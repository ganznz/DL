local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GeneralUtils = require(ReplicatedStorage.Utils:WaitForChild("GeneralUtils"))
local GeneralConfig = require(ReplicatedStorage.Configs:WaitForChild("General"))
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

local ComputerDevContainer = AllGuiScreenGui.Computer:WaitForChild("ComputerDevelopContainer")
local MainScreen = ComputerDevContainer.ComputerDevelopContainerInner.Main
local ComputerDevExitBtn = MainScreen.ExitBtn
local ComputerDevHeader = ComputerDevContainer.Header
-- game name
local GameNameContainer = MainScreen.GameNameContainer
local GameNameInput = GameNameContainer.TextBox
-- genre & topic
local GenreTopicContainer = MainScreen.GenreTopicContainer
local GenreBtn = GenreTopicContainer.Btns.GenreBtn
local TopicBtn = GenreTopicContainer.Btns.TopicBtn
local MatchResultContainer = GenreTopicContainer.MatchResult
local MatchInfoText = MatchResultContainer.MatchInfo
-- genre & topic selection frame
local GenreTopicScreen = ComputerDevContainer.ComputerDevelopContainerInner.GenreTopicSelection
local GenreTopicBackBtn = GenreTopicScreen.BackBtn
local GenreTopicScrollingFrame = GenreTopicScreen.ScrollingFrame
local GenreTopicTemplate = GenreTopicScrollingFrame.Template
-- team / current staff members
local TeamContainer = MainScreen.TeamContainer
local TeamMembersContainer = TeamContainer.TeamMembers
local TeamHeader = TeamContainer.TeamHeader
local TeamStaffMemberTemplate = TeamMembersContainer.StaffTemplateContainer
-- requirements
local RequirementsContainer = MainScreen.RequirementsContainer
local RequirementEnergyText = RequirementsContainer.EnergyRequirement.Need
local RequirementHungerText = RequirementsContainer.HungerRequirement.Need
local RequirementMoodText = RequirementsContainer.MoodRequirement.Need
local RequirementStatusText = RequirementsContainer.RequirementsStatus
-- other
local ConfirmBtn = MainScreen.ConfirmBtn


-- STATIC VARIABLES --
local TEAM_HEADER = "Current Team (CURR/MAX)"
local NEED_TEXT = "CURR/REQUIRED"

-- STATE VARIABLES --
local plrData = nil
local plrCharacterData = nil
local staffInStudio = nil
local studioPcModel: Model = nil
local selectedGenre: string = nil
local selectedTopic: string = nil

GuiServices.StoreInCache(ComputerDevContainer)

GuiServices.DefaultMainGuiStyling(ComputerDevContainer)

GuiTemplates.HeaderText(ComputerDevHeader)
GuiTemplates.CreateButton(ComputerDevExitBtn, { Rotates = true })
GuiTemplates.CreateButton(GenreBtn)
GuiTemplates.CreateButton(TopicBtn)
GuiTemplates.CreateButton(ConfirmBtn)
GuiTemplates.CreateButton(GenreTopicBackBtn)

local function requirementsMet(): boolean
    local requiredNeed = PlayerConfig.CalcMaxNeed(plrData) * ComputerConfig.Constants.NeedReqToMakeGame

    -- check if genre & topic selected
    if not selectedGenre or not selectedTopic then
        RequirementStatusText.Text = "Must select a Genre & Topic"
        return false
    end

    -- check plr needs
    if plrCharacterData.Needs.CurrentEnergy < requiredNeed then
        RequirementStatusText.Text = "Insufficient character needs"
        return false
    end
    if plrCharacterData.Needs.CurrentHunger < requiredNeed then
        RequirementStatusText.Text = "Insufficient character needs"
        return false
    end
    if plrCharacterData.Needs.CurrentMood < requiredNeed then
        RequirementStatusText.Text = "Insufficient character needs"
        return false
    end

    RequirementStatusText.Text = ""
    return true
end

