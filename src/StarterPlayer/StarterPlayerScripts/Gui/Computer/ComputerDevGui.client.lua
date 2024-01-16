local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GeneralUtils = require(ReplicatedStorage.Utils:WaitForChild("GeneralUtils"))
local GeneralConfig = require(ReplicatedStorage.Configs:WaitForChild("General"))
local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))
local PlayerServices = require(ReplicatedStorage.Utils.Player:WaitForChild("Player"))
local CameraControls = require(ReplicatedStorage.Utils.Camera:WaitForChild("CameraControls"))
local StudioConfig = require(ReplicatedStorage.Configs.Studio:WaitForChild("Studio"))
local StaffMemberConfig = require(ReplicatedStorage.Configs.Staff:WaitForChild("StaffMember"))
local FormatNumber = require(ReplicatedStorage.Libs:WaitForChild("FormatNumber").Simple)

local Remotes = ReplicatedStorage.Remotes

local localPlr = Players.LocalPlayer

local PlayerGui = localPlr.PlayerGui
local camera = Workspace:WaitForChild("Camera")

-- GUI REFERENCE VARIABLES --
local AllGuiScreenGui = PlayerGui:WaitForChild("AllGui")

local ComputerDevContainer = AllGuiScreenGui.Computer:WaitForChild("ComputerDevelopContainer")
local ComputerDevExitBtn = ComputerDevContainer.ExitBtn
local ComputerDevHeader = ComputerDevContainer.Header
-- game name
local GameNameContainer = ComputerDevContainer.ComputerDevelopContainerInner.GameNameContainer
local GameNameInput = GameNameContainer.TextBox
-- genre & topic
local GenreTopicContainer = ComputerDevContainer.ComputerDevelopContainerInner.GenreTopicContainer
local GenreBtn = GenreTopicContainer.Btns.GenreBtn
local TopicBtn = GenreTopicContainer.Btns.TopicBtn
local MatchResultContainer = GenreTopicContainer.MatchResult
local MatchInfoText = MatchResultContainer.MatchInfo
-- team / current staff members
local TeamContainer = ComputerDevContainer.ComputerDevelopContainerInner.TeamContainer
local TeamMembersContainer = TeamContainer.TeamMembers
local TeamHeader = TeamContainer.TeamHeader
local TeamStaffMemberTemplate = TeamMembersContainer.StaffTemplateContainer
-- requirements
local RequirementsContainer = ComputerDevContainer.ComputerDevelopContainerInner.RequirementsContainer
local RequirementEnergyText = RequirementsContainer.EnergyRequirement.Need
local RequirementHungerText = RequirementsContainer.HungerRequirement.Need
local RequirementMoodText = RequirementsContainer.MoodRequirement.Need
-- other
local ConfirmBtn = ComputerDevContainer.ComputerDevelopContainerInner.ConfirmBtn


-- STATIC VARIABLES --
local TEAM_HEADER = "Current Team (CURR/MAX)"

-- STATE VARIABLES --
local plrData = nil
local studioPcModel: Model = nil
local selectedGenre: string = nil
local selectedTopic: string = nil

GuiServices.StoreInCache(ComputerDevContainer)
GuiServices.DefaultMainGuiStyling(ComputerDevContainer)

local function determineGenreTopicSection()
    local colour = nil
    local text = ""

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

local function resetStaffMemberDisplay()
    local instancesToIgnore = {"UICorner", "UIListLayout", "UIStroke", "StaffTemplateContainer"}
    for _i, v in TeamContainer.TeamMembers:GetChildren() do
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
    templateContainer.Parent = TeamMembersContainer
    templateContainer.Name = staffMemberUUID
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

    local staffInStudio = plrData.Studio.Studios[studioType][studioIndex].StaffMembers
    local staffInInventory = plrData.Inventory.StaffMembers

    TeamHeader.Text = TEAM_HEADER:gsub("CURR", tostring(GeneralUtils.LengthOfDict(staffInStudio))):gsub("MAX", tostring(plrData.Studio.StaffMemberCapacity))

    for staffMemberUUID, _staffMemberStudioData in staffInStudio do
        local staffMemberData = staffInInventory[staffMemberUUID]
        createStaffMemberTemplate(staffMemberUUID, staffMemberData)
    end
end

-- resets gui instances & variables
local function resetDevelopGameGui()
    selectedGenre = nil
    selectedTopic = nil
    GameNameInput.Text = ""
    GenreBtn.Image = ""
    TopicBtn.Image = ""
    resetStaffMemberDisplay()
end

local function populateDevelopGameGui()
    determineGenreTopicSection()
    populateTeamSection()
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

    GuiServices.HideHUD()
    GuiServices.ShowGuiStandard(ComputerDevContainer)
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

-- REMOTES --
Remotes.GUI.ChangeGuiStatusBindable.Event:Connect(function(guiName, showGui, _options)
    plrData = Remotes.Data.GetAllData:InvokeServer()

    if showGui then
        if guiName == "developGame" then
            prepareDevelopGameGui()
        end
    end
end)
