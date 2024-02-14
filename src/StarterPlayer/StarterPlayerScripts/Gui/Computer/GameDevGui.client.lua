local Lighting = game:GetService("Lighting")
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
local GenreTopicConfig = require(ReplicatedStorage.Configs.GameDev.GenreTopicConfig)
local GenreConfig = require(ReplicatedStorage.Configs.GameDev:WaitForChild("Genre"))
local TopicConfig = require(ReplicatedStorage.Configs.GameDev:WaitForChild("Topic"))
local StudioConfig = require(ReplicatedStorage.Configs.Studio:WaitForChild("Studio"))
local StaffMemberConfig = require(ReplicatedStorage.Configs.Staff:WaitForChild("StaffMember"))
local PlayerConfig = require(ReplicatedStorage.Configs:WaitForChild("Player"))
local PlayerUtils = require(ReplicatedStorage.Utils.Player:WaitForChild("Player"))
local ComputerConfig = require(ReplicatedStorage.Configs.GameDev:WaitForChild("Computer"))
local GamesConfig = require(ReplicatedStorage.Configs.GameDev.Games)
local FormatNumber = require(ReplicatedStorage.Libs:WaitForChild("FormatNumber").Simple)

local Remotes = ReplicatedStorage.Remotes

local localPlr = Players.LocalPlayer

local PlayerGui = localPlr.PlayerGui
local camera = Workspace:WaitForChild("Camera")

-- GUI REFERENCE VARIABLES --
-- IN-DEV GUI
local AllGuiScreenGui = PlayerGui:WaitForChild("AllGui")
local DevelopGameGui = AllGuiScreenGui.DevelopGame
local InDevGui = DevelopGameGui.InDev
---- phase intro
local PhaseIntroContainer = InDevGui.PhaseIntroContainer
local PhaseIntroBgGradient: UIGradient = PhaseIntroContainer.BackgroundGradient
local PhaseIntroHeaderContainer = PhaseIntroContainer.HeaderContainer
local PhaseIntroHeaderText = PhaseIntroHeaderContainer.Header
local PhaseIntroDescContainer = PhaseIntroContainer.DescContainer
local PhaseIntroDescText = PhaseIntroDescContainer.Desc
---- timer bar
local TimerBarContainer = InDevGui.TimerBarContainer
local TimerBarProg = TimerBarContainer.TimerBarProg
---- game points
local GamePtsContainer = InDevGui.GamePoints
local CodePtsAmt = GamePtsContainer.CodePts.PtsAmount
local SoundPtsAmt = GamePtsContainer.SoundPts.PtsAmount
local ArtPtsAmt = GamePtsContainer.ArtPts.PtsAmount
---- team members
local TeamMembersContainer = InDevGui.TeamMembers
local TeamMemberTemplate = TeamMembersContainer.Template
---- phase 1 btn container
local Phase1BtnContainer = InDevGui.Phase1Container
local BtnTemplatePc = Phase1BtnContainer.PcTemplate
local BtnTemplateMobile = Phase1BtnContainer.MobileTemplate
---- big fix phase
local BugFixPhaseContainer = InDevGui.BugFixPhaseContainer
local BugTemplate: ImageButton = BugFixPhaseContainer.BugTemplate
-- POST-DEV GUI
local PostDevGui = DevelopGameGui.PostDev
-- market game gui
local MarketGameContainer = PostDevGui.MarketGame
local MarketGameHeader = MarketGameContainer.MarketGameInner.Header
local MarketGameDeclineBtn = MarketGameContainer.MarketGameInner.DeclineBtn
local ReviewsPanel = MarketGameContainer.MarketGameInner.ReviewsPanel
local ReviewsContainer = ReviewsPanel.ReviewsContainer
local ReviewTemplate = ReviewsContainer.TemplateContainer
local MarketingPanel = MarketGameContainer.MarketGameInner.MarketingPanel
local MarketingOption1 = MarketingPanel.MarketingOptions.Friends
local MarketingOption2 = MarketingPanel.MarketingOptions.Newspaper
local MarketingOption3 = MarketingPanel.MarketingOptions.TV
-- game results gui
local GameResultsContainer = PostDevGui.GameResults
local GameInfoContainer = GameResultsContainer.GameResultsInner.GameInfoContainer
local GameInfoGameName = GameInfoContainer.GameName
local GameInfoCollectBtn = GameInfoContainer.CollectCoinsBtn
local GameInfoPanel = GameInfoContainer.GameInfo
---- game points
local GameInfoGamePtsContainer = GameInfoPanel.GamePoints
local GameInfoCodingPts = GameInfoGamePtsContainer.CodingPts.PtsAmt
local GameInfoSoundPts = GameInfoGamePtsContainer.SoundPts.PtsAmt
local GameInfoArtPts = GameInfoGamePtsContainer.ArtPts.PtsAmt
local PtsDistributionInfoContainer = GameInfoGamePtsContainer.PointsDistributionInfo
local PtsDistributionResult = PtsDistributionInfoContainer.Result
---- level bars
local GameInfoLevelBarsContainer = GameInfoPanel.LevelBars
local PlrLevelContainer = GameInfoLevelBarsContainer.PlrLevelContainer
local PlrLevelInfoText = PlrLevelContainer.InfoText
local PlrLevelBarContainer = PlrLevelContainer.LevelBarContainer
local PlrLevelText = PlrLevelBarContainer:FindFirstChild("LevelText", true)
local PlrLevelXp = PlrLevelBarContainer.LevelXP
local PlrLevelBarProg = PlrLevelBarContainer:FindFirstChild("LevelProg", true)

local GenreLevelContainer = GameInfoLevelBarsContainer.GenreLevelContainer
local GenreLevelInfoText = GenreLevelContainer.InfoText
local GenreLevelTrendingInfoContainer = GenreLevelContainer.TrendingInfo
local GenreLevelBarContainer = GenreLevelContainer.LevelBarContainer
local GenreLevelBarProg = GenreLevelBarContainer:FindFirstChild("LevelProg", true)
local GenreLevelText = GenreLevelBarContainer:FindFirstChild("LevelText", true)
local GenreLevelXp = GenreLevelBarContainer.LevelXP
local GenreTrendingIcon = GenreLevelBarContainer.TrendingIcon

local TopicLevelContainer = GameInfoLevelBarsContainer.TopicLevelContainer
local TopicLevelInfoText = TopicLevelContainer.InfoText
local TopicLevelTrendingInfoContainer = TopicLevelContainer.TrendingInfo
local TopicLevelBarContainer = TopicLevelContainer.LevelBarContainer
local TopicLevelBarProg = TopicLevelBarContainer:FindFirstChild("LevelProg", true)
local TopicLevelText = TopicLevelBarContainer:FindFirstChild("LevelText", true)
local TopicLevelXp = TopicLevelBarContainer.LevelXP
local TopicTrendingIcon = TopicLevelBarContainer.TrendingIcon

local GenreTopicCompatibilityContainer = GameInfoLevelBarsContainer.GenreTopicCompatibilityContainer

---- game sales graph
local GameSalesGraphPanel = GameResultsContainer.GameResultsInner.SalesGraphPanel
------ y-axis
local GameSalesAxisY = GameSalesGraphPanel.yAxis
local GamesSalesYAxisDataPts = GameSalesAxisY.yDataPoints
------ sales graph
local GamesSalesGraphContainer = GameSalesGraphPanel.SalesGraph
local GamesSalesGraphBars = GamesSalesGraphContainer.Bars

