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
-- phase number text
local PhaseNumberText = DevelopGameGui.PhaseNumber
-- countdown text
local CountdownTextContainer = DevelopGameGui.CountdownTextContainer
local CountdownText = CountdownTextContainer.CountdownText
-- timer bar
local TimerBarContainer = DevelopGameGui.TimerBarContainer
local TimerBarProg = TimerBarContainer.TimerBarProg
-- game points
local GamePtsContainer = DevelopGameGui.GamePoints
local CodePtsAmt = GamePtsContainer.CodePts.PtsAmount
local SoundPtsAmt = GamePtsContainer.SoundPts.PtsAmount
local ArtPtsAmt = GamePtsContainer.ArtPts.PtsAmount
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
local PHASE_INDICATOR_TEXT = "PHASE - PHASE_NO"

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
-- -- connections
local userPcInputConnection: RBXScriptConnection | nil = nil

GuiServices.StoreInCache(PhaseNumberText)
GuiServices.StoreInCache(CountdownTextContainer)
GuiServices.StoreInCache(TeamMembersContainer)
GuiServices.StoreInCache(GamePtsContainer)
GuiServices.StoreInCache(TimerBarContainer)

GuiServices.DefaultMainGuiStyling(CountdownTextContainer, { PosY = -CountdownTextContainer.Size.Y.Scale })
local phaseNumberTextHiddenPos: UDim2 = GuiServices.DefaultMainGuiStyling(PhaseNumberText, { PosX = PhaseNumberText.Position.X.Scale, PosY = -PhaseNumberText.Size.Y.Scale })
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
    local energyIconDropshadow: ImageLabel = energyContainer:FindFirstChild("EnergyIconDropshadow", true)
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

local function setupPcUserInputConnection()
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

local function setPhaseIndicatorText(phaseNumber: number)
    PhaseNumberText.Text = PHASE_INDICATOR_TEXT:gsub("PHASE_NO", phaseNumber)
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
    -- populate staff member container
    clearStaffMemberContainer()
    populateStaffMemberContainer()
end

-- general gamedev gui to display across the different phases
local function showGameDevGui()
    local instancesToShow = {PhaseNumberText, TeamMembersContainer, GamePtsContainer, TimerBarContainer}
    for _i, v in instancesToShow do
        local visiblePos = GuiServices.GetCachedData(v).Position
        v.Visible = true
        TweenService:Create(v, TweenInfo.new(0.3), { Position = visiblePos }):Play()
    end
end

local function hideGameDevGui()
    local instancesToHide = {
        [PhaseNumberText.Name] = phaseNumberTextHiddenPos,
        [TeamMembersContainer.Name] = teamMembersContainerHiddenPos,
        [GamePtsContainer.Name] = gamePtsContainerHiddenPos,
        [TimerBarContainer.Name] = timerBarContainerContainerHiddenPos
    }

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

local function resetTimerBar(): Tween
    local tween = TweenService:Create(TimerBarProg, TweenInfo.new(TimerBarProg.Size.X.Scale * 0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Size = UDim2.fromScale(0, 1) })
    tween:Play()

    return tween
end

local function styleTimerBar()
    local xSizeScale: number = TimerBarProg.Size.X.Scale
    local colours -- timer bar uses same colours as staff members energy bar
    if xSizeScale >= 0.66 then
        colours = ENERGY_COLOURS.HighEnergy
    elseif xSizeScale >= 0.33 then
        colours = ENERGY_COLOURS.MedEnergy
    else
        colours = ENERGY_COLOURS.LowEnergy
    end

    TimerBarContainer.BackgroundColor3 = colours.Main
    TimerBarProg.BackgroundColor3 = colours.Prog
end

local function startTimerBar(time: number)
    local timeLeft = time
    task.spawn(function()
        while timeLeft > 0 do
            styleTimerBar()
            task.wait(1)
            timeLeft -= 1
        end
    end)

    -- reset timer bar
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

    local random = Random.new()
    template.Position = UDim2.fromScale(random:NextNumber(0, 1), random:NextNumber(0, 1))

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
        GuiServices.MakeInvisible(btnInstance, 0.3)
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

-- REMOTES --
Remotes.GameDev.CreateGame.DevelopGame.OnClientEvent:Connect(function()
    plrData = Remotes.Data.GetAllData:InvokeServer()
    plrPlatform = Remotes.Player.GetPlrPlatformData:InvokeServer().Platform
    helpingStaffMembers = StudioConfig.GetStaffInActiveStudio(plrData)
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
        setPhaseIndicatorText(phase)
        setupGameDevGui()

        if plrPlatform == "pc" then
            setupPcUserInputConnection()
        end
    end

    if phase == 2 then
        
    end

    -- bug fix phase
    if phase == -1 then
        
    end
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

-- phase 1 btn remotes
Remotes.GameDev.CreateGame.Phase1.SendBtn.OnClientEvent:Connect(phase1DisplayBtn)
Remotes.GameDev.CreateGame.Phase1.RemoveBtn.OnClientEvent:Connect(phase1RemoveBtn)

Remotes.GUI.GameDev.StartTimerBar.OnClientEvent:Connect(startTimerBar)