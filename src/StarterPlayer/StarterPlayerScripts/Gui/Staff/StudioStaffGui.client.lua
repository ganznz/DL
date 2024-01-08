local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))
local GuiTemplates = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiTemplates"))
local GeneralConfig = require(ReplicatedStorage.Configs:WaitForChild("General"))
local GeneralUtils = require(ReplicatedStorage.Utils:WaitForChild("GeneralUtils"))
local StaffMemberConfig = require(ReplicatedStorage.Configs.Staff:WaitForChild("StaffMember"))
local DateTimeUtils = require(ReplicatedStorage.Utils.DateTime:WaitForChild("DateTime"))
local CameraControls = require(ReplicatedStorage.Utils.Camera:WaitForChild("CameraControls"))
local PlayerServices = require(ReplicatedStorage.Utils.Player:WaitForChild("Player"))

local Remotes = ReplicatedStorage.Remotes

local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui
local camera = Workspace:WaitForChild("Camera")

-- GUI REFERENCE VARIABLES --
local AllGuiScreenGui = PlayerGui:WaitForChild("AllGui")

-- view staff member gui
local StaffViewContainer = AllGuiScreenGui.Staff:WaitForChild("StaffViewContainer")
local StaffViewExitBtn = StaffViewContainer:FindFirstChild("ExitBtn")
local StaffViewHeader = StaffViewContainer:FindFirstChild("Header")
local StaffViewRarity = StaffViewContainer.StaffViewContainerInner:FindFirstChild("Rarity")
local StaffViewSpecialty = StaffViewContainer.StaffViewContainerInner:FindFirstChild("Specialty")
-- -- energy gui
local StaffViewEnergyContainer = StaffViewContainer.StaffViewContainerInner:FindFirstChild("EnergyContainer")
local StaffViewEnergyText = StaffViewContainer.StaffViewContainerInner:FindFirstChild("Energy", true)
local StaffViewEnergyBarProg = StaffViewContainer.StaffViewContainerInner:FindFirstChild("EnergyProg", true)
local StaffViewEnergyTimer = StaffViewContainer.StaffViewContainerInner:FindFirstChild("EnergyTimer")
-- -- skill pts
local StaffViewSkillPtsContainer = StaffViewContainer.StaffViewContainerInner:FindFirstChild("SkillPtsContainer")
local StaffViewCodingPtsAmt = StaffViewSkillPtsContainer.CodingPts:FindFirstChild("PtsAmt")
local StaffViewSoundPtsAmt = StaffViewSkillPtsContainer.SoundPts:FindFirstChild("PtsAmt")
local StaffViewArtPtsAmt = StaffViewSkillPtsContainer.ArtPts:FindFirstChild("PtsAmt")

-- train staff member gui

-- STATIC VARIABLES --
local ENERGY_TEXT = "CURRENT / MAX"
local SPECIALTY_TEXT = "Specialty: SPECIALTY"

-- STATE VARIABLES --
local currentlyViewedStaffUUID: string | nil = nil -- uuid of the staff member currently being viewed (or trained)
local currentlyViewedStaffInstance: {} | nil = nil -- instance object of the staff member currently being viewed (or trained)
local currentlyViewedStaffPcModel: Model | nil = nil -- the PC model of the placed staff member model being viewed


GuiServices.StoreInCache(StaffViewContainer)
GuiServices.DefaultMainGuiStyling(StaffViewContainer)

GuiTemplates.HeaderText(StaffViewHeader)
GuiTemplates.CreateButton(StaffViewExitBtn, { Rotates = true })

local function resetViewedStaffVariables()
    currentlyViewedStaffUUID = nil
    currentlyViewedStaffInstance = nil
end

local function populateStaffViewGui()
    StaffViewHeader.Text = currentlyViewedStaffInstance.Name
    StaffViewRarity.Text = StaffMemberConfig.GetRarityName(currentlyViewedStaffInstance.Model)
    StaffViewRarity.TextColor3 = GeneralConfig.GetRarityColour(currentlyViewedStaffInstance.Rarity)
    StaffViewSpecialty.Text = SPECIALTY_TEXT:gsub("SPECIALTY", currentlyViewedStaffInstance.Specialisation)
    StaffViewEnergyBarProg.Size = UDim2.fromScale(currentlyViewedStaffInstance.CurrentEnergy / currentlyViewedStaffInstance:CalcMaxEnergy(), 1)
    StaffViewEnergyText.Text = ENERGY_TEXT:gsub("CURRENT", currentlyViewedStaffInstance.CurrentEnergy):gsub("MAX", currentlyViewedStaffInstance:CalcMaxEnergy())
    StaffViewEnergyTimer.Text = DateTimeUtils.FormatTimeLeft( currentlyViewedStaffInstance:CalcTimeUntilFullEnergy() )
    StaffViewCodingPtsAmt.Text = tostring(currentlyViewedStaffInstance:GetCodePoints())
    StaffViewSoundPtsAmt.Text = tostring(currentlyViewedStaffInstance:GetSoundPoints())
    StaffViewArtPtsAmt.Text = tostring(currentlyViewedStaffInstance:GetArtPoints())
end

local function prepareStaffViewGui()
    local studioPlacedItemsFolder = Workspace.TempAssets.Studios:FindFirstChild("PlacedObjects", true)
    local placedItem = studioPlacedItemsFolder:FindFirstChild(currentlyViewedStaffUUID)
    currentlyViewedStaffPcModel = placedItem:FindFirstChild("Pc")

    local cameraPosPart = placedItem:FindFirstChild("CameraPositionPart")
    local cameraLookAtPart = placedItem:FindFirstChild("CameraLookAt")

    GuiServices.HideHUD({ HideGuiFrames = true })

    populateStaffViewGui()
    PlayerServices.HidePlayer(localPlr, true)
    GeneralUtils.HideModel(currentlyViewedStaffPcModel, { Tween = true })
    CameraControls.FocusOnObject(localPlr, camera, cameraPosPart.Position, cameraLookAtPart.Position, true, true)

    GuiServices.ShowGuiStandard(StaffViewContainer)
end

local function hideStaffViewGui()
    resetViewedStaffVariables()
    PlayerServices.ShowPlayer(localPlr, true)
    GeneralUtils.ShowModel(currentlyViewedStaffPcModel, { Tween = true })
    CameraControls.SetDefault(localPlr, camera, true)
    GuiServices.ShowHUD()
    Remotes.Player.StopInspecting:Fire()
end

-- BTN ACTIVATIONS --
StaffViewExitBtn.Activated:Connect(function()
    local hideTween = GuiServices.HideGuiStandard(StaffViewContainer)
    hideTween.Completed:Connect(function()
        hideStaffViewGui()
    end)
end)


-- REMOTES --
Remotes.GUI.ChangeGuiStatusBindable.Event:Connect(function(guiName, showGui, options)
    if showGui then
        if guiName == "viewStaffMemberStudio" then
            currentlyViewedStaffUUID = options.StaffMemberUUID
            local staffMemberData = Remotes.Staff.GetStaffMemberData:InvokeServer(currentlyViewedStaffUUID)
            if not staffMemberData then return end -- add resetStaffVariables function here

            currentlyViewedStaffInstance = StaffMemberConfig.new(currentlyViewedStaffUUID, staffMemberData)

            prepareStaffViewGui()
        end
    end
end)