-- STATIC VARIABLES --
local RANDOM = Random.new()
local PHASE_1_PC_KEYS = Remotes.GameDev.CreateGame.GetPcPhase1BtnValues:InvokeServer()
local BUG_DEFAULT_IMAGE_ID = "16169807796"
local BUG_SQUASHED_IMAGE_ID = "16169809051"

-- -- styling static variables
local ENERGY_COLOURS = {
    NoEnergy = { Main = Color3.fromRGB(191, 191, 191), Prog = Color3.fromRGB(191, 191, 191) },
    LowEnergy = { Main = Color3.fromRGB(154, 84, 84), Prog = Color3.fromRGB(255, 139, 139) },
    MedEnergy = { Main = Color3.fromRGB(188, 164, 69), Prog = Color3.fromRGB(255, 231, 51) },
    HighEnergy = { Main = Color3.fromRGB(90, 162, 82), Prog = Color3.fromRGB(161, 255, 142) }
}
local BTN_STYLE_INFO = {
    ["pc"] = {
        ["Code"] = {
            ["Images"] = { Default = "16103019898", Bomb = "16102714079" },
            ["Colours"] = { Fill = Color3.fromRGB(123, 241, 91), Outline = Color3.fromRGB(74, 147, 61) }
        },
        ["Sound"] = {
            ["Images"] = { Default = "16103020629", Bomb = "16102479667" },
            ["Colours"] = { Fill = Color3.fromRGB(124, 205, 255), Outline = Color3.fromRGB(83, 138, 170) }
        },
        ["Art"] = {
            ["Images"] = { Default = "16103021581", Bomb = "16102481342" },
            ["Colours"] = { Fill = Color3.fromRGB(255, 174, 74), Outline = Color3.fromRGB(176, 104, 32) }
        }
    },
    ["mobile"] = {
        ["Code"] = {
            ["Images"] = { Default = "16102482196", Bomb = "16102482911" },
        },
        ["Sound"] = {
            ["Images"] = { Default = "16102483760", Bomb = "16102484802" },
        },
        ["Art"] = {
            ["Images"] = { Default = "16102486250", Bomb = "16102487404" },
        }
    }
}

-- STATE VARIABLES --
local plrData = nil
local plrPlatform = nil
local helpingStaffMembers = nil
local studioPcSetup: Model = nil
local pcSetupSeat: Seat = nil
-- -- developed game info
local developingGame: boolean = false
local developedGameInfo = nil
local levelUpInfo = {} -- holds genre, topic and player post-gamedev xp-adjustment info
-- -- connections
local userPcInputConnection: RBXScriptConnection | nil = nil
local bugIconTweens = {} -- { [bugID: string] = { MovementTween: Tween | nil, RotationTween: Tween | nil } }

GuiServices.StoreInCache(PhaseIntroHeaderContainer)
GuiServices.StoreInCache(PhaseIntroDescContainer)
GuiServices.StoreInCache(TeamMembersContainer)
GuiServices.StoreInCache(GamePtsContainer)
GuiServices.StoreInCache(TimerBarContainer)
GuiServices.StoreInCache(MarketGameContainer)
GuiServices.StoreInCache(GameResultsContainer)

GuiTemplates.PopText(CodePtsAmt, UDim2.fromScale(CodePtsAmt.Size.X.Scale, CodePtsAmt.Size.Y.Scale + 0.35))
GuiTemplates.PopText(SoundPtsAmt, UDim2.fromScale(CodePtsAmt.Size.X.Scale, CodePtsAmt.Size.Y.Scale + 0.35))
GuiTemplates.PopText(ArtPtsAmt, UDim2.fromScale(CodePtsAmt.Size.X.Scale, CodePtsAmt.Size.Y.Scale + 0.35))

local teamMembersContainerHiddenPos: UDim2 = GuiServices.DefaultMainGuiStyling(TeamMembersContainer, { PosX = -0.13, PosY = TeamMembersContainer.Position.Y.Scale})
local gamePtsContainerHiddenPos: UDim2 = GuiServices.DefaultMainGuiStyling(GamePtsContainer, { PosY = -0.01 })
local timerBarContainerHiddenPos: UDim2 = GuiServices.DefaultMainGuiStyling(TimerBarContainer, { PosY = -TimerBarContainer.Size.Y.Scale })
GuiServices.DefaultMainGuiStyling(MarketGameContainer)
GuiServices.DefaultMainGuiStyling(GameResultsContainer)

GuiTemplates.CreateButton(MarketingOption1)
GuiTemplates.CreateButton(MarketingOption2)
GuiTemplates.CreateButton(MarketingOption3)

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

local function clearStaffMemberContainer()
    local instancesToIgnore = {"UIListLayout", "Template"}
    for _i, instance in TeamMembersContainer:GetChildren() do
        if table.find(instancesToIgnore, instance.Name) then continue end

        instance:Destroy()
    end
end

local styleStaffMemberTemplate -- to hoist function

local function styleStaffMemberTemplateEnergyContainer(staffMemberUUID: string, staffMemberData: {})
    local staffMemberTemplate = TeamMembersContainer:FindFirstChild(staffMemberUUID)
    if not staffMemberTemplate then return end

    local energyContainer = staffMemberTemplate:FindFirstChild("EnergyContainer")
    local energyIcon: ImageLabel = energyContainer:FindFirstChild("EnergyIcon")
    local energyIconDropshadow: ImageLabel = energyIcon:FindFirstChild("EnergyIconDropshadow")
    local energyBarMain: Frame = energyContainer:FindFirstChild("EnergyBar")
    local energyBarProg: Frame = energyBarMain:FindFirstChild("EnergyProg")
    local energyBarUIStroke: UIStroke = energyBarMain:FindFirstChild("UIStroke")

    local staffMemberInstance: StaffMemberConfig.StaffMemberInstance = StaffMemberConfig.new(staffMemberUUID, staffMemberData)
    local currentEnergy = staffMemberData.CurrentEnergy
    local maxEnergy = staffMemberInstance:CalcMaxEnergy()
    local currEnergyProportion = currentEnergy / maxEnergy
    
    local colours
    if currEnergyProportion >= 0.66 then
        colours = ENERGY_COLOURS.HighEnergy
    elseif currEnergyProportion >= 0.33 then
        colours = ENERGY_COLOURS.MedEnergy
    elseif currEnergyProportion <= 0 then
        colours = ENERGY_COLOURS.NoEnergy
        energyIcon.Image = GeneralUtils.GetDecalUrl(GlobalVariables.Images.Icons.PlrEnergyGrayscaleIcon)
    else
        colours = ENERGY_COLOURS.LowEnergy
    end

    local tweenInfo = TweenInfo.new(0.5)
    -- only tween colours if the colour has actually changed
    if energyIconDropshadow.ImageColor3 ~= colours.Main then
        local iconDropshadowTween = TweenService:Create(energyIconDropshadow, tweenInfo, { ImageColor3 = colours.Main })
        local energyBarColourTween = TweenService:Create(energyBarMain, tweenInfo, { BackgroundColor3 = colours.Main })
        local energyBarProgColourTween = TweenService:Create(energyBarProg, tweenInfo, { BackgroundColor3 = colours.Prog })
        local energyBarUIStrokeTween = TweenService:Create(energyBarUIStroke, tweenInfo, { Color = colours.Main })
        iconDropshadowTween:Play()
        energyBarColourTween:Play()
        energyBarProgColourTween:Play()
        energyBarUIStrokeTween:Play()
    end

    -- tween bar movement
    local energyBarProgTween = TweenService:Create(energyBarProg, tweenInfo, { Size = UDim2.fromScale(currEnergyProportion, 1) })
    energyBarProgTween:Play()
end

styleStaffMemberTemplate = function(template: Frame, staffMemberUUID: string, staffMemberData: {})
    local templateUIStroke: UIStroke = template:FindFirstChild("UIStroke")
    local gradient: Frame = template:FindFirstChild("Gradient")
    local staffIcon: ImageLabel = template:FindFirstChild("StaffIcon")
    local staffIconDropshadow: ImageLabel = staffIcon:FindFirstChild("StaffIconDropshadow")

    local currentEnergy = staffMemberData.CurrentEnergy
    local noEnergyColour: Color3 = ENERGY_COLOURS.NoEnergy.Main

    local staffMemberConfig: StaffMemberConfig.StaffMemberConfig = StaffMemberConfig.GetConfig(staffMemberData.Model)
    local rarityColour: Color3 = GeneralConfig.GetRarityColour(staffMemberData.Rarity)
    
    staffIcon.Image = if currentEnergy <= 0 then GeneralUtils.GetDecalUrl(staffMemberConfig.IconGrayscale) else GeneralUtils.GetDecalUrl(staffMemberConfig.IconStroke)
    staffIconDropshadow.Image = GeneralUtils.GetDecalUrl(staffMemberConfig.IconFill)
    
    templateUIStroke.Color = if currentEnergy <= 0 then noEnergyColour else rarityColour
    gradient.BackgroundColor3 = if currentEnergy <= 0 then noEnergyColour else rarityColour
    staffIconDropshadow.ImageColor3 = if currentEnergy <= 0 then noEnergyColour else rarityColour

    styleStaffMemberTemplateEnergyContainer(staffMemberUUID, staffMemberData)
end

local function populateStaffMemberContainer()
    if not developingGame then return end

    for staffMemberUUID: string, staffMemberData in helpingStaffMembers do
        local template = TeamMemberTemplate:Clone()
        template.Parent = TeamMembersContainer
        template.Name = staffMemberUUID
        styleStaffMemberTemplate(template, staffMemberUUID, staffMemberData)
        template.Visible = true
    end
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

local function resetState()
    resetAllConnections({ userPcInputConnection })
    plrPlatform = nil
    helpingStaffMembers = nil
    studioPcSetup = nil
    pcSetupSeat = nil
    developedGameInfo = nil
    bugIconTweens = {}
    levelUpInfo = {}
end

local function setupPcUserInputConnection()
    if not developingGame then return end

    userPcInputConnection = UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
        if not processed then
            for _i, allowedKey in PHASE_1_PC_KEYS do
                if input.KeyCode == Enum.KeyCode[allowedKey] then
                    Remotes.GameDev.CreateGame.Phase1.ValidateInput:FireServer({ InputKeyCode = input.KeyCode })
                end
            end
        end
    end)
end

local function populateGameDevGui()
    if not developingGame then return end

    -- populate staff member container
    clearStaffMemberContainer()
    populateStaffMemberContainer()
    CodePtsAmt.Text = 0
    SoundPtsAmt.Text = 0
    ArtPtsAmt.Text = 0
end

local function toggleStaffMemberContainer(visible: boolean)
    if visible then
        local visiblePos = GuiServices.GetCachedData(TeamMembersContainer).Position
        if TeamMembersContainer.Position == visiblePos then return end -- already visible
        TeamMembersContainer.Visible = true
        TweenService:Create(TeamMembersContainer, TweenInfo.new(0.3), { Position = visiblePos }):Play()

    else
        if TeamMembersContainer.Position == teamMembersContainerHiddenPos then return end -- already hidden
        local tween = TweenService:Create(TeamMembersContainer, TweenInfo.new(0.3), { Position = teamMembersContainerHiddenPos })
        tween:Play()
        tween.Completed:Connect(function() TeamMembersContainer.Visible = false end)
    end
end

local function toggleGamePtsContainer(visible: boolean)
    if visible then
        local visiblePos = GuiServices.GetCachedData(GamePtsContainer).Position
        if GamePtsContainer.Position == visiblePos then return end -- already visible
        GamePtsContainer.Visible = true
        TweenService:Create(GamePtsContainer, TweenInfo.new(0.3), { Position = visiblePos }):Play()

    else
        if GamePtsContainer.Position == gamePtsContainerHiddenPos then return end -- already hidden
        local tween = TweenService:Create(GamePtsContainer, TweenInfo.new(0.3), { Position = gamePtsContainerHiddenPos })
        tween:Play()
        tween.Completed:Connect(function() GamePtsContainer.Visible = false end)
    end
end

local function toggleTimerBarContainer(visible: boolean)
    if visible then
        local visiblePos = GuiServices.GetCachedData(TimerBarContainer).Position
        if TimerBarContainer.Position == visiblePos then return end -- already visible
        TimerBarContainer.Visible = true
        TweenService:Create(TimerBarContainer, TweenInfo.new(0.3), { Position = visiblePos }):Play()

    else
        if TimerBarContainer.Position == timerBarContainerHiddenPos then return end -- already hidden
        local tween = TweenService:Create(TimerBarContainer, TweenInfo.new(0.3), { Position = timerBarContainerHiddenPos })
        tween:Play()
        tween.Completed:Connect(function() TimerBarContainer.Visible = false end)
    end
end

-- general gamedev gui to display across the different phases
-- opts
-- -- KeepHidden = { "StaffMember", "PhaseText", "GamePts", "TimerBar" }
local function showGameDevGui(opts: {})
    opts = opts or {}

    toggleStaffMemberContainer(if opts["KeepHidden"] and table.find(opts["KeepHidden"], "StaffMember") then false else true)
    toggleGamePtsContainer(if opts["KeepHidden"] and table.find(opts["KeepHidden"], "GamePts") then false else true)
    toggleTimerBarContainer(if opts["KeepHidden"] and table.find(opts["KeepHidden"], "TimerBar") then false else true)
end

-- opts
-- -- KeepVisible = { "StaffMember", "PhaseText", "GamePts", "TimerBar" }
local function hideGameDevGui(opts: {})
    opts = opts or {}

    toggleStaffMemberContainer(if opts["KeepVisible"] and table.find(opts["KeepVisible"], "StaffMember") then true else false)
    toggleGamePtsContainer(if opts["KeepVisible"] and table.find(opts["KeepVisible"], "GamePts") then true else false)
    toggleTimerBarContainer(if opts["KeepVisible"] and table.find(opts["KeepVisible"], "TimerBar") then true else false)
end

local function clearPhase1BtnContainer()
    local instancesToIgnore = {BtnTemplatePc, BtnTemplateMobile}
    for _i, instance in Phase1BtnContainer:GetChildren() do
        if table.find(instancesToIgnore, instance) then continue end

        instance:Destroy()
    end
end

local function clearBugPhaseContainer()
    local instancesToIgnore = {BugTemplate}
    for _i, instance in BugFixPhaseContainer:GetChildren() do
        if table.find(instancesToIgnore, instance) then continue end

        instance:Destroy()
    end
end

local function setupGameDevGui()
    if not developingGame then return end

    populateGameDevGui()
end

local function resetTimerBar(): Tween
    local tween = TweenService:Create(TimerBarProg, TweenInfo.new(TimerBarProg.Size.X.Scale * 0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Size = UDim2.fromScale(0, 1) })
    tween:Play()

    return tween
end

local function styleTimerBar()
    local xSizeScale: number = TimerBarProg.Size.X.Scale
    local colours -- timer bar uses same colours as staff members energy bar
    if xSizeScale >= 0.75 then
        colours = ENERGY_COLOURS.LowEnergy
    elseif xSizeScale >= 0.5 then
        colours = ENERGY_COLOURS.MedEnergy
    else
        colours = ENERGY_COLOURS.HighEnergy
    end

    TimerBarContainer.BackgroundColor3 = colours.Main
    TimerBarProg.BackgroundColor3 = colours.Prog
end

local function startTimerBar(time: number)
    if not developingGame then return end

    local timeLeft = time

    task.spawn(function()
        while timeLeft > 0 do
            if not developingGame then break end
            styleTimerBar()
            task.wait(1)
            timeLeft -= 1
        end
    end)
    if not developingGame then return end

    -- reset timer bar
    styleTimerBar()
    local resetTween = resetTimerBar()
    resetTween.Completed:Connect(function()
        local tween = TweenService:Create(TimerBarProg, TweenInfo.new(timeLeft, Enum.EasingStyle.Linear), { Size = UDim2.fromScale(1, 1) })
        tween:Play()
    end)
end

local function phase1StyleBtn(btn, btnType: "Code" | "Sound" | "Art" , isBomb: boolean)
    local defaultIcon: ImageLabel = btn:FindFirstChild("DefaultIcon")
    local bombIcon: ImageLabel = btn:FindFirstChild("BombIcon")
    defaultIcon.Visible = not isBomb
    bombIcon.Visible = isBomb

    local stylingInfo = BTN_STYLE_INFO[plrPlatform][btnType]
    if isBomb then bombIcon.Image = GeneralUtils.GetDecalUrl(stylingInfo.Images.Bomb) else defaultIcon.Image = GeneralUtils.GetDecalUrl(stylingInfo.Images.Default) end

    if plrPlatform == "pc" then
        local btnValueText: TextLabel = btn:FindFirstChild("BtnValue")
        local btnValueTextUIStroke: UIStroke = btnValueText:FindFirstChild("UIStroke")
        btnValueText.TextColor3 = stylingInfo.Colours.Fill
        btnValueTextUIStroke.Color = stylingInfo.Colours.Outline
    end
end

local function phase1DisplayBtn(isBomb: boolean, opts: {})
    if not developingGame then return end

    local template

    if plrPlatform == "pc" then
        local btnValue = opts["BtnValue"]
        template = BtnTemplatePc:Clone()
        template:FindFirstChild("BtnValue").Text = btnValue

    elseif plrPlatform == "mobile" then
        template = BtnTemplateMobile:Clone()
        template.Activated:Connect(function()
            Remotes.GameDev.CreateGame.Phase1.ValidateInput:FireServer({ BtnId = template.Name })
        end)
    end

    template.Position = UDim2.fromScale(RANDOM:NextNumber(0, 1), RANDOM:NextNumber(0, 1))

    local sizeTween = TweenService:Create(template, TweenInfo.new(0.3, Enum.EasingStyle.Elastic), { Size = template.Size })
    template.Size = UDim2.fromScale(0, 0)
    
    phase1StyleBtn(template, opts["BtnType"], isBomb)
    template.Parent = Phase1BtnContainer
    template.Name = opts["BtnId"]
    template.Visible = true

    sizeTween:Play()
end

local function phase1RemoveBtn(btnId: number, removeOnPlrInteraction: boolean, wasBomb: boolean)
    local btnInstance = Phase1BtnContainer:FindFirstChild(btnId)
    if not btnInstance then return end

    local hideTween: Tween
    if removeOnPlrInteraction then
        hideTween = TweenService:Create(btnInstance, TweenInfo.new(0.3), { Size = UDim2.fromScale(0.1, 0.1) })
        GuiServices.ChangeTransparency(btnInstance, 1, 0.3)
        GeneralUtils.PlaySfx(GlobalVariables.Sound.Sfx.GuiOpen)
        task.delay(0.3, function() btnInstance:Destroy() end)
    else
        hideTween = TweenService:Create(btnInstance, TweenInfo.new(0.15), { Size = UDim2.fromScale(0, 0) })
    end
    hideTween:Play()
    hideTween.Completed:Connect(function()
        btnInstance:Destroy()
    end)
end

local function removeBug(bugID: number, removeOnPlrInteraction: boolean)
    local bugTweenInfo = bugIconTweens[tostring(bugID)]
    if not bugTweenInfo then return end

    local bugImage = BugFixPhaseContainer:FindFirstChild(bugID)
    local removeBugTween = TweenService:Create(bugImage, TweenInfo.new(0.15), { Size = UDim2.fromScale(0, 0) })

    bugTweenInfo.MovementTween:Pause()
    bugTweenInfo.RotationTween:Pause()

    if removeOnPlrInteraction then
        bugImage.Image = GeneralUtils.GetDecalUrl(BUG_SQUASHED_IMAGE_ID)
        task.delay(2, function() removeBugTween:Play() end)

    else
        removeBugTween:Play()
    end

    removeBugTween.Completed:Connect(function()
        bugImage:Destroy()
        bugIconTweens[tostring(bugID)] = nil
    end)
end

local function calcBugEndPos(quadrant: string): UDim2
    if quadrant == "top-1" then
        local xPos = RANDOM:NextNumber(0.05, 1.5)
        local yPos = if xPos > 1.2 then RANDOM:NextNumber(0.2, 1.2) else 1.2
        return UDim2.fromScale(xPos, yPos)

    elseif quadrant == "top-2" then
        local xPos = RANDOM:NextNumber(-0.5, 0.95)
        local yPos = if xPos < -0.2 then RANDOM:NextNumber(0.2, 1.2) else 1.2
        return UDim2.fromScale(xPos, yPos)

    elseif quadrant == "bottom-3" then
        local xPos = RANDOM:NextNumber(0.05, 1.5)
        local yPos = if xPos > 1.2 then RANDOM:NextNumber(-0.2, 0.8) else -0.2
        return UDim2.fromScale(xPos, yPos)

    elseif quadrant == "bottom-4" then
        local xPos = RANDOM:NextNumber(-0.5, 0.95)
        local yPos = if xPos < -0.2 then RANDOM:NextNumber(-0.2, 0.8) else -0.2
        return UDim2.fromScale(xPos, yPos)

    elseif quadrant == "left-1" then
        local yPos = RANDOM:NextNumber(0.05, 1.4)
        local xPos = if yPos > 1.2 then RANDOM:NextNumber(0.05, 1.2) else 1.2
        return UDim2.fromScale(xPos, yPos)

    elseif quadrant == "left-3" then
        local yPos = RANDOM:NextNumber(-0.4, 0.95)
        local xPos = if yPos < -0.2 then RANDOM:NextNumber(0.05, 1.2) else 1.2
        return UDim2.fromScale(xPos, yPos)

    elseif quadrant == "right-2" then
        local yPos = RANDOM:NextNumber(0.05, 1.4)
        local xPos = if yPos > 1.2 then RANDOM:NextNumber(-0.2, 0.95) else -0.2
        return UDim2.fromScale(xPos, yPos)

    elseif quadrant == "right-4" then
        local yPos = RANDOM:NextNumber(-0.4, 0.95)
        local xPos = if yPos < -0.2 then RANDOM:NextNumber(-0.2, 0.95) else -0.2
        return UDim2.fromScale(xPos, yPos)
    end
end

local function calcBugStartPos(): { StartPos: UDim2, Quadrant: string }
    local randomNum = math.random()
    local info = {}
    if randomNum < 0.25 then
        -- bug starts along top of screen
        local xPos = RANDOM:NextNumber(-0.1, 1.1)
        info["StartPos"] = UDim2.fromScale(xPos, -0.2)
        info["Quadrant"] = if xPos <= 0.5 then "top-1" else "top-2"

    elseif randomNum < 0.5 then
        -- bug starts along bottom of screen
        local xPos = RANDOM:NextNumber(-0.1, 1.1)
        info["StartPos"] = UDim2.fromScale(xPos, 1.2)
        info["Quadrant"] = if xPos <= 0.5 then "bottom-3" else "bottom-4"

    elseif randomNum < 0.75 then
        -- bug starts along left-side of screen
        local yPos = RANDOM:NextNumber(-0.2, 1.2)
        info["StartPos"] = UDim2.fromScale(-0.1, yPos)
        info["Quadrant"] = if yPos <= 0.5 then "left-1" else "left-3"
    else
        -- bug starts along right-side of screen
        local yPos = RANDOM:NextNumber(-0.2, 1.2)
        info["StartPos"] = UDim2.fromScale(1.1, yPos)
        info["Quadrant"] = if yPos <= 0.5 then "right-2" else "right-4"
    end
    return info
end

-- function calculates the path of a bug image
local function calcBugMovementInfo(): {}
    local startPosInfo = calcBugStartPos()
    local startPos = startPosInfo.StartPos
    local quadrant = startPosInfo.Quadrant
    local endPos = calcBugEndPos(quadrant)

    local vector = GeneralUtils.GetVectorBetweenUDim2s(startPos, endPos)

    local rotationRadians = math.atan2(vector.Y, vector.X)
    local rotationDegrees = math.deg(rotationRadians)

    -- ensure that rotation is in the range [0, 360)
    rotationDegrees = ((rotationDegrees + 90) % 360 + 360) % 360

    return { StartPos = startPos, EndPos = endPos, Rotation = rotationDegrees }
end

local function spawnBug(bugId: number)
    if not developingGame then return end

    local template = BugTemplate:Clone()
    template.Parent = BugFixPhaseContainer
    template.Name = bugId
    template.Image = GeneralUtils.GetDecalUrl(BUG_DEFAULT_IMAGE_ID)
    
    local movementInfo = calcBugMovementInfo()
    template.Position = movementInfo.StartPos
    template.Rotation = movementInfo.Rotation
    
    local movementTween = TweenService:Create(template, TweenInfo.new(RANDOM:NextNumber(5, 10)), { Position = movementInfo.EndPos })
    movementTween:Play()
    
    template.Rotation -= 15
    local rotationTween = TweenService:Create(template, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), { Rotation = template.Rotation + 30 })
    rotationTween:Play()
    
    bugIconTweens[tostring(bugId)] = { MovementTween = movementTween, RotationTween = rotationTween }
    template.Visible = true
    
    local timeAlive = 0
    task.spawn(function()
        while BugFixPhaseContainer:FindFirstChild(bugId) do
            task.wait(1)
            timeAlive += 1
        end
    end)

    -- detection for border flash (dmg taken) effect
    local offScreen = false
    template:GetPropertyChangedSignal("Position"):Connect(function()
        if not offScreen and timeAlive > 2 and ((template.Position.X.Scale < 0 or template.Position.X.Scale > 1) or (template.Position.Y.Scale < 0 or template.Position.Y.Scale > 1)) then
            offScreen = true
            GuiServices.TriggerBorderFlash(GlobalVariables.Gui.BorderFlashDmgTaken)
        end
    end)

    -- squash bug
    template.Activated:Connect(function()
        Remotes.GameDev.CreateGame.BugFixPhase.SquashBug:FireServer(bugId, true)
    end)
end

local function resetPhaseIntro()
    PhaseIntroContainer.Visible = false
    PhaseIntroContainer.BackgroundTransparency = 1
    -- reset background uigradient
    PhaseIntroBgGradient.Rotation = -180
    -- reset text position
    local headerCache = GuiServices.GetCachedData(PhaseIntroHeaderContainer)
    local descCache = GuiServices.GetCachedData(PhaseIntroDescContainer)
    PhaseIntroHeaderContainer.Position = UDim2.fromScale(-headerCache.Size.X.Scale / 2, headerCache.Position.Y.Scale)
    PhaseIntroDescContainer.Position = UDim2.fromScale(1 + descCache.Size.X.Scale / 2, descCache.Position.Y.Scale)
end
resetPhaseIntro()

local function playPhaseIntro(phaseNumber: string)
    if not developingGame then return end

    resetPhaseIntro()
    hideGameDevGui()

    PhaseIntroContainer.Visible = true

    -- cached data
    local headerCache = GuiServices.GetCachedData(PhaseIntroHeaderContainer)
    local descCache = GuiServices.GetCachedData(PhaseIntroDescContainer)

    -- tweens
    local bgGradientRotateTween = TweenService:Create(PhaseIntroBgGradient, TweenInfo.new(4), { Rotation = 180 })
    local containerInTween = TweenService:Create(PhaseIntroContainer, TweenInfo.new(0.5), { BackgroundTransparency = 0.45 })
    local containerOutTween = TweenService:Create(PhaseIntroContainer, TweenInfo.new(0.5), { BackgroundTransparency = 1 })
    local headerInTween = TweenService:Create(PhaseIntroHeaderContainer, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Position = headerCache.Position })
    local descInTween = TweenService:Create(PhaseIntroDescContainer, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Position = descCache.Position })
    local headerOutTween = TweenService:Create(PhaseIntroHeaderContainer, TweenInfo.new(0.3), { Position = UDim2.fromScale(1 + headerCache.Position.X.Scale / 2, headerCache.Position.Y.Scale) })
    local descOutTween = TweenService:Create(PhaseIntroDescContainer, TweenInfo.new(0.3), { Position = UDim2.fromScale(-descCache.Position.X.Scale / 2, descCache.Position.Y.Scale) })

    if phaseNumber == "1" then
        PhaseIntroHeaderText.Text = "Develop"
        PhaseIntroDescText.Text = "Don't hit the bombs!"
    elseif phaseNumber == "2" then
        PhaseIntroHeaderText.Text = "Balancing"
        PhaseIntroDescText.Text = "Balance out the points!"
    elseif phaseNumber == "-1" then
        PhaseIntroHeaderText.Text = "Bug Fixing"
        PhaseIntroDescText.Text = "Squash the bugs!"
    elseif phaseNumber == "-99" then
        PhaseIntroHeaderText.Text = "Completed Development"
        PhaseIntroDescText.Text = "Adding finishing touches..."
    end

    bgGradientRotateTween:Play()
    containerInTween:Play()
    headerInTween:Play()
    GeneralUtils.PlaySfx(GlobalVariables.Sound.Sfx.SwooshFast)
    task.wait(1)
    descInTween:Play()
    GeneralUtils.PlaySfx(GlobalVariables.Sound.Sfx.SwooshFast)
    task.wait(3)
    containerOutTween:Play()
    headerOutTween:Play()
    descOutTween:Play()
    GeneralUtils.PlaySfx(GlobalVariables.Sound.Sfx.SwooshFast)

    headerOutTween.Completed:Connect(function()
        PhaseIntroContainer.Visible = false
    end)
end

local function displayStaffPtContribution(staffMemberUUID: string, ptsType: "Code" | "Sound" | "Art", contributedPts)
    local template = TeamMembersContainer:FindFirstChild(staffMemberUUID)
    if not template then return end

    local contributionContainer = template:FindFirstChild("ContributionContainer")
    local contributionText: TextLabel = contributionContainer:FindFirstChild("ContributionTemplate"):Clone()
    local contributionTextUIStroke: UIStroke = contributionText:FindFirstChild("UIStroke")
    
    contributionText.Parent = contributionContainer
    contributionText.Text = `{contributedPts < 0 and "-" or "+"}{FormatNumber.FormatCompact(math.abs(contributedPts))}`

    -- style text
    if ptsType == "Code" then
        contributionText.TextColor3 = Color3.fromRGB(123, 241, 91)
        contributionTextUIStroke.Color = Color3.fromRGB(74, 147, 61)
    elseif ptsType == "Sound" then
        contributionText.TextColor3 = Color3.fromRGB(124, 205, 255)
        contributionTextUIStroke.Color = Color3.fromRGB(83, 138, 170)
    elseif ptsType == "Art" then
        contributionText.TextColor3 = Color3.fromRGB(255, 174, 74)
        contributionTextUIStroke.Color = Color3.fromRGB(176, 104, 32)
    end

    contributionText.Visible = true

    -- tween text
    local tween = TweenService:Create(contributionText, TweenInfo.new(2), { Position = UDim2.fromScale(0.5, 0.273) })
    GuiServices.ChangeTransparency(contributionText, 1, 2)
    tween:Play()
    tween.Completed:Connect(function() contributionText:Destroy() end)
end

local function adjustGamePts(phaseNo: string, ptsType: "Code" | "Sound" | "Art", newPtAmt: number, pointsLost: boolean, opts: {})
    if not developingGame then return end

    if pointsLost then GuiServices.TriggerBorderFlash(GlobalVariables.Gui.BorderFlashDmgTaken) end

    if phaseNo == "1" then
        if ptsType == "Code" then CodePtsAmt.Text = FormatNumber.FormatCompact(newPtAmt) end
        if ptsType == "Sound" then SoundPtsAmt.Text = FormatNumber.FormatCompact(newPtAmt) end
        if ptsType == "Art" then ArtPtsAmt.Text = FormatNumber.FormatCompact(newPtAmt) end

        local staffMemberContributions = opts["StaffMemberContributions"].Individual
        for staffMemberUUID: string, contributedPts: number in staffMemberContributions do
            displayStaffPtContribution(staffMemberUUID, ptsType, contributedPts)
        end
    end
end

local function clearReviews()
    local instancesToIgnore = {"UIListLayout", "TemplateContainer"}
    for _i, v in ReviewsContainer:GetChildren() do
        if table.find(instancesToIgnore, v.Name) then continue end
        v:Destroy()
    end
end

local function styleReviewCard(templateNo: number, reviewTemplate: Frame, reviewData:  {})
    local reviewCardUIStroke: UIStroke = reviewTemplate:FindFirstChild("UIStroke")
    local reviewCardGradient: Frame = reviewTemplate:FindFirstChild("Gradient")
    local criticPhoto: ImageLabel = reviewTemplate:FindFirstChild("CriticPhoto")
    local criticReview: TextLabel = reviewTemplate:FindFirstChild("CriticReview")
    local ratingContainer: Frame = reviewTemplate:FindFirstChild("RatingContainer")

    criticPhoto.Image = GeneralUtils.GetDecalUrl(reviewData.AuthorImageID)
    criticPhoto.Rotation = if templateNo % 2 == 1 then -8 else 8

    criticReview.Text = `"{reviewData.Review}"`

    for i=1, reviewData.Stars do
        local star = ratingContainer:FindFirstChild(i)
        if reviewData.Stars == 1 or reviewData.Stars == 2 then star:FindFirstChild("StarIconDropshadow").ImageColor3 = Color3.fromRGB(255, 137, 137) end
        if reviewData.Stars == 3 then star:FindFirstChild("StarIconDropshadow").ImageColor3 = Color3.fromRGB(220, 167, 88) end
        if reviewData.Stars == 4 or reviewData.Stars == 5 then star:FindFirstChild("StarIconDropshadow").ImageColor3 = Color3.fromRGB(136, 208, 125) end
        
        star.Visible = true
    end

    if reviewData.Stars == 1 or reviewData.Stars == 2 then
        reviewCardUIStroke.Color = Color3.fromRGB(255, 137, 137)
        reviewCardGradient.BackgroundColor3 = Color3.fromRGB(255, 137, 137)

    elseif reviewData.Stars == 3 then
        reviewCardUIStroke.Color = Color3.fromRGB(220, 167, 88)
        reviewCardGradient.BackgroundColor3 = Color3.fromRGB(255, 196, 102)
    
    elseif reviewData.Stars == 4 or reviewData.Stars == 5 then
        reviewCardUIStroke.Color = Color3.fromRGB(136, 208, 125)
        reviewCardGradient.BackgroundColor3 = Color3.fromRGB(151, 231, 139)
    
    end
end

local function displayMarketingGui()
    if not developingGame then return end

    local reviews = developedGameInfo.GameResults.Reviews
    clearReviews()

    hideGameDevGui()
    GuiServices.ShowGuiStandard(MarketGameContainer)

    for i = 1, #reviews, 1 do
        local reviewData = reviews[i]

        local reviewTemplateContainer = ReviewTemplate:Clone()
        reviewTemplateContainer.Parent = ReviewsContainer
        reviewTemplateContainer.Name = i
        local reviewTemplate = reviewTemplateContainer:FindFirstChild("Template")

        local finalPos = reviewTemplate.Position
        local startPos = UDim2.fromScale(-reviewTemplate.Size.X.Scale / 2, finalPos.Y.Scale)
        reviewTemplate.Position = startPos
        local movementTween = TweenService:Create(reviewTemplate, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Position = finalPos })

        styleReviewCard(i, reviewTemplate, reviewData)

        reviewTemplateContainer.Visible = true
        movementTween:Play()
        GeneralUtils.PlaySfx(GlobalVariables.Sound.Sfx.SwooshSlow)
        task.wait(0.5)
    end
end

local function playGameSalesChartAnimation(): Tween
    if not developingGame then return end

    -- reset graph to its defaults
    GameSalesGraphPanel.Position = UDim2.fromScale(0, 0)
    GameSalesGraphPanel.Size = UDim2.fromScale(0.9, 0.9)
    for _i, v: Frame in GamesSalesGraphBars:GetChildren() do
        if v.Name == "UIListLayout" then continue end
        v.Size = UDim2.fromScale(0.2, 0)
    end

    -- get sale increment values
    -- e.g. ([1] = 500,000, [2] = 1,000,000, [3] = 1,500,000 , [4] = 2,000,000)
    local saleIncrementValues = {
        developedGameInfo.GameResults.GameSales.Total / 8,
        developedGameInfo.GameResults.GameSales.Total / 4,
        developedGameInfo.GameResults.GameSales.Total / 2.67,
        developedGameInfo.GameResults.GameSales.Total / 2,
    }
    
    for _i, dataPtNo: Frame in GamesSalesYAxisDataPts:GetChildren() do
        local salesAmt: TextLabel = dataPtNo:FindFirstChild("SalesAmt")
        if dataPtNo.Name == "1" then
            salesAmt.Text = FormatNumber.FormatCompact(GeneralUtils.RoundToDp(saleIncrementValues[1], 1))
        elseif dataPtNo.Name == "2" then
            salesAmt.Text = FormatNumber.FormatCompact(GeneralUtils.RoundToDp(saleIncrementValues[2], 1))
        elseif dataPtNo.Name == "3" then
            salesAmt.Text = FormatNumber.FormatCompact(GeneralUtils.RoundToDp(saleIncrementValues[3], 1))
        elseif dataPtNo.Name == "4" then
            salesAmt.Text = FormatNumber.FormatCompact(GeneralUtils.RoundToDp(saleIncrementValues[4], 1))
        end
    end

    -- play bar chart animations
    local showChartTween = TweenService:Create(GameSalesGraphPanel, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Position = UDim2.fromScale(0.5, 0.5) })
    showChartTween:Play()
    
    local barTweenInfo: TweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    local maxBarHeightInSales: number = developedGameInfo.GameResults.GameSales.Total / 2 -- the max sales a bar can display (half of the total game sales)
    local tweenToReturn: Tween
    for _i, v in GamesSalesGraphBars:GetChildren() do
        if v.Name == "UIListLayout" then continue end

        task.wait(0.4) -- wait before playing next bar tween

        local tween = TweenService:Create(v, barTweenInfo, {
            Size = UDim2.fromScale(0.2, developedGameInfo.GameResults.GameSales.Weekly[tonumber(v.Name)] / maxBarHeightInSales)
        })
        tween:Play()
        GeneralUtils.PlaySfx(GlobalVariables.Sound.Sfx.SwooshSlow)

        if v.Name == "4" then tweenToReturn = tween end
    end
    
    return tweenToReturn
end

local function populateGameInfoContainer()
    if not developingGame then return end

    GameInfoGameName.Text = developedGameInfo.Name
    -- pts info
    GameInfoCodingPts.Text = FormatNumber.FormatCompact(developedGameInfo.GamePoints.Code)
    GameInfoSoundPts.Text = FormatNumber.FormatCompact(developedGameInfo.GamePoints.Sound)
    GameInfoArtPts.Text = FormatNumber.FormatCompact(developedGameInfo.GamePoints.Art)
    PtsDistributionInfoContainer.Visible = developedGameInfo.GameResults.PointsDistribution == "Uneven"
    if developedGameInfo.GameResults.PointsDistribution == "Uneven" then
        PtsDistributionResult.Text = "UNEVEN Point Distribution"
        PtsDistributionResult.TextColor3 = GlobalVariables.Gui.InvalidRedColour
    end

    -- genre & topic info
    GenreTopicCompatibilityContainer.Visible = developedGameInfo.GameResults.GenreTopicRelationship ~= "Neutral"

    if developedGameInfo.GameResults.GenreTopicRelationship ~= "Neutral" then
        local compatibilityInfoText: TextLabel = GenreTopicCompatibilityContainer:FindFirstChild("Result")
        local compatibilityBonusText: TextLabel = GenreTopicCompatibilityContainer:FindFirstChild("BonusText")

        if developedGameInfo.GameResults.GenreTopicRelationship == "Compatible" then
            compatibilityInfoText.Text = "COMPATIBLE Genre & Topic"
            compatibilityBonusText.Text = "+10%"
        elseif developedGameInfo.GameResults.GenreTopicRelationship == "Incompatible" then
            compatibilityInfoText.Text = "INCOMPATIBLE Genre & Topic"
            compatibilityBonusText.Text = "-10%"
        end
    end

    
    GenreLevelTrendingInfoContainer.Visible = developedGameInfo.GameResults.GenreTrending
    TopicLevelTrendingInfoContainer.Visible = developedGameInfo.GameResults.TopicTrending
    GenreTrendingIcon.Visible = developedGameInfo.GameResults.GenreTrending
    TopicTrendingIcon.Visible = developedGameInfo.GameResults.TopicTrending

    GenreLevelInfoText.Text = `GENRE: {developedGameInfo.Genre} {levelUpInfo["Genre"].PreAdjustmentLevel ~= levelUpInfo["Genre"].PostAdjustmentLevel and "(LEVEL UP!)" or "" }`
    TopicLevelInfoText.Text = `TOPIC: {developedGameInfo.Topic} {levelUpInfo["Topic"].PreAdjustmentLevel ~= levelUpInfo["Topic"].PostAdjustmentLevel and "(LEVEL UP!)" or "" }`

    -- plr level bar info
    PlrLevelInfoText.Text = `Player Level {levelUpInfo["Player"].PreAdjustmentLevel ~= levelUpInfo["Player"].PostAdjustmentLevel and "(LEVEL UP!)" or "" }`
end

local function displayGameInfoGui()
    if not developingGame then return end

    -- reset game info container position
    GameInfoContainer.Position = UDim2.fromScale(1, 0)
    GameInfoContainer.Visible = false
    -- reset collect btn position
    GameInfoCollectBtn.Position = UDim2.fromScale(GameInfoCollectBtn.Position.X.Scale, GameInfoCollectBtn.Position.Y.Scale + 0.2)

    -- opening the game results gui will automatically hide the game marketing gui
    GuiServices.ShowGuiStandard(GameResultsContainer)
    
    -- play game sales chart animation
    local finalTween = playGameSalesChartAnimation()
    
    finalTween.Completed:Connect(function()
        if not developingGame then return end

        populateGameInfoContainer()
        GuiServices.SetLevelBar(GenreLevelBarProg, GenreLevelText, GenreLevelXp, levelUpInfo["Genre"].PreAdjustmentLevel, levelUpInfo["Genre"].PreAdjustmentXP, levelUpInfo["Genre"].PreAdjustmentMaxXP)
        GuiServices.SetLevelBar(TopicLevelBarProg, TopicLevelText, TopicLevelXp, levelUpInfo["Topic"].PreAdjustmentLevel, levelUpInfo["Topic"].PreAdjustmentXP, levelUpInfo["Topic"].PreAdjustmentMaxXP)
        GuiServices.SetLevelBar(PlrLevelBarProg, PlrLevelText, PlrLevelXp, levelUpInfo["Player"].PreAdjustmentLevel, levelUpInfo["Player"].PreAdjustmentXP, levelUpInfo["Player"].PreAdjustmentMaxXP)
        task.wait(1)
        GameInfoContainer.Visible = true

        local moveGraphTween = TweenService:Create(GameSalesGraphPanel, TweenInfo.new(0.5), { Position = UDim2.fromScale(0.164, 0.648), Size = UDim2.fromScale(0.6, 0.6) })
        moveGraphTween:Play()

        local showGameInfoTween = TweenService:Create(GameInfoContainer, TweenInfo.new(0.5), { Position = UDim2.fromScale(0, 0) })
        showGameInfoTween:Play()
        GeneralUtils.PlaySfx(GlobalVariables.Sound.Sfx.SwooshSlow)

        showGameInfoTween.Completed:Wait()

        GuiServices.TweenProgBar(GenreLevelBarProg, GenreLevelText, GenreLevelXp, levelUpInfo["Genre"].PreAdjustmentLevel, levelUpInfo["Genre"].PostAdjustmentLevel, levelUpInfo["Genre"].PostAdjustmentXP, levelUpInfo["Genre"].PostAdjustmentMaxXP)
        GuiServices.TweenProgBar(TopicLevelBarProg, TopicLevelText, TopicLevelXp, levelUpInfo["Topic"].PreAdjustmentLevel, levelUpInfo["Topic"].PostAdjustmentLevel, levelUpInfo["Topic"].PostAdjustmentXP, levelUpInfo["Topic"].PostAdjustmentMaxXP)
        local plrBarTween = GuiServices.TweenProgBar(PlrLevelBarProg, PlrLevelText, PlrLevelXp, levelUpInfo["Player"].PreAdjustmentLevel, levelUpInfo["Player"].PostAdjustmentLevel, levelUpInfo["Player"].PostAdjustmentXP, levelUpInfo["Player"].PostAdjustmentMaxXP)
        local collectBtnTween = TweenService:Create(GameInfoCollectBtn, TweenInfo.new(0.3), { Position = UDim2.fromScale(GameInfoCollectBtn.Position.X.Scale, GameInfoCollectBtn.Position.Y.Scale - 0.2) })
        
        GameInfoCollectBtn:FindFirstChild("CollectText").Text = `COLLECT {FormatNumber.FormatCompact(developedGameInfo.GameResults.Earnings)}`

        plrBarTween.Completed:Connect(function() collectBtnTween:Play() end)
    end)
end

-- BTN ACTIVATIONS --
MarketGameDeclineBtn.Activated:Connect(function()
    displayGameInfoGui()
end)

GameInfoCollectBtn.Activated:Connect(function()
    Remotes.GameDev.CreateGame.EndGameDevelopment:FireServer()
end)

-- REMOTES --
Remotes.GameDev.CreateGame.DevelopGame.OnClientEvent:Connect(function()
    developingGame = true

    plrData = Remotes.Data.GetAllData:InvokeServer()
    plrPlatform = Remotes.Player.GetPlrPlatformData:InvokeServer().Platform
    helpingStaffMembers = StudioConfig.GetStaffInActiveStudio(plrData)
    setup()
end)

Remotes.GameDev.CreateGame.StartPhase.OnClientEvent:Connect(function(phase: number, _gameStateInfo)
    if not developingGame then return end

    if phase == 1 then
        setupGameDevGui()
        clearPhase1BtnContainer()
        showGameDevGui()

        if plrPlatform == "pc" then
            setupPcUserInputConnection()
        end

    elseif phase == 2 then
        showGameDevGui({ KeepHidden = {"StaffMember, TimerBar"} })

    -- bug fix phase
    elseif phase == -1 then
        clearBugPhaseContainer()
        showGameDevGui({ KeepHidden = {"StaffMember"} })
    end

    Phase1BtnContainer.Visible = phase == 1
    BugFixPhaseContainer.Visible = phase == -1
end)

Remotes.Staff.AdjustEnergy.OnClientEvent:Connect(function(staffMemberUUID: string, staffMemberData: {})
    if helpingStaffMembers and helpingStaffMembers[staffMemberUUID] then
        -- if energy <= 0, style template only (which also styles energy bar)
        -- else style energy bar only
        if staffMemberData.CurrentEnergy <= 0 then
            local template = TeamMembersContainer:FindFirstChild(staffMemberUUID)
            if not template then return end
            styleStaffMemberTemplate(template, staffMemberUUID, staffMemberData)
    
        else
            styleStaffMemberTemplateEnergyContainer(staffMemberUUID, staffMemberData)
        end
    end
end)

Remotes.GUI.GameDev.DisplayPhaseIntro.OnClientEvent:Connect(playPhaseIntro)

Remotes.GameDev.CreateGame.AdjustGamePoints.OnClientEvent:Connect(adjustGamePts)

-- phase 1 btn remotes
Remotes.GameDev.CreateGame.Phase1.SendBtn.OnClientEvent:Connect(phase1DisplayBtn)
Remotes.GameDev.CreateGame.Phase1.RemoveBtn.OnClientEvent:Connect(phase1RemoveBtn)

-- bug fix phase remotes
Remotes.GameDev.CreateGame.BugFixPhase.SendBug.OnClientEvent:Connect(spawnBug)
Remotes.GameDev.CreateGame.BugFixPhase.SquashBug.OnClientEvent:Connect(removeBug)

Remotes.GUI.GameDev.StartTimerBar.OnClientEvent:Connect(startTimerBar)

Remotes.GUI.GameDev.DisplayMarketingGui.OnClientEvent:Connect(function(gameStateInfo: {})
    developedGameInfo = gameStateInfo
    displayMarketingGui()
end)

Remotes.GameDev.GenreTopic.AdjustGenreXP.OnClientEvent:Connect(function(_genreData, _genreInstance, adjustmentInfo)
    levelUpInfo["Genre"] = adjustmentInfo
end)

Remotes.GameDev.GenreTopic.AdjustTopicXP.OnClientEvent:Connect(function(_topicData, _topicInstance, adjustmentInfo)
    levelUpInfo["Topic"] = adjustmentInfo
end)

Remotes.Character.AdjustPlrXP.OnClientEvent:Connect(function(_plrCharacterData, adjustmentInfo)
    levelUpInfo["Player"] = adjustmentInfo
end)

-- forceEnded -> boolean: is true if player resets mid-game dev
Remotes.GameDev.CreateGame.EndGameDevelopment.OnClientEvent:Connect(function(forceEnded: true)
    developingGame = false
    resetState()

    -- if forceEnded, then plr reset
    if forceEnded then
        hideGameDevGui()
        BugFixPhaseContainer.Visible = false
        Phase1BtnContainer.Visible = false
        PhaseIntroContainer.Visible = false
    
    else
        GuiServices.HideGuiStandard(GameResultsContainer)
        GuiServices.ShowHUD()

        studioPcSetup = Workspace.TempAssets.Studios:FindFirstChild("Computer", true)
        CameraControls.SetDefault(localPlr, camera, true)
        GeneralUtils.ShowModel(studioPcSetup:FindFirstChild("Pc"), { Tween = true })
        PlayerUtils.UnseatPlayer(localPlr)

        Remotes.Studio.General.EnableInteractionBtns:Fire()
    end
end)
