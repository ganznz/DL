local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local Zone = require(ReplicatedStorage.Libs.Zone)
local CashierConfig = require(ReplicatedStorage.Configs.Jobs.Cashier)
local PlayerConfig = require(ReplicatedStorage.Configs.Player)
local plrDataTemplate = require(ReplicatedStorage.PlayerData.Template)

local Remotes = ReplicatedStorage.Remotes

local iceCreamStoreFolder = Workspace.Map.Buildings.IceCreamStore
local icecreamStoreExteriorTeleport = iceCreamStoreFolder.IceCreamStoreExterior.TeleportToPart
local icecreamStoreTeleportHitbox = iceCreamStoreFolder:FindFirstChild("TeleportHitboxZone", true)
local zone = Zone.new(icecreamStoreTeleportHitbox)

zone.playerEntered:Connect(function(plr: Player)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end
    local plrData: plrDataTemplate.PlayerData = profile.Data

    local plrCashierInstance = plrData.Jobs.Cashier.CashierInstance

    Remotes.GUI.ChangeGuiStatusRemote:FireClient(plr, "cashierJobInfo", true, {
        jobLevel = CashierConfig.GetLevel(plrCashierInstance),
        xp = CashierConfig.GetXp(plrCashierInstance),
        levelUpXpRequirement = CashierConfig.CalcLevelUpXpRequirement(plrCashierInstance),
        skillPointsReward = CashierConfig.CalcPotentialSkillPoints(plrCashierInstance),
    })
end)

zone.playerExited:Connect(function(plr: Player)
    Remotes.GUI.ChangeGuiStatusRemote:FireClient(plr, "cashierJobInfo", false, nil)
end)


-- push plrs who are in an active shift to this table
-- { [Player]: { remainingTime: number, goodOrders: number, badOrders: number } }
local activeShifts = {}

local SHIFT_TIMER = 10 -- seconds
local SHIFT_COOLDOWN = 0 -- seconds
local ICECREAM_FLAVOURS = {"Chocolate", "Vanilla", "Strawberry"}

local function startActiveShift(plr: Player)
    local shift = {
        remainingTime = SHIFT_TIMER,
        goodOrders = 0,
        badOrders = 0,
        currentCustomer = nil -- information on current customer
    }
    activeShifts[plr.Name] = shift
end

local function sendCustomer(plr: Player)
    local customerInfo = { icecream = ICECREAM_FLAVOURS[math.random(1, #ICECREAM_FLAVOURS)] }
    activeShifts[plr.Name].currentCustomer = customerInfo
    Remotes.Jobs.Cashier.SendCustomer:FireClient(plr, customerInfo)
end

Remotes.Jobs.StartShift.OnServerEvent:Connect(function(plr: Player, job: string)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    if job == "IceCreamStoreCashier" and (profile.Data.Jobs.Cashier.ShiftCooldown - os.time() <= 0) then
        startActiveShift(plr)
        task.delay(2, function()
            Remotes.GUI.Jobs.UpdateJobTimer:FireClient(plr, activeShifts[plr.Name].remainingTime)
            Remotes.GUI.Jobs.ChangeJobTimerVisibility:FireClient(plr, true)
            sendCustomer(plr)
        end)
    end
end)

local function endActiveShift(plr: Player, forceEndedShift: boolean)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end
    local plrData: plrDataTemplate.PlayerData = profile.Data

    local cashierJobInstance = plrData.Jobs.Cashier.CashierInstance
    local shiftDetails = activeShifts[plr.Name]
    activeShifts[plr.Name] = nil

    -- details to populate gui with
    local preShiftSkillLvl = CashierConfig.GetLevel(cashierJobInstance)
    local preShiftSkillXp = CashierConfig.GetXp(cashierJobInstance)
    local preShiftSkillLvlUpXpRequirement = CashierConfig.CalcLevelUpXpRequirement(cashierJobInstance)
    local skillPointsReward = CashierConfig.CalcActualSkillPoints(cashierJobInstance, shiftDetails)
    local preShiftPlrLvl = PlayerConfig.GetLevel(plrData)
    local preShiftPlrXp = PlayerConfig.GetXp(plrData)
    local preShiftPlrLvlUpXpRequirement = PlayerConfig.CalcLevelUpXpRequirement(plrData)

    -- ADD METHODS FOR DETECTING IF THERE ARE NEW JOB UPGRADES ON LEVEL UP!!!!

    -- adjust plr stats
    local jobXpGained = CashierConfig.CalcXpGained(cashierJobInstance, shiftDetails)
    PlrDataManager.AdjustPlrJobXp(plr, "cashierJob", jobXpGained)

    -- gui remotes
    Remotes.GUI.Jobs.ChangeJobTimerVisibility:FireClient(plr, false)
    Remotes.GUI.ChangeGuiStatusRemote:FireClient(plr, "loadingBgSplash", true, { TeleportPart = icecreamStoreExteriorTeleport })
    profile.Data.Jobs.Cashier.ShiftCooldown = os.time() + SHIFT_COOLDOWN
    task.delay(1, function()
        -- show shift details
        Remotes.GUI.ChangeGuiStatusRemote:FireClient(plr, "jobShiftDetails", true, {
            jobType = "cashierJob",
            jobInstance = cashierJobInstance,
            forceEndedShift = forceEndedShift,
            preShiftSkillLvl = preShiftSkillLvl,
            preShiftSkillXp = preShiftSkillXp,
            preShiftSkillLvlUpXpRequirement = preShiftSkillLvlUpXpRequirement,
            skillPointsReward = skillPointsReward,
            preShiftPlrLvl = preShiftPlrLvl,
            preShiftPlrXp = preShiftPlrXp,
            preShiftPlrLvlUpXpRequirement = preShiftPlrLvlUpXpRequirement,
            
        })
    end)

    Remotes.Jobs.EndShift:FireClient(plr, "cashierJob")
end

Remotes.Jobs.Cashier.CustomerOrderFulfilled.OnServerEvent:Connect(function(plr: Player, orderStatus: 'good' | 'bad')
    if activeShifts[plr.Name] then
        if orderStatus == 'good' then activeShifts[plr.Name].goodOrders += 1 else activeShifts[plr.Name].badOrders += 1 end
        sendCustomer(plr)
    end
end)

Players.PlayerAdded:Connect(function(plr: Player)
    plr.CharacterAdded:Connect(function(char: Model)
        local humanoid: Humanoid = char:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            if activeShifts[plr.Name] then
                endActiveShift(plr, true) -- force end shift early
            end
        end)
    end)
end)

while true do
    for _, plr in Players:GetPlayers() do
        local profile = PlrDataManager.Profiles[plr]
        if not profile then continue end
        local plrData: plrDataTemplate.PlayerData = profile.Data

        Remotes.GUI.Jobs.UpdateJobAvailableTimer:FireClient(plr, "cashierJob", plrData.Jobs.Cashier.ShiftCooldown)
    end

    -- update current active shifts
    for plrName, _shiftInfo in activeShifts do
        local plr = Players:FindFirstChild(plrName)
        local profile = PlrDataManager.Profiles[plr]
        if not profile then continue end
        
        activeShifts[plrName].remainingTime -= 1
        Remotes.GUI.Jobs.UpdateJobTimer:FireClient(plr, activeShifts[plrName].remainingTime)


        if activeShifts[plrName].remainingTime == 0 then
            endActiveShift(plr, false)
        end
    end

    task.wait(1)
end