local function determineGenreTopicSection()
    local colour = nil
    local text = ""

    -- apply images to genre & topic buttons
    if selectedGenre then
        local genreConfig = GenreConfig.GetConfig(selectedGenre)
        GenreBtn.Image = GeneralUtils.GetDecalUrl(genreConfig.ImageIcon)
    end
    if selectedTopic then
        local topicConfig = TopicConfig.GetConfig(selectedTopic)
        TopicBtn.Image = GeneralUtils.GetDecalUrl(topicConfig.ImageIcon)
    end

    if selectedGenre and selectedTopic then
        -- determine compatibility using plrdata here
        local isCompatible
        local isIncompatible

        if isCompatible then
            colour = Color3.fromRGB(96, 212, 90)
            text = "Good match!"
        elseif isIncompatible then
            colour = Color3.fromRGB(255, 106, 108)
            text = "Bad match"
        else
            colour = Color3.fromRGB(162, 162, 162)
            text = ""
        end
    
    else
        colour = Color3.fromRGB(162, 162, 162)
        text = "Select Genre & Topic"
    end

    for _i, instance: Instance in MatchResultContainer:GetChildren() do
        if instance:IsA("Frame") then instance.BackgroundColor3 = colour end
        if instance:IsA("TextLabel") then instance:FindFirstChild("UIStroke").Color = colour end
    end

    GenreBtn:FindFirstChild("UIStroke").Color = colour
    TopicBtn:FindFirstChild("UIStroke").Color = colour
    MatchInfoText.Text = text
end

local function resetStaffMemberScrollingFrame()
    local instancesToIgnore = {"UICorner", "UIListLayout", "UIStroke", "StaffTemplateContainer"}
    for _i, v in TeamMembersContainer:GetChildren() do
        if table.find(instancesToIgnore, v.Name) then continue end

        v:Destroy()
    end
end

local function resetGenreTopicScrollingFrame()
    local instancesToIgnore = {"UIGridLayout", "UIPadding", "Template"}
    for _i, v in GenreTopicScrollingFrame:GetChildren() do
        if table.find(instancesToIgnore, v.Name) then continue end

        v:Destroy()
    end
end

local function adjustStaffMemberEnergyBar(energyBarProg: Frame, currEnergy: number, maxEnergy: number)
    energyBarProg.Size = UDim2.fromScale(1, currEnergy / maxEnergy)
end

local function createStaffMemberTemplate(staffMemberUUID: string, staffMemberData)
    local staffMemberConfig: StaffMemberConfig.StaffMemberConfig = StaffMemberConfig.GetConfig(staffMemberData.Model)
    local staffInstance: StaffMemberConfig.StaffMemberInstance = StaffMemberConfig.new(staffMemberUUID, staffMemberData)

    local templateContainer = TeamStaffMemberTemplate:Clone()
    templateContainer.Name = staffMemberUUID
    templateContainer.Parent = TeamMembersContainer
    -- btn
    local templateBtn = templateContainer:FindFirstChild("StaffIcon")
    local staffMemberIcon = templateBtn:FindFirstChild("Icon")
    local staffMemberPts = templateBtn:FindFirstChild("TotalPts")
    -- energy bar
    local energyBar = templateContainer:FindFirstChild("EnergyBar")
    local energyBarProg = energyBar:FindFirstChild("EnergyBarProg")
   
    staffMemberIcon.Image = GeneralUtils.GetDecalUrl(staffMemberConfig.IconStroke)
    staffMemberIcon.BackgroundColor3 = GeneralConfig.GetRarityColour(staffMemberConfig.Rarity)
    staffMemberPts.Text = FormatNumber.FormatCompact(staffInstance:GetTotalSkillPts())

    local currentEnergy = staffMemberData.CurrentEnergy
    local maxEnergy = staffInstance:CalcMaxEnergy()

    adjustStaffMemberEnergyBar(energyBarProg, currentEnergy, maxEnergy)
    templateContainer.Visible = true
end

local function populateTeamSection()
    local studioPlrInfo = Remotes.Studio.General.GetStudioPlrInfo:InvokeServer()
    local studioIndex = studioPlrInfo[tostring(localPlr.UserId)].StudioIndex
    local studioType = StudioConfig.GetConfig(studioIndex).StudioType

    staffInStudio = plrData.Studio.Studios[studioType][studioIndex].StaffMembers
    local staffInInventory = plrData.Inventory.StaffMembers

    TeamHeader.Text = TEAM_HEADER:gsub("CURR", tostring(GeneralUtils.LengthOfDict(staffInStudio))):gsub("MAX", tostring(plrData.Studio.StaffMemberCapacity))

    for staffMemberUUID, _staffMemberStudioData in staffInStudio do
        local staffMemberData = staffInInventory[staffMemberUUID]
        createStaffMemberTemplate(staffMemberUUID, staffMemberData)
    end
end

local function determineRequirementTextColour(textLabel: TextLabel, currentNeed: number, RequiredNeed: number)
    if currentNeed < RequiredNeed then
        textLabel.TextColor3 = Color3.fromRGB(254, 157, 159)
        textLabel:FindFirstChild("UIStroke").Color = Color3.fromRGB(182, 56, 60)
    else
        textLabel.TextColor3 = Color3.fromRGB(140, 255, 134)
        textLabel:FindFirstChild("UIStroke").Color = Color3.fromRGB(66, 157, 66)
    end
end

-- initial setting of requirements section
local function setRequirementsSection()
    local requiredNeed = PlayerConfig.CalcMaxNeed(plrData) * ComputerConfig.Constants.NeedReqToMakeGame
    RequirementEnergyText.Text = NEED_TEXT:gsub("CURR", FormatNumber.FormatCompact(plrCharacterData.Needs.CurrentEnergy)):gsub("REQUIRED", FormatNumber.FormatCompact(requiredNeed))
    RequirementHungerText.Text = NEED_TEXT:gsub("CURR", FormatNumber.FormatCompact(plrCharacterData.Needs.CurrentHunger)):gsub("REQUIRED", FormatNumber.FormatCompact(requiredNeed))
    RequirementMoodText.Text = NEED_TEXT:gsub("CURR", FormatNumber.FormatCompact(plrCharacterData.Needs.CurrentMood)):gsub("REQUIRED", FormatNumber.FormatCompact(requiredNeed))
    determineRequirementTextColour(RequirementEnergyText, plrCharacterData.Needs.CurrentEnergy, requiredNeed)
    determineRequirementTextColour(RequirementHungerText, plrCharacterData.Needs.CurrentHunger, requiredNeed)
    determineRequirementTextColour(RequirementMoodText, plrCharacterData.Needs.CurrentMood, requiredNeed)
end

local function styleConfirmBtn()
    local btnUIStroke: UIStroke = ConfirmBtn:FindFirstChild("UIStroke")
    local btnText: TextLabel = ConfirmBtn:FindFirstChild("Text")
    local textUIStroke: UIStroke = btnText:FindFirstChild("UIStroke")
    
    local canConfirm = requirementsMet()
    if canConfirm then
        ConfirmBtn.BackgroundColor3 = Color3.fromRGB(93, 217, 91)
        btnUIStroke.Color = Color3.fromRGB(67, 172, 83)
        textUIStroke.Color = Color3.fromRGB(67, 172, 83)
    else
        ConfirmBtn.BackgroundColor3 = Color3.fromRGB(168, 168, 168)
        btnUIStroke.Color = Color3.fromRGB(112, 112, 112)
        textUIStroke.Color = Color3.fromRGB(112, 112, 112)
    end
    btnText.Text = "Create game"
end

local function styleGenreTopicTemplate(type: "genre" | "topic", template: ImageButton)
    local isCurrentlySelected = false
    if type == "genre" and selectedGenre == template.Name then isCurrentlySelected = true end
    if type == "topic" and selectedTopic == template.Name then isCurrentlySelected = true end

    local templateUIStroke: UIStroke = template:FindFirstChild("UIStroke")
    local nameUIStroke: UIStroke = template:FindFirstChild("Name"):FindFirstChild("UIStroke")
    local levelIconDropshadow: ImageLabel = template:FindFirstChild("LevelIcon"):FindFirstChild("LevelIconDropshadow")

    if isCurrentlySelected then
        template.BackgroundColor3 = Color3.fromRGB(235, 255, 225)
        templateUIStroke.Color = Color3.fromRGB(85, 176, 73)
        nameUIStroke.Color = Color3.fromRGB(85, 176, 73)
        levelIconDropshadow.ImageColor3 = Color3.fromRGB(85, 176, 73)
    else
        template.BackgroundColor3 = Color3.fromRGB(255, 213, 214)
        templateUIStroke.Color = Color3.fromRGB(230, 91, 93)
        nameUIStroke.Color = Color3.fromRGB(230, 91, 93)
        levelIconDropshadow.ImageColor3 = Color3.fromRGB(230, 91, 93)
    end
end

local function styleAllGenreTopicTemplates(type: "genre" | "topic")
    local instancesToIgnore = {"UIGridLayout", "UIPadding", "Template"}

    for _i, v in GenreTopicScrollingFrame:GetChildren() do
        if table.find(instancesToIgnore, v.Name) then continue end

        styleGenreTopicTemplate(type, v)
    end
end

local function displayGenreTopicSelection(type: "genre" | "topic")
    resetGenreTopicScrollingFrame()
    local dataToIterateOver = type == "genre" and plrData.GameDev.Genres or plrData.GameDev.Topics

    for instanceName, instanceData in dataToIterateOver do
        local itemConfig = type == "genre" and GenreConfig.GetConfig(instanceName) or TopicConfig.GetConfig(instanceName)
        local template = GenreTopicTemplate:Clone()
        template.Parent = GenreTopicScrollingFrame
        template.Name = instanceName
        template.Image = GeneralUtils.GetDecalUrl(itemConfig.ImageSplash)
        local nameText = template:FindFirstChild("Name")
        local levelText = template:FindFirstChild("LevelText", true)

        nameText.Text = instanceName
        levelText.Text = tostring(instanceData.Level)

        styleGenreTopicTemplate(type, template)

        GuiTemplates.CreateButton(template)
        template.LayoutOrder = -instanceData.Level
        template.Visible = true

        template.Activated:Connect(function()
            if type == "genre" then selectedGenre = template.Name else selectedTopic = template.Name end
            styleAllGenreTopicTemplates(type)
        end)
    end

    GenreTopicScreen.Visible = true
    MainScreen.Visible = false
end

-- resets gui instances & variables
local function resetDevelopGameGui()
    selectedGenre = nil
    selectedTopic = nil
    staffInStudio = nil
    GameNameInput.Text = ""
    GenreBtn.Image = ""
    TopicBtn.Image = ""
    MainScreen.Visible = true
    GenreTopicScreen.Visible = false
    resetStaffMemberScrollingFrame()
end

local function populateDevelopGameGui()
    determineGenreTopicSection()
    populateTeamSection()
    setRequirementsSection()
    styleConfirmBtn()
end

local function prepareDevelopGameGui()
    resetDevelopGameGui()

    studioPcModel = Workspace.TempAssets.Studios:FindFirstChild("Computer", true)
    local cameraPosPart = studioPcModel:FindFirstChild("CameraPositionPart")
    local cameraLookAtPart = studioPcModel:FindFirstChild("CameraLookAt")

    GuiServices.HideHUD({ HideGuiFrames = true })

    populateDevelopGameGui()
    PlayerServices.HidePlayer(localPlr, true)
    CameraControls.FocusOnObject(localPlr, camera, cameraPosPart.Position, cameraLookAtPart.Position, true, true)

    GuiServices.ShowGuiStandard(ComputerDevContainer)
    GuiServices.HideHUD()
end

local function onHideComputerDevGui()
    PlayerServices.ShowPlayer(localPlr, true)
    CameraControls.SetDefault(localPlr, camera, true)
    GuiServices.ShowHUD()
    Remotes.Player.StopInspecting:Fire()
end

-- BTN ACTIVATIONS --
ComputerDevExitBtn.Activated:Connect(function()
    local hideTween = GuiServices.HideGuiStandard(ComputerDevContainer)
    hideTween.Completed:Connect(function()
        onHideComputerDevGui()
    end)
end)

GenreBtn.Activated:Connect(function()
    displayGenreTopicSelection("genre")
end)

TopicBtn.Activated:Connect(function()
    displayGenreTopicSelection("topic")
end)

GenreTopicBackBtn.Activated:Connect(function()
    determineGenreTopicSection()
    MainScreen.Visible = true
    GenreTopicScreen.Visible = false
    styleConfirmBtn()
end)

ConfirmBtn.Activated:Connect(function()
    if not requirementsMet() then return end

    Remotes.GameDev.CreateGame.DevelopGame:FireServer(selectedGenre, selectedTopic)
end)

-- REMOTES --
Remotes.GUI.ChangeGuiStatusBindable.Event:Connect(function(guiName, showGui, _options)
    plrData = Remotes.Data.GetAllData:InvokeServer()
    plrCharacterData = plrData.Character

    if showGui then
        if guiName == "developGame" then
            prepareDevelopGameGui()
        end
    end
end)

-- close game setup gui
Remotes.GameDev.CreateGame.DevelopGame.OnClientEvent:Connect(function()
    GuiServices.HideGuiStandard()
end)

Remotes.Staff.AdjustEnergy.OnClientEvent:Connect(function(staffMemberUUID: string, staffMemberData: {})
    if ComputerDevContainer.Visible and staffInStudio then
        if staffInStudio[staffMemberUUID] then
            local staffInstance = StaffMemberConfig.new(staffMemberUUID, staffMemberData)
            local maxEnergy = staffInstance:CalcMaxEnergy()

            local staffMemberTemplate = TeamMembersContainer:FindFirstChild(staffMemberUUID)
            local staffMemberEnergyBarProg = staffMemberTemplate:FindFirstChild("EnergyBarProg", true)
            adjustStaffMemberEnergyBar(staffMemberEnergyBarProg, staffMemberData.CurrentEnergy, maxEnergy)
        end
    end
end)

for _i, remote: RemoteEvent in {Remotes.Character.AdjustPlrEnergy, Remotes.Character.AdjustPlrHunger, Remotes.Character.AdjustPlrMood} do
    remote.OnClientEvent:Connect(function(newPlrCharacterData)
        plrCharacterData = newPlrCharacterData
        setRequirementsSection()
        styleConfirmBtn()
    end)
end