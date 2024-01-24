local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local GeneralUtils = require(ReplicatedStorage.Utils:WaitForChild("GeneralUtils"))
local GeneralConfig = require(ReplicatedStorage.Configs:WaitForChild("General"))
local GlobalVariables = require(ReplicatedStorage:WaitForChild("GlobalVariables"))
local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))
local GuiTemplates = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiTemplates"))
local PlayerServices = require(ReplicatedStorage.Utils.Player:WaitForChild("Player"))
local CameraControls = require(ReplicatedStorage.Utils.Camera:WaitForChild("CameraControls"))
local GenreConfig = require(ReplicatedStorage.Configs.GameDev:WaitForChild("Genre"))
local TopicConfig = require(ReplicatedStorage.Configs.GameDev:WaitForChild("Topic"))
local StudioConfig = require(ReplicatedStorage.Configs.Studio:WaitForChild("Studio"))
local StaffMemberConfig = require(ReplicatedStorage.Configs.Staff:WaitForChild("StaffMember"))
local PlayerConfig = require(ReplicatedStorage.Configs:WaitForChild("Player"))
local PlayerUtils = require(ReplicatedStorage.Utils.Player:WaitForChild("Player"))
local ComputerConfig = require(ReplicatedStorage.Configs.GameDev:WaitForChild("Computer"))
local FormatNumber = require(ReplicatedStorage.Libs:WaitForChild("FormatNumber").Simple)

local Remotes = ReplicatedStorage.Remotes

local localPlr = Players.LocalPlayer

local PlayerGui = localPlr.PlayerGui
local camera = Workspace:WaitForChild("Camera")

-- GUI REFERENCE VARIABLES --
local AllGuiScreenGui = PlayerGui:WaitForChild("AllGui")
local DevelopGameGui = AllGuiScreenGui.DevelopGame
-- countdown text
local CountdownTextContainer = DevelopGameGui:WaitForChild("CountdownTextContainer")
local CountdownText = CountdownTextContainer.CountdownText
-- timer bar
local TimerBarContainer = DevelopGameGui.TimerBarContainer
local TimerBarProg = TimerBarContainer.TimerBarProg
-- game points
local GamePtsContainer = DevelopGameGui.GamePoints
local CodePtsAmt =GamePtsContainer.CodePts.PtsAmount
local SoundPtsAmt =GamePtsContainer.SoundPts.PtsAmount
local ArtPtsAmt =GamePtsContainer.ArtPts.PtsAmount
-- team members
local TeamMembersContainer = DevelopGameGui.TeamMembers
local TeamMemberTemplate = TeamMembersContainer.Template
-- phase 1 btn container
local Phase1BtnContainer = DevelopGameGui.Phase1Container
local BtnTemplatePc = Phase1BtnContainer.PcTemplate
local BtnTemplateMobile = Phase1BtnContainer.MobileTemplate

-- STATIC VARIABLES --
local PHASE_1_PC_KEYS = Remotes.GameDev.CreateGame.GetPcPhase1BtnValues:InvokeServer()
local COUNTDOWN_TEXT = "Start in... TIME_LEFT"

-- STATE VARIABLES --
local plrData = nil
local plrPlatform = nil
local studioPcSetup: Model = nil
local pcSetupSeat: Seat = nil
-- -- connections
local userPcInputConnection: RBXScriptConnection | nil = nil

GuiServices.StoreInCache(CountdownTextContainer)
GuiServices.StoreInCache(TeamMembersContainer)
GuiServices.StoreInCache(GamePtsContainer)
GuiServices.StoreInCache(TimerBarContainer)

GuiServices.DefaultMainGuiStyling(CountdownTextContainer, { PosY = -CountdownTextContainer.Size.Y.Scale })
local teamMembersContainerHiddenPos: UDim2 = GuiServices.DefaultMainGuiStyling(TeamMembersContainer, { PosX = -0.13, PosY = TeamMembersContainer.Position.Y.Scale})
local gamePtsContainerHiddenPos: UDim2 = GuiServices.DefaultMainGuiStyling(GamePtsContainer, { PosY = -0.01 })
local timerBarContainerContainerHiddenPos: UDim2 = GuiServices.DefaultMainGuiStyling(TimerBarContainer, { PosY = -TimerBarContainer.Size.Y.Scale })

local function setup()
    studioPcSetup = Workspace.TempAssets.Studios:FindFirstChild("Computer", true)
    pcSetupSeat = studioPcSetup:FindFirstChild("Seat", true)
    local cameraPosPart = studioPcSetup:FindFirstChild("CameraPosPartDev")
    local cameraLookAtPart = studioPcSetup:FindFirstChild("CameraLookAtPartDev")

    CameraControls.FocusOnObject(localPlr, camera, cameraPosPart.Position, cameraLookAtPart.Position, true, true)
    GeneralUtils.HideModel(studioPcSetup:FindFirstChild("Pc"), { Tween = true })
    PlayerServices.ShowPlayer(localPlr, true)
    PlayerUtils.SeatPlayer(localPlr, pcSetupSeat)
end

local function resetConnection(connection: RBXScriptConnection)
    if connection then connection:Disconnect() end
    connection = nil
end

local function resetAllConnections(allConnections: {})
    for _i, v: RBXScriptConnection | nil in allConnections do
        resetConnection(v)
    end
end

local function setupPcUserInputConnection()
    userPcInputConnection = UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
        if not processed then
            for _i, allowedKey in PHASE_1_PC_KEYS do
                if input.KeyCode == Enum.KeyCode[allowedKey] then
                    print('sent')
                    Remotes.GameDev.CreateGame.Phase1.CheckInteraction:FireServer({ InputKeyCode = input.KeyCode })
                end
            end
        end
    end)
end

local function showCountdownText()
    CountdownTextContainer.Visible = true
    local visiblePos = GuiServices.GetCachedData(CountdownTextContainer).Position
    local showTween = TweenService:Create(CountdownTextContainer, TweenInfo.new(0.8, Enum.EasingStyle.Elastic), { Position = visiblePos })
    showTween:Play()
end

local function hideCountdownText()
    local countdownTextVisiblePos = GuiServices.GetCachedData(CountdownTextContainer).Position
    local hideTween = TweenService:Create(CountdownTextContainer, TweenInfo.new(0.4), { Position = UDim2.fromScale(countdownTextVisiblePos.X.Scale, 0) })
    hideTween:Play()
    hideTween.Completed:Connect(function() CountdownTextContainer.Visible = false end)
end

local function populateGameDevGui()
    
end

-- general gamedev gui to display across the different phases
local function showGameDevGui()
    local instancesToShow = {TeamMembersContainer, GamePtsContainer, TimerBarContainer}
    for _i, v in instancesToShow do
        local visiblePos = GuiServices.GetCachedData(v).Position
        v.Visible = true
        TweenService:Create(v, TweenInfo.new(0.3), { Position = visiblePos }):Play()
    end
end

local function hideGameDevGui()
    local instancesToHide = {[TeamMembersContainer.Name] = teamMembersContainerHiddenPos,
            [GamePtsContainer.Name] = gamePtsContainerHiddenPos,
            [TimerBarContainer.Name] = timerBarContainerContainerHiddenPos}

    for instanceName, hiddenPos in instancesToHide do
        local instance = DevelopGameGui:FindFirstChild(instanceName, true)
        instance.Visible = true
        TweenService:Create(instance, TweenInfo.new(0.3), { Position = hiddenPos }):Play()
    end
end

local function clearPhase1BtnContainer()
    local instancesToIgnore = {BtnTemplatePc, BtnTemplateMobile}
    for _i, instance in Phase1BtnContainer:GetChildren() do
        if table.find(instancesToIgnore, instance) then continue end

        instance:Destroy()
    end
end

local function setupGameDevGui()
    populateGameDevGui()
    clearPhase1BtnContainer()

    Phase1BtnContainer.Visible = true
    showGameDevGui()
end

local function phase1StyleBtn(btn, isBomb: boolean)
    local btnUIStroke: UIStroke = btn:FindFirstChild("UIStroke")

    -- universal styling
    if isBomb then
        btnUIStroke.Color = Color3.fromRGB(255, 172, 88)
    else
        btnUIStroke.Color = Color3.fromRGB(89, 181, 97)
    end

    -- platform specific styling
    if plrPlatform == "pc" then
        local inputText: TextLabel = btn:FindFirstChild("InputText")
        local inputTextUIStroke: UIStroke = inputText:FindFirstChild("UIStroke")
        if isBomb then
            inputText.TextColor3 = Color3.fromRGB(255, 229, 133)
            inputTextUIStroke.Color = Color3.fromRGB(255, 172, 88)
        else
            inputText.TextColor3 = Color3.fromRGB(126, 255, 137)
            inputTextUIStroke.Color = Color3.fromRGB(89, 181, 97)
        end

    elseif plrPlatform == "mobile" then
        local bombIcon: ImageLabel = btn:FindFirstChild("BombIcon")
        local bombIconDropshadow: ImageLabel = bombIcon:FindFirstChild("BombIconDropshadow")
        local clickIcon: ImageLabel = btn:FindFirstChild("ClickIcon")
        local clickIconDropshadow: ImageLabel = clickIcon:FindFirstChild("ClickIconDropshadow")
        if isBomb then
            bombIcon.Visible = true
            bombIcon.ImageColor3 = Color3.fromRGB(255, 229, 133)
            bombIconDropshadow.ImageColor3 = Color3.fromRGB(255, 172, 88)
        else
            clickIcon.Visible = true
            clickIcon.ImageColor3 = Color3.fromRGB(126, 255, 137)
            clickIconDropshadow.ImageColor3 = Color3.fromRGB(89, 181, 97)
        end
    end
end

local function phase1DisplayBtn(isBomb: boolean, opts: {})
    local template

    if plrPlatform == "pc" then
        template = BtnTemplatePc:Clone()
        local btnValue = opts["BtnValue"]
        template:FindFirstChild("InputText").Text = btnValue

    elseif plrPlatform == "mobile" then
        template = BtnTemplateMobile:Clone()
        template.Activated:Connect(function()
            Remotes.GameDev.CreateGame.Phase1.CheckInteraction:FireServer({ BtnId = template.Name })
        end)
    end

    local random = Random.new()
    template.Position = UDim2.fromScale(random:NextNumber(0, 1), random:NextNumber(0, 1))

    local sizeTween = TweenService:Create(template, TweenInfo.new(0.3, Enum.EasingStyle.Elastic), { Size = template.Size })
    template.Size = UDim2.fromScale(0, 0)
    
    phase1StyleBtn(template, isBomb)
    template.Parent = Phase1BtnContainer
    template.Name = opts["BtnId"]
    template.Visible = true

    sizeTween:Play()
end

local function phase1RemoveBtn(btnId: number, removeOnPlrInteraction: boolean)
    
end

-- REMOTES --
Remotes.GameDev.CreateGame.DevelopGame.OnClientEvent:Connect(function()
    plrData = Remotes.Data.GetAllData:InvokeServer()
    plrPlatform = Remotes.Player.GetPlrPlatformData:InvokeServer().Platform
    setup()
end)

-- phase 0 timer remotes
local countdownLoopSfx: Sound = GlobalVariables.Sound.Sfx.CountdownLoop
local countdownEndSfx: Sound = GlobalVariables.Sound.Sfx.CountdownEnd
Remotes.GUI.GameDev.DisplayTimerText.OnClientEvent:Connect(function(secLeft: number)
    GeneralUtils.PlaySfx(countdownLoopSfx)
    CountdownText.Text = COUNTDOWN_TEXT:gsub("TIME_LEFT", tostring(secLeft))
    showCountdownText()

    -- timer sfx
    task.spawn(function()
        local sfx: Sound
        while secLeft >= 1 do
            GeneralUtils.PlaySfx(countdownLoopSfx)
            task.wait(1)
            secLeft -= 1
        end
        GeneralUtils.PlaySfx(countdownEndSfx)
    end)
end)
Remotes.GUI.GameDev.UpdateTimerText.OnClientEvent:Connect(function(secLeft: number)
    CountdownText.Text = COUNTDOWN_TEXT:gsub("TIME_LEFT", tostring(secLeft))
end)

Remotes.GameDev.CreateGame.StartPhase.OnClientEvent:Connect(function(phase: number)
    if phase == 1 then
        hideCountdownText()
        setupGameDevGui()

        if plrPlatform == "pc" then
            setupPcUserInputConnection()
        end
    end
end)

Remotes.GameDev.CreateGame.Phase1.SendBtn.OnClientEvent:Connect(phase1DisplayBtn)

Remotes.GameDev.CreateGame.Phase1.RemoveBtn.OnClientEvent:Connect(phase1RemoveBtn)