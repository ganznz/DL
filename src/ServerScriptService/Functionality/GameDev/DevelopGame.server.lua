local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local PlrPlatformManager = require(ServerScriptService.PlayerData.PlrPlatformManager)
local StudioConfig = require(ReplicatedStorage.Configs.Studio.Studio)
local GeneralUtils = require(ReplicatedStorage.Utils.GeneralUtils)

local Remotes = ReplicatedStorage.Remotes

-- STATE VARIABLES --
-- keeps track of all plrs in the server and information on games they're developing
-- { [plr.UserId] = {gamestate} | false }
local plrsDeveloping = {}

-- CONSTANT VARIABLES --
local PC_PHASE1_BTNS = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q",
"R", "S", "T", "U", "V", "W", "X", "Y", "Z"}
local PHASE1_BTN_LIFETIME = 4

local function initializeGameDevState(plr: Player, selectedGenre: string, selectedTopic: string)
    local profile = PlrDataManager.Profiles[plr]

    if not profile.Data.GameDev.Genres[selectedGenre] then return end
    if not profile.Data.GameDev.Topics[selectedTopic] then return end

    local helpingStaffMembers = StudioConfig.GetStaffInActiveStudio(profile.Data)

    plrsDeveloping[plr.UserId] = {
        PlrPlatform = PlrPlatformManager.GetProfile(plr).Platform , -- the platform the plr is on (pc, mobile or console)
        Phase = 0, -- phase 0 is the countdown before phase 1 begins
        Genre = selectedGenre,
        Topic = selectedTopic,
        StaffMembers = helpingStaffMembers,
        GamePoints = { Code = 0, Sound = 0, Art = 0 },
        PhaseInfo = {},
        Timer = 5 -- the amt of time the current phase should last for, resets to a number (seconds) at the start of each phase
    }
end

-- function for 'resolving' a button, whether that's through a plr interacting w/ it or when a button reaches it's lifetime
-- endOnPlrInteraction -> boolean: indicates whether btn life is ending as a result of plr interaction or not (if not, then plr ran out of time)
-- opts -> {}
-- --
local function endBtnLife(plr: Player, endOnPlrInteraction: boolean, btnId: number)
    local gameStateInfo = plrsDeveloping[plr.UserId]
    if not gameStateInfo then return end

    -- check if the btn the client pressed is actually present in game state
    if gameStateInfo.PlrPlatform == "pc" then
        if endOnPlrInteraction then
            local exists = gameStateInfo.PhaseInfo["Phase 1"].CurrentlyDisplayedBtns[btnId]
            if not exists then return end
        end
    
    elseif gameStateInfo.PlrPlatform == "mobile" then
        
    else return end

    Remotes.GameDev.CreateGame.Phase1.RemoveBtn:FireClient(plr, btnId, endOnPlrInteraction)
    gameStateInfo.PhaseInfo["Phase 1"].CurrentlyDisplayedBtns[btnId] = nil
end

local function sendBtn(plr: Player)
    local gameStateInfo = plrsDeveloping[plr.UserId]
    if not gameStateInfo then return end

    local btnId = gameStateInfo.PhaseInfo["Phase 1"].TotalBtns
    local isBomb = math.random(1, 10) >= 8

    if gameStateInfo["PlrPlatform"] == "pc" then
        local availableInputs = {unpack(PC_PHASE1_BTNS)}
        for _btnId, btnInfo in gameStateInfo.PhaseInfo["Phase 1"].CurrentlyDisplayedBtns do
            local index = table.find(availableInputs, btnInfo.Value)
            if index then table.remove(availableInputs, index) end
        end
        
        local btnValue = availableInputs[math.random(1, #availableInputs)]
        gameStateInfo.PhaseInfo["Phase 1"].CurrentlyDisplayedBtns[btnId] = { Value = btnValue, IsBomb = isBomb}

        Remotes.GameDev.CreateGame.Phase1.SendBtn:FireClient(plr, isBomb, { BtnId = btnId, BtnValue = btnValue })
        
        elseif gameStateInfo["PlrPlatform"] == "mobile" then
        Remotes.GameDev.CreateGame.Phase1.SendBtn:FireClient(plr, isBomb, { BtnId = btnId })
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
        if not gameStateInfo.PhaseInfo["Phase 1"].CurrentlyDisplayedBtns[opts.BtnId] then return end
        btnId = opts.BtnId
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
    
    gameStateInfo.Timer = 15
    Remotes.GUI.GameDev.StartTimerBar:FireClient(plr, gameStateInfo.Timer)

    local random = Random.new()

    -- send phase 1 btns
    task.spawn(function()
        while gameStateInfo and (gameStateInfo.Timer > 0) and (gameStateInfo.Phase == 1) do
            gameStateInfo.PhaseInfo["Phase 1"].TotalBtns += 1
            sendBtn(plr)

            task.wait(random:NextNumber(1, 1.5))
        end
    end)

    -- update timer
    while gameStateInfo and (gameStateInfo.Timer > 0) and (gameStateInfo.Phase == 1) do
        task.wait(1)
        gameStateInfo.Timer -= 1
    end

    -- proceed to phase 2 if the player has it unlocked
    -- initiatePhase2(plr)
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

Remotes.GameDev.CreateGame.Phase1.CheckInteraction.OnServerEvent:Connect(validatePhase1Input)

for _i, plr: Player in Players:GetPlayers() do
    plrsDeveloping[plr.UserId] = false
end

Players.PlayerAdded:Connect(function(plr: Player)
    plrsDeveloping[plr.UserId] = false
end)

Players.PlayerRemoving:Connect(function(plr: Player)
    plrsDeveloping[plr.UserId] = nil
end)