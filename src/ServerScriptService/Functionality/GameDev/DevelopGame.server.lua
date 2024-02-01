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
local RANDOM = Random.new()
local PHASE_INTRO_LENGTH = 5
local PHASE_1_PLR_CONTRIBUTION_PTS = 10 -- the game pts contributed when plr interacts w/ btn (w/o help of staff)
local PC_PHASE1_BTNS = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q",
"R", "S", "T", "U", "V", "W", "X", "Y", "Z"}
local PHASE1_BTN_TYPES = {"Code", "Sound", "Art"}
local PHASE1_BTN_LIFETIME = 4
local PHASE_1_LENGTH = 20
local BUG_ICON_DEFAULT = "16127668114"
local BUG_ICON_SQUASHED = "16127669693"
local BUG_MAX_ONSCREEN_TIME = 11
local BUGFIX_PHASE_LENGTH = 15

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
        local instance = StaffMemberConfig.new(uuid, data)

        helpingStaffMembers.StaffMembers[uuid] = {
            StaffMemberData = data,
            PointsContribution = {
                Code = instance:GetSpecificSkillPoints("code"),
                Sound = instance:GetSpecificSkillPoints("sound"),
                Art = instance:GetSpecificSkillPoints("art")
            },
            EnergyUsage = { ["Phase1"] = calcStaffMemberPhase1EnergyUsage(uuid, data, totalStaffPts) },
            Active = data.CurrentEnergy > 0
        }
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

local function adjustGamePts(plr: Player, phase: string, pointsType: "Code" | "Sound" | "Art", opts: {}): number
    local gameStateInfo = plrsDeveloping[plr.UserId]
    if not gameStateInfo then return end

    opts = opts or {}
    
    -- get staff members who are still active (not out of energy)
    local activeStaffMembers = {}
    for staffMemberUUID, staffMemberInfo in gameStateInfo.StaffMembersInfo.StaffMembers do
        if staffMemberInfo.Active then table.insert(activeStaffMembers, staffMemberUUID) end
    end

    local ptsToAdjustBy: number
    local optsToSend = {}
    
    -- pts only get added upon clicking btn
    if phase == "1" then
        local adjustment = RANDOM:NextNumber(0.8, 1.2) -- ensures variance each time game pts get adjusted

        -- calc total contributed pts of the specific point type, and each staff members contribution
        optsToSend["StaffMemberContributions"] = {}
        optsToSend["StaffMemberContributions"]["Individual"] = {}
        optsToSend["StaffMemberContributions"]["Total"] = 0
        for _i, staffMemberUUID: string in activeStaffMembers do
            local ptContribution = gameStateInfo.StaffMembersInfo.StaffMembers[staffMemberUUID].PointsContribution[pointsType]
            local contributionAmt: number = ptContribution
            contributionAmt = opts["IsBomb"] and -contributionAmt or contributionAmt

            optsToSend["StaffMemberContributions"]["Total"] += contributionAmt
            optsToSend["StaffMemberContributions"]["Individual"][staffMemberUUID] = math.floor(contributionAmt * adjustment)
        end

        local plrContributionPts = math.floor(PHASE_1_PLR_CONTRIBUTION_PTS * adjustment)
        if opts["IsBomb"] then plrContributionPts = -plrContributionPts end

        ptsToAdjustBy = #activeStaffMembers == 0 and plrContributionPts or (plrContributionPts + math.floor(optsToSend["StaffMemberContributions"]["Total"] * adjustment))
    
    elseif phase == "2" then
        
    end

    local currentPtAmt = gameStateInfo.GamePoints[pointsType]
    if currentPtAmt + ptsToAdjustBy < 0 then
        gameStateInfo.GamePoints[pointsType] = 0
    else
        gameStateInfo.GamePoints[pointsType] += ptsToAdjustBy
    end

    local pointsLost: boolean = ptsToAdjustBy < 0
    Remotes.GameDev.CreateGame.AdjustGamePoints:FireClient(plr, phase, pointsType, gameStateInfo.GamePoints[pointsType], pointsLost, optsToSend)
end

-- opts
-- -- Ignore: boolean -- When specified, the bug gets removed but doesn't contribute to gameStateInfo.PhaseInfo["-1"].Misses (usecases incl removing bugs after timer has run out that are still on-screen)
local function endBugLife(plr: Player, bugId: number, endOnPlrInteraction: boolean, opts: {})
    opts = opts or {}

    local gameStateInfo = plrsDeveloping[plr.UserId]
    if not gameStateInfo then return end

    -- check if the bug exists first
    local exists = table.find(gameStateInfo.PhaseInfo["-1"].CurrentlyDisplayedBugs, bugId)
    if not exists then return end

    -- if endOnPlrInteraction then plr squashed bug, otherwise they missed/ran out of time
    if endOnPlrInteraction then
        gameStateInfo.PhaseInfo["-1"].Hits += 1
    else
        if not opts["Ignore"] then gameStateInfo.PhaseInfo["-1"].Misses += 1 end
    end

    Remotes.GameDev.CreateGame.BugFixPhase.SquashBug:FireClient(plr, bugId, endOnPlrInteraction)
    
    local index = table.find(gameStateInfo.PhaseInfo["-1"].CurrentlyDisplayedBugs, bugId)
    if index then table.remove(gameStateInfo.PhaseInfo["-1"].CurrentlyDisplayedBugs, index) end
end

local function sendBug(plr: Player)
    local gameStateInfo = plrsDeveloping[plr.UserId]
    if not gameStateInfo then return end

    gameStateInfo.PhaseInfo["-1"].TotalBugs += 1

    local bugId: number = gameStateInfo.PhaseInfo["-1"].TotalBugs
    table.insert(gameStateInfo.PhaseInfo["-1"].CurrentlyDisplayedBugs, bugId)

    Remotes.GameDev.CreateGame.BugFixPhase.SendBug:FireClient(plr, bugId)

    -- end bugs life if plr misses it and it runs off-screen
    task.delay(BUG_MAX_ONSCREEN_TIME, function() endBugLife(plr, bugId, false) end)
end

local function initiateBugFixPhase(plr: Player)
    local gameStateInfo = plrsDeveloping[plr.UserId]
    if not gameStateInfo then return end

    gameStateInfo.Phase = -1
    gameStateInfo.PhaseInfo["-1"] = {
        CurrentlyDisplayedBugs = {},
        TotalBugs = 0,
        Hits = 0,
        Misses = 0
    }

    Remotes.GUI.GameDev.DisplayPhaseIntro:FireClient(plr, "-1")
    task.wait(PHASE_INTRO_LENGTH)

    Remotes.GameDev.CreateGame.StartPhase:FireClient(plr, -1)
    
    gameStateInfo.Timer = BUGFIX_PHASE_LENGTH
    Remotes.GUI.GameDev.StartTimerBar:FireClient(plr, gameStateInfo.Timer)

    -- send bugs
    task.spawn(function()
        while gameStateInfo and (gameStateInfo.Phase == -1) and (gameStateInfo.Timer > 3) do
            sendBug(plr)
            task.wait(1)
        end
    end)

    -- update timer
    while gameStateInfo and (gameStateInfo.Timer > 0) and (gameStateInfo.Phase == -1) do
        task.wait(1)
        gameStateInfo.Timer -= 1
    end

    -- end bug fix phase
    local bugsLeft = gameStateInfo.PhaseInfo["-1"].CurrentlyDisplayedBugs
    for i = #bugsLeft, 1, -1 do
        endBugLife(plr, bugsLeft[i], false)
    end
end

local function initiatePhase2(plr: Player)
    local gameStateInfo = plrsDeveloping[plr.UserId]
    if not gameStateInfo then return end

    gameStateInfo.Phase = 2
    gameStateInfo.PhaseInfo["2"] = {}

    Remotes.GUI.GameDev.DisplayPhaseIntro:FireClient(plr, "2")
    task.wait(PHASE_INTRO_LENGTH)

    Remotes.GameDev.CreateGame.StartPhase:FireClient(plr, 2)
end

-- function for 'resolving' a button, whether that's through a plr interacting w/ it or when a button reaches it's lifetime
-- endOnPlrInteraction -> boolean: indicates whether btn life is ending as a result of plr interaction or not (if not, then plr ran out of time)
local function endBtnLife(plr: Player, endOnPlrInteraction: boolean, btnId: number)
    local gameStateInfo = plrsDeveloping[plr.UserId]
    if not gameStateInfo then return end

    -- check if the btn exists first
    local btnInfo = gameStateInfo.PhaseInfo["1"].CurrentlyDisplayedBtns[btnId]
    if not btnInfo then return end


    local isBomb = btnInfo.IsBomb
    -- if endOnPlrInteraction then plr hit btn, otherwise they missed/ran out of time
    if endOnPlrInteraction then
        if isBomb then
            gameStateInfo.PhaseInfo["1"].BadHits += 1
        else
            gameStateInfo.PhaseInfo["1"].GoodHits += 1
        end
    else
        if not isBomb then
            gameStateInfo.PhaseInfo["1"].Misses += 1
        end
    end

    if endOnPlrInteraction then adjustGamePts(plr, "1", btnInfo.BtnType, { IsBomb = isBomb }) end

    Remotes.GameDev.CreateGame.Phase1.RemoveBtn:FireClient(plr, btnId, endOnPlrInteraction, isBomb)

    gameStateInfo.PhaseInfo["1"].CurrentlyDisplayedBtns[btnId] = nil
end

local function sendBtn(plr: Player)
    local gameStateInfo = plrsDeveloping[plr.UserId]
    if not gameStateInfo then return end

    gameStateInfo.PhaseInfo["1"].TotalBtns += 1

    local btnId = gameStateInfo.PhaseInfo["1"].TotalBtns
    local btnType: "Code" | "Sound" | "Art" = PHASE1_BTN_TYPES[math.random(1, #PHASE1_BTN_TYPES)]
    local isBomb = math.random(1, 10) >= 8

    if gameStateInfo["PlrPlatform"] == "pc" then
        local availableInputs = {unpack(PC_PHASE1_BTNS)}
        for _btnId, btnInfo in gameStateInfo.PhaseInfo["1"].CurrentlyDisplayedBtns do
            local index = table.find(availableInputs, btnInfo.Value)
            if index then table.remove(availableInputs, index) end
        end
        
        local btnValue = availableInputs[math.random(1, #availableInputs)]
        gameStateInfo.PhaseInfo["1"].CurrentlyDisplayedBtns[btnId] = { BtnType = btnType, Value = btnValue, IsBomb = isBomb}

        Remotes.GameDev.CreateGame.Phase1.SendBtn:FireClient(plr, isBomb, { BtnId = btnId, BtnType = btnType, BtnValue = btnValue })
        
    elseif gameStateInfo["PlrPlatform"] == "mobile" then
        gameStateInfo.PhaseInfo["1"].CurrentlyDisplayedBtns[btnId] = { BtnType = btnType, IsBomb = isBomb}
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

        for id, btnInfo in gameStateInfo.PhaseInfo["1"].CurrentlyDisplayedBtns do
            if inputKeyCode == Enum.KeyCode[btnInfo.Value] then
                btnId = id
                break
            end
        end
    
    elseif gameStateInfo.PlrPlatform == "mobile" then
        if not gameStateInfo.PhaseInfo["1"].CurrentlyDisplayedBtns[tonumber(opts.BtnId)] then return end
        btnId = tonumber(opts.BtnId)
    end

    if btnId then endBtnLife(plr, true, btnId) end
end

local function initiatePhase1(plr: Player)
    local gameStateInfo = plrsDeveloping[plr.UserId]
    if not gameStateInfo then return end

    gameStateInfo.Phase = 1
    gameStateInfo.PhaseInfo["1"] = {
        TotalBtns = 0,
        CurrentlyDisplayedBtns = {},
        GoodHits = 0, -- hitting a btn on time
        BadHits = 0, -- hitting a bomb
        Misses = 0, -- not hitting a btn on time
    }
    
    Remotes.GUI.GameDev.DisplayPhaseIntro:FireClient(plr, "1")
    task.wait(PHASE_INTRO_LENGTH)

    Remotes.GameDev.CreateGame.StartPhase:FireClient(plr, 1)
    
    gameStateInfo.Timer = PHASE_1_LENGTH
    Remotes.GUI.GameDev.StartTimerBar:FireClient(plr, gameStateInfo.Timer)

    -- helping staff members
    task.spawn(function()
        while gameStateInfo and (gameStateInfo.Phase == 1) and (gameStateInfo.Timer > 0) do
            for staffMemberUUID: string, staffMemberInfo: {} in gameStateInfo.StaffMembersInfo.StaffMembers do
                if staffMemberInfo.StaffMemberData.CurrentEnergy <= 0 then
                    gameStateInfo.StaffMembersInfo.StaffMembers[staffMemberUUID].Active = false
                    continue
                end

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
            sendBtn(plr)
            task.wait(RANDOM:NextNumber(0.5, 0.8))
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

Remotes.GameDev.CreateGame.DevelopGame.OnServerEvent:Connect(function(plr: Player, selectedGenre: string, selectedTopic: string)
    plr:SetAttribute("CurrentlyDevelopingGame", true)
    Remotes.GameDev.CreateGame.DevelopGame:FireClient(plr)
    
    initializeGameDevState(plr, selectedGenre, selectedTopic)

    -- start phase 1
    initiatePhase1(plr)
end)

Remotes.GameDev.CreateGame.GetPcPhase1BtnValues.OnServerInvoke = function() return PC_PHASE1_BTNS end

Remotes.GameDev.CreateGame.Phase1.ValidateInput.OnServerEvent:Connect(validatePhase1Input)

Remotes.GameDev.CreateGame.BugFixPhase.SquashBug.OnServerEvent:Connect(endBugLife)

for _i, plr: Player in Players:GetPlayers() do
    plrsDeveloping[plr.UserId] = false
end

Players.PlayerAdded:Connect(function(plr: Player)
    plrsDeveloping[plr.UserId] = false
end)

Players.PlayerRemoving:Connect(function(plr: Player)
    plrsDeveloping[plr.UserId] = nil
end)