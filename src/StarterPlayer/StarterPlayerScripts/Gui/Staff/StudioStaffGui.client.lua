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
-- -- energy bar
local StaffViewEnergyContainer = StaffViewContainer.StaffViewContainerInner:FindFirstChild("EnergyContainer")
local StaffViewEnergyText = StaffViewEnergyContainer:FindFirstChild("Energy", true)
local StaffViewEnergyBarProg = StaffViewEnergyContainer:FindFirstChild("EnergyProg", true)
local StaffViewEnergyTimer = StaffViewEnergyContainer:FindFirstChild("EnergyTimer")
-- -- skill pts
local StaffViewSkillPtsContainer = StaffViewContainer.StaffViewContainerInner:FindFirstChild("SkillPtsContainer")
local StaffViewCodingPtsAmt = StaffViewSkillPtsContainer.CodingPts:FindFirstChild("PtsAmt")
local StaffViewSoundPtsAmt = StaffViewSkillPtsContainer.SoundPts:FindFirstChild("PtsAmt")
local StaffViewArtPtsAmt = StaffViewSkillPtsContainer.ArtPts:FindFirstChild("PtsAmt")

-- train staff member gui
local StaffTrainContainer = AllGuiScreenGui.Staff:WaitForChild("StaffTrainContainer")
local StaffTrainExitBtn = StaffTrainContainer:FindFirstChild("ExitBtn")
local StaffTrainHeader = StaffTrainContainer:FindFirstChild("Header")
local StaffTrainSpecialtyText = StaffTrainContainer.StaffTrainContainerInner:FindFirstChild("Specialty")
-- energy bar
local StaffTrainEnergyContainer = StaffTrainContainer.StaffTrainContainerInner:FindFirstChild("EnergyContainer")
local StaffTrainEnergyText = StaffTrainEnergyContainer:FindFirstChild("Energy", true)
local StaffTrainEnergyBarProg = StaffTrainEnergyContainer:FindFirstChild("EnergyProg", true)
-- train stats
local StaffTrainSkillPtsContainer = StaffTrainContainer.StaffTrainContainerInner:FindFirstChild("SkillPtsContainer")
local StaffTrainCodingPtsText = StaffTrainSkillPtsContainer.CodingPts:FindFirstChild("PtsAmount")
local StaffTrainCodingPtsBuyBtn = StaffTrainSkillPtsContainer.CodingPts:FindFirstChild("BuyBtn")
local StaffTrainSoundPtsText = StaffTrainSkillPtsContainer.SoundPts:FindFirstChild("PtsAmount")
local StaffTrainSoundPtsBuyBtn = StaffTrainSkillPtsContainer.SoundPts:FindFirstChild("BuyBtn")
local StaffTrainArtPtsText = StaffTrainSkillPtsContainer.ArtPts:FindFirstChild("PtsAmount")
local StaffTrainArtPtsBuyBtn = StaffTrainSkillPtsContainer.ArtPts:FindFirstChild("BuyBtn")
local StaffTrainAllStatsBtn = StaffTrainContainer.StaffTrainContainerInner:FindFirstChild("TrainAllStatsBtn")
local StaffTrainUpgradeOneBtn = StaffTrainContainer.StaffTrainContainerInner.UpgradeAmtBtns:FindFirstChild("Upgrade1")
local StaffTrainUpgradeFiveBtn = StaffTrainContainer.StaffTrainContainerInner.UpgradeAmtBtns:FindFirstChild("Upgrade5")
local StaffTrainUpgradeMaxBtn = StaffTrainContainer.StaffTrainContainerInner.UpgradeAmtBtns:FindFirstChild("UpgradeMax")

-- STATIC VARIABLES --
local ENERGY_TEXT = "CURRENT / MAX"
local SPECIALTY_TEXT = "Specialty: SPECIALTY"
local ENERGY_FULL_IN_TEXT = "Full in: FORMATTED_TIME"

-- STATE VARIABLES --
local currentlyViewedStaffUUID: string | nil = nil -- uuid of the staff member currently being viewed (or trained)
local currentlyViewedStaffInstance: {} | nil = nil -- instance object of the staff member currently being viewed (or trained)
local currentlyViewedStaffPcModel: Model | nil = nil -- the PC model of the placed staff member model being viewed\
local selectedUpgradeBtn = "1" -- how many staff member skill upgrades occur at once ("1"=1, "2"=5, "3"=max)

GuiServices.StoreInCache(StaffViewContainer)
GuiServices.DefaultMainGuiStyling(StaffViewContainer)

GuiTemplates.HeaderText(StaffViewHeader)
GuiTemplates.HeaderText(StaffTrainHeader)
GuiTemplates.CreateButton(StaffViewExitBtn, { Rotates = true })
GuiTemplates.CreateButton(StaffTrainExitBtn, { Rotates = true })

local function getAmtOfUpgrades(): number
    if selectedUpgradeBtn == "1" then
        return 1
    elseif selectedUpgradeBtn == "2" then
        return 5
    elseif selectedUpgradeBtn == "3" then
        return -1
    end
end

local function resetViewedStaffVariables()
    currentlyViewedStaffUUID = nil
    currentlyViewedStaffInstance = nil
    selectedUpgradeBtn = "1"
end

local function populateStaffViewGui()
    StaffViewHeader.Text = currentlyViewedStaffInstance.Name
    StaffViewRarity.Text = StaffMemberConfig.GetRarityName(currentlyViewedStaffInstance.Model)
    StaffViewRarity.TextColor3 = GeneralConfig.GetRarityColour(currentlyViewedStaffInstance.Rarity)
    StaffViewSpecialty.Text = SPECIALTY_TEXT:gsub("SPECIALTY", currentlyViewedStaffInstance.Specialisation)
    StaffViewEnergyBarProg.Size = UDim2.fromScale(currentlyViewedStaffInstance.CurrentEnergy / currentlyViewedStaffInstance:CalcMaxEnergy(), 1)
    StaffViewEnergyText.Text = ENERGY_TEXT:gsub("CURRENT", currentlyViewedStaffInstance.CurrentEnergy):gsub("MAX", currentlyViewedStaffInstance:CalcMaxEnergy())
    StaffViewEnergyTimer.Text = ENERGY_FULL_IN_TEXT:gsub("FORMATTED_TIME", DateTimeUtils.FormatTimeLeft(currentlyViewedStaffInstance:CalcTimeUntilFullEnergy()))
    StaffViewCodingPtsAmt.Text = tostring(currentlyViewedStaffInstance:GetSpecificSkillPoints("code"))
    StaffViewSoundPtsAmt.Text = tostring(currentlyViewedStaffInstance:GetSpecificSkillPoints("sound"))
    StaffViewArtPtsAmt.Text = tostring(currentlyViewedStaffInstance:GetSpecificSkillPoints("art"))
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

local function styleUpgradeAmtBtns()
    for _i, btn in {StaffTrainUpgradeOneBtn, StaffTrainUpgradeFiveBtn, StaffTrainUpgradeMaxBtn} do
        local btnID: string = btn:GetAttribute("ID")
        local btnStroke: UIStroke = btn:FindFirstChild("UIStroke")
        local textStroke: UIStroke = btn.CostText:FindFirstChild("UIStroke")

        if btnID == selectedUpgradeBtn then
            -- style as selected btn
            btn.BackgroundColor3 = Color3.fromRGB(97, 234, 76)
            btnStroke.Color = Color3.fromRGB(56, 165, 32)
            textStroke.Color = Color3.fromRGB(42, 90, 41)

        else
            -- style as unselected btn
            btn.BackgroundColor3 = Color3.fromRGB(234, 106, 109)
            btnStroke.Color = Color3.fromRGB(198, 58, 61)
            textStroke.Color = Color3.fromRGB(90, 43, 44)
        end
    end
end

local function populateStaffTrainSkillUpgradeContainer()
    local specifiedCodeLevel
    local specifiedSoundLevel
    local specifiedArtLevel

    if selectedUpgradeBtn == "1" then
        specifiedCodeLevel = 1
        specifiedSoundLevel = 1
        specifiedArtLevel = 1
    elseif selectedUpgradeBtn == "2" then
        specifiedCodeLevel = 5
        specifiedSoundLevel = 5
        specifiedArtLevel = 5
    elseif selectedUpgradeBtn == "3" then
        specifiedCodeLevel = currentlyViewedStaffInstance:GetSpecificSkillLevel("code", { MaxAffordableLevel = true })
        specifiedSoundLevel = currentlyViewedStaffInstance:GetSpecificSkillLevel("sound", { MaxAffordableLevel = true })
        specifiedArtLevel = currentlyViewedStaffInstance:GetSpecificSkillLevel("art", { MaxAffordableLevel = true })
    end

    local currentCodePts = currentlyViewedStaffInstance:GetSpecificSkillPoints("code")
    local upgradedCodePts = currentlyViewedStaffInstance:GetSpecificSkillPoints("code", { SpecifiedSkillLevel = specifiedCodeLevel })
    StaffTrainCodingPtsText.Text = `<font color="#FFF"><stroke color="#76a8d6" thickness="3">{currentCodePts}%%</stroke></font><font color="#a0f2a8"><stroke color="#72b078" thickness="3"> >> {upgradedCodePts}%%</stroke></font>`
    StaffTrainCodingPtsBuyBtn.Text = tostring(currentlyViewedStaffInstance:CalcSkillLevelUpgradeCost("code", { AmountOfUpgrades = specifiedCodeLevel }))

    local currentSoundPts = currentlyViewedStaffInstance:GetSpecificSkillPoints("sound")
    local upgradedSoundPts = currentlyViewedStaffInstance:GetSpecificSkillPoints("sound", { SpecifiedSkillLevel = specifiedSoundLevel })
    StaffTrainSoundPtsText.Text = `<font color="#FFF"><stroke color="#76a8d6" thickness="3">{currentSoundPts}%%</stroke></font><font color="#a0f2a8"><stroke color="#72b078" thickness="3"> >> {upgradedSoundPts}%%</stroke></font>`
    StaffTrainSoundPtsBuyBtn.Text = tostring(currentlyViewedStaffInstance:CalcSkillLevelUpgradeCost("sound", { AmountOfUpgrades = specifiedSoundLevel }))

    local currentArtPts = currentlyViewedStaffInstance:GetSpecificSkillPoints("art")
    local upgradedArtPts = currentlyViewedStaffInstance:GetSpecificSkillPoints("art", { SpecifiedSkillLevel = specifiedArtLevel })
    StaffTrainArtPtsText.Text = `<font color="#FFF"><stroke color="#76a8d6" thickness="3">{currentArtPts}%%</stroke></font><font color="#a0f2a8"><stroke color="#72b078" thickness="3"> >> {upgradedArtPts}%%</stroke></font>`
    StaffTrainArtPtsBuyBtn.Text = tostring(currentlyViewedStaffInstance:CalcSkillLevelUpgradeCost("art", { AmountOfUpgrades = specifiedArtLevel }))
end

local function populateStaffTrainGui()
    StaffTrainHeader.Text = `Train {currentlyViewedStaffInstance.Name}`
    StaffTrainSpecialtyText.Text = SPECIALTY_TEXT:gsub("SPECIALTY", currentlyViewedStaffInstance.Specialisation)
    StaffTrainEnergyBarProg.Size = UDim2.fromScale(currentlyViewedStaffInstance.CurrentEnergy / currentlyViewedStaffInstance:CalcMaxEnergy(), 1)
    StaffTrainEnergyText.Text = ENERGY_TEXT:gsub("CURRENT", currentlyViewedStaffInstance.CurrentEnergy):gsub("MAX", currentlyViewedStaffInstance:CalcMaxEnergy())

    populateStaffTrainSkillUpgradeContainer()
end

local function prepareStaffTrainGui()
    styleUpgradeAmtBtns()
    populateStaffTrainGui()
end

local function hideStaffViewGui()
    resetViewedStaffVariables()
    PlayerServices.ShowPlayer(localPlr, true)
    GeneralUtils.ShowModel(currentlyViewedStaffPcModel, { Tween = true })
    CameraControls.SetDefault(localPlr, camera, true)
    GuiServices.ShowHUD()
    Remotes.Player.StopInspecting:Fire()
end

local function hideStaffTrainGui()
    resetViewedStaffVariables()
    PlayerServices.ShowPlayer(localPlr, true)
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

StaffTrainExitBtn.Activated:Connect(function()
    local hideTween = GuiServices.HideGuiStandard(StaffTrainContainer)
    hideTween.Completed:Connect(function()
        hideStaffTrainGui()
    end)
end)

-- upgrade amt btns
for _i, btn in {StaffTrainUpgradeOneBtn, StaffTrainUpgradeFiveBtn, StaffTrainUpgradeMaxBtn} do
    local btnID: string = btn:GetAttribute("ID")
    selectedUpgradeBtn = btnID
    styleUpgradeAmtBtns()
end


-- REMOTES --
Remotes.GUI.ChangeGuiStatusBindable.Event:Connect(function(guiName, showGui, options)
    if showGui then
        if guiName == "viewStaffMemberStudio" or guiName == "trainStaffMemberStudio" then
            currentlyViewedStaffUUID = options.StaffMemberUUID
            local staffMemberData = Remotes.Staff.GetStaffMemberData:InvokeServer(currentlyViewedStaffUUID)
            if not staffMemberData then
                resetViewedStaffVariables()
                return
            end
            currentlyViewedStaffInstance = StaffMemberConfig.new(currentlyViewedStaffUUID, staffMemberData)
        end

        if guiName == "viewStaffMemberStudio" then
            prepareStaffViewGui()
        elseif guiName == "trainStaffMemberStudio" then
            prepareStaffTrainGui()
        end
    end
end)