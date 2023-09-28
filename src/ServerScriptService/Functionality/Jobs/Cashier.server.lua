local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local Zone = require(ReplicatedStorage.Libs.Zone)
local JobConfig = require(ReplicatedStorage.Configs.Jobs.Cashier)
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
        jobLevel = JobConfig.GetLevel(plrCashierInstance),
        xp = JobConfig.GetXp(plrCashierInstance),
        levelUpXpRequirement = JobConfig.CalcLevelUpXpRequirement(plrCashierInstance),
        traitPointsReward = JobConfig.CalcTraitPoints(plrCashierInstance),
    })
end)

zone.playerExited:Connect(function(plr: Player)
    Remotes.GUI.ChangeGuiStatusRemote:FireClient(plr, "cashierJobInfo", false, nil)
end)


-- push plrs who are in an active shift to this table
-- { [Player]: { remainingTime: number, goodOrders: number, badOrders: number } }
local activeShifts = {}

local SHIFT_TIMER = 120 -- seconds
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
        task.delay(4, function()
            startActiveShift(plr)
            Remotes.GUI.Jobs.UpdateJobTimer:FireClient(plr, activeShifts[plr.Name].remainingTime)
            Remotes.GUI.Jobs.ChangeJobTimerVisibility:FireClient(plr, true)
            sendCustomer(plr)
        end)
    end
end)

Remotes.Jobs.Cashier.CustomerOrderFulfilled.OnServerEvent:Connect(function(plr: Player, orderStatus: 'good' | 'bad')
    if activeShifts[plr.Name] then
        if orderStatus == 'good' then activeShifts[plr.Name].goodOrders += 1 else activeShifts[plr.Name].badOrders += 1 end
        sendCustomer(plr)
    end
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
            -- finish shift
            activeShifts[plrName] = nil
            Remotes.GUI.Jobs.ChangeJobTimerVisibility:FireClient(plr, false)
            Remotes.GUI.ChangeGuiStatusRemote:FireClient(plr, "loadingBgSplash", true, { TeleportPart = icecreamStoreExteriorTeleport })
            profile.Data.Jobs.Cashier.ShiftCooldown = os.time() + SHIFT_TIMER
        end
    end

    task.wait(1)
end
