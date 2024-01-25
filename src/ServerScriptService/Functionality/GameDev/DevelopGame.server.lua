local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local PlrPlatformManager = require(ServerScriptService.PlayerData.PlrPlatformManager)
local GeneralUtils = require(ReplicatedStorage.Utils.GeneralUtils)
local StudioConfig = require(ReplicatedStorage.Configs.Studio.Studio)
local StaffMemberConfigServer = require(ServerScriptService.Functionality.Staff.StaffMemberServer)
local StaffMemberConfig = require(ReplicatedStorage.Configs.Staff.StaffMember)

local Remotes = ReplicatedStorage.Remotes

-- STATE VARIABLES --
-- keeps track of all plrs in the server and information on games they're developing
-- { [plr.UserId] = {gamestate} | false }
local plrsDeveloping = {}

-- CONSTANT VARIABLES --
local PC_PHASE1_BTNS = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q",
"R", "S", "T", "U", "V", "W", "X", "Y", "Z"}
local PHASE1_BTN_TYPES = {"Code", "Sound", "Art"}
local PHASE1_BTN_LIFETIME = 4
local PHASE_1_LENGTH = 20

-- calculates the energy usage of a staff member across the entire length of Phase 1
local function calcStaffMemberPhase1EnergyUsage(staffMemberUUID: string, staffMemberData: {}, totalPtsAcrossStaff: number): number
    local staffMemberInstance: StaffMemberConfig.StaffMemberInstance = StaffMemberConfig.new(staffMemberUUID, staffMemberData)
    local staffMemberPts: number = staffMemberInstance:GetTotalSkillPts()
    local energyUsedProportion: number = 1 - (staffMemberPts / totalPtsAcrossStaff)
    local energyUsedProportionClamped: number = math.clamp(0.3, energyUsedProportion, 1) -- the actual proportion value
    local energyUsedActual = staffMemberInstance:CalcMaxEnergy() * energyUsedProportionClamped

    return energyUsedActual
end

local function initializeGameDevState(plr: Player, selectedGenre: string, selectedTopic: string)
    local profile = PlrDataManager.Profiles[plr]

    if not profile.Data.GameDev.Genres[selectedGenre] then return end
    if not profile.Data.GameDev.Topics[selectedTopic] then return end

    local helpingStaffMembersUUIDS = {}
    local staffInStudio = StudioConfig.GetStaffInActiveStudio(profile.Data)
    for uuid: string, _data: {} in staffInStudio do table.insert(helpingStaffMembersUUIDS, uuid) end
    
    local helpingStaffMembers = { StaffMembers = {}, TotalStaffPts = 0 }
    local totalStaffPts = StaffMemberConfig.GetTotalSkillPtsAcrossNumerousStaff(profile.Data, helpingStaffMembersUUIDS)
    for uuid: string, data: {} in staffInStudio do
        helpingStaffMembers.StaffMembers[uuid] = { StaffMemberData = data, EnergyUsage = { ["Phase1"] = calcStaffMemberPhase1EnergyUsage(uuid, data, totalStaffPts) } }
    end
    helpingStaffMembers["TotalStaffPts"] = totalStaffPts

    plrsDeveloping[plr.UserId] = {
        PlrPlatform = PlrPlatformManager.GetProfile(plr).Platform , -- the platform the plr is on (pc, mobile or console)
        HighestUnlockedPhase = profile.Data.GameDev.HighestGameDevPhase,
        Phase = 0, -- phase 0 is the countdown before phase 1 begins
        Genre = selectedGenre,
        Topic = selectedTopic,
        StaffMembersInfo = helpingStaffMembers,
        GamePoints = { Code = 0, Sound = 0, Art = 0 },
        PhaseInfo = {},
        Timer = 5 -- the amt of time the current phase should last for, resets to a number (seconds) at the start of each phase
    }
end

local function initiateBugFixPhase(plr: Player)

end

local function initiatePhase2(plr: Player)

end

-- function for 'resolving' a button, whether that's through a plr interacting w/ it or when a button reaches it's lifetime
-- endOnPlrInteraction -> boolean: indicates whether btn life is ending as a result of plr interaction or not (if not, then plr ran out of time)
local function endBtnLife(plr: Player, endOnPlrInteraction: boolean, btnId: number)
    local gameStateInfo = plrsDeveloping[plr.UserId]
    if not gameStateInfo then return end

    -- check if the btn exists first
    local exists = gameStateInfo.PhaseInfo["Phase 1"].CurrentlyDisplayedBtns[btnId]
    if not exists then return end


    local isBomb = gameStateInfo.PhaseInfo["Phase 1"].CurrentlyDisplayedBtns[btnId].IsBomb
    -- if endOnPlrInteraction then plr hit btn, otherwise they missed/ran out of time
    if endOnPlrInteraction then
        if isBomb then
            gameStateInfo.PhaseInfo["Phase 1"].BadHits += 1
        else
            gameStateInfo.PhaseInfo["Phase 1"].GoodHits += 1
        end
    else
        if not isBomb then
            gameStateInfo.PhaseInfo["Phase 1"].Misses += 1
        end
    end

    Remotes.GameDev.CreateGame.Phase1.RemoveBtn:FireClient(plr, btnId, endOnPlrInteraction, gameStateInfo.PhaseInfo["Phase 1"].CurrentlyDisplayedBtns[btnId].IsBomb)
    gameStateInfo.PhaseInfo["Phase 1"].CurrentlyDisplayedBtns[btnId] = nil
end

local function sendBtn(plr: Player)
    local gameStateInfo = plrsDeveloping[plr.UserId]
    if not gameStateInfo then return end

    local btnId = gameStateInfo.PhaseInfo["Phase 1"].TotalBtns
    local btnType: "Code" | "Sound" | "Art" = PHASE1_BTN_TYPES[math.random(1, #PHASE1_BTN_TYPES)]
    local isBomb = math.random(1, 10) >= 8

    if gameStateInfo["PlrPlatform"] == "pc" then
        local availableInputs = {unpack(PC_PHASE1_BTNS)}
        for _btnId, btnInfo in gameStateInfo.PhaseInfo["Phase 1"].CurrentlyDisplayedBtns do
            local index = table.find(availableInputs, btnInfo.Value)
            if index then table.remove(availableInputs, index) end
        end
        
        local btnValue = availableInputs[math.random(1, #availableInputs)]
        gameStateInfo.PhaseInfo["Phase 1"].CurrentlyDisplayedBtns[btnId] = { BtnType = btnType, Value = btnValue, IsBomb = isBomb}

        Remotes.GameDev.CreateGame.Phase1.SendBtn:FireClient(plr, isBomb, { BtnId = btnId, BtnType = btnType, BtnValue = btnValue })
        
    elseif gameStateInfo["PlrPlatform"] == "mobile" then
        gameStateInfo.PhaseInfo["Phase 1"].CurrentlyDisplayedBtns[btnId] = { BtnType = btnType, IsBomb = isBomb}
        Remotes.GameDev.CreateGame.Phase1.SendBtn:FireClient(plr, isBomb, { BtnId = btnId, BtnType = btnType })
    end
    

    -- end btn life
    task.delay(PHASE1_BTN_LIFETIME, function() endBtnLife(plr, false, btnId) end)
end

local function validatePhase1Input(plr: Player, opts: {})
    local gameStateInfo = plrsDeveloping[plr.UserId]
    if not gameStateInfo then return end
    if gameStateInfo.Phase ~= 1 then return end
    
    local btnId: number = nil
    if gameStateInfo.PlrPlatform == "pc" then
        local inputKeyCode = opts.InputKeyCode

        for id, btnInfo in gameStateInfo.PhaseInfo["Phase 1"].CurrentlyDisplayedBtns do
            if inputKeyCode == Enum.KeyCode[btnInfo.Value] then
                btnId = id
                break
            end
        end
    
    elseif gameStateInfo.PlrPlatform == "mobile" then
        if not gameStateInfo.PhaseInfo["Phase 1"].CurrentlyDisplayedBtns[tonumber(opts.BtnId)] then return end
        btnId = tonumber(opts.BtnId)
    end

    if btnId then endBtnLife(plr, true, btnId) end
end

local function initiatePhase1(plr: Player)
    local gameStateInfo = plrsDeveloping[plr.UserId]
    gameStateInfo.Phase = 1
    gameStateInfo.PhaseInfo["Phase 1"] = {
        TotalBtns = 0,
        CurrentlyDisplayedBtns = {},
        GoodHits = 0, -- hitting a btn on time
        BadHits = 0, -- hitting a bomb
        Misses = 0, -- not hitting a btn on time
    }
    Remotes.GameDev.CreateGame.StartPhase:FireClient(plr, 1)
    
    gameStateInfo.Timer = PHASE_1_LENGTH
    Remotes.GUI.GameDev.StartTimerBar:FireClient(plr, gameStateInfo.Timer)

    local random = Random.new()

    -- helping staff members
    task.spawn(function()
        while gameStateInfo and (gameStateInfo.Phase == 1) and (gameStateInfo.Timer > 0) do
            for staffMemberUUID: string, staffMemberInfo: {} in gameStateInfo.StaffMembersInfo.StaffMembers do
                local staffMemberInstance = StaffMemberConfig.new(staffMemberUUID, staffMemberInfo.StaffMemberData)
                local staffMemberEnergyUsage = staffMemberInfo.EnergyUsage.Phase1 / PHASE_1_LENGTH

                staffMemberInstance:AdjustEnergy(plr, staffMemberUUID, -staffMemberEnergyUsage)
            end

            task.wait(1)
        end
    end)

    -- send phase 1 btns
    task.spawn(function()
        while gameStateInfo and (gameStateInfo.Phase == 1) and (gameStateInfo.Timer > PHASE1_BTN_LIFETIME) do
            gameStateInfo.PhaseInfo["Phase 1"].TotalBtns += 1
            sendBtn(plr)

            task.wait(random:NextNumber(0.3, 0.5))
        end
    end)

    -- update timer
    while gameStateInfo and (gameStateInfo.Timer > 0) and (gameStateInfo.Phase == 1) do
        task.wait(1)
        gameStateInfo.Timer -= 1
    end

    -- proceed to phase 2 if the player has it unlocked, otherwise go straight to bug-fix stage
    if gameStateInfo.HighestUnlockedPhase >= 2 then initiatePhase2(plr) else initiateBugFixPhase(plr) end
end

local function setCountdown(plr: Player)
    local gameStateInfo = plrsDeveloping[plr.UserId]
    if not gameStateInfo then return end

    Remotes.GUI.GameDev.DisplayTimerText:FireClient(plr, gameStateInfo.Timer)

    while gameStateInfo and (gameStateInfo.Timer > 0) and (gameStateInfo.Phase == 0) do
        task.wait(1)
        gameStateInfo.Timer -= 1
        Remotes.GUI.GameDev.UpdateTimerText:FireClient(plr, gameStateInfo.Timer)
    end

    -- proceed to phase 1
    initiatePhase1(plr)
end

Remotes.GameDev.CreateGame.DevelopGame.OnServerEvent:Connect(function(plr: Player, selectedGenre: string, selectedTopic: string)
    plr:SetAttribute("CurrentlyDevelopingGame", true)
    Remotes.GameDev.CreateGame.DevelopGame:FireClient(plr)
    
    initializeGameDevState(plr, selectedGenre, selectedTopic)
    setCountdown(plr)
end)

Remotes.GameDev.CreateGame.GetPcPhase1BtnValues.OnServerInvoke = function() return PC_PHASE1_BTNS end

Remotes.GameDev.CreateGame.Phase1.ValidateInput.OnServerEvent:Connect(validatePhase1Input)

for _i, plr: Player in Players:GetPlayers() do
    plrsDeveloping[plr.UserId] = false
end

Players.PlayerAdded:Connect(function(plr: Player)
    plrsDeveloping[plr.UserId] = false
end)

Players.PlayerRemoving:Connect(function(plr: Player)
    plrsDeveloping[plr.UserId] = nil
end)