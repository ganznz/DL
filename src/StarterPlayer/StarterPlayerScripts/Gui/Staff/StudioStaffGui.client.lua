local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlobalVariables = require(ReplicatedStorage:WaitForChild("GlobalVariables"))
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
local StaffViewEnergyTimer = StaffViewContainer.StaffViewContainerInner:FindFirstChild("EnergyTimer")
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
local StaffTrainCodePtsContainer = StaffTrainSkillPtsContainer.CodingPts
local StaffTrainCodingPtsText = StaffTrainCodePtsContainer:FindFirstChild("PtsAmount")
local StaffTrainCodingPtsBuyBtn = StaffTrainSkillPtsContainer.CodingPts:FindFirstChild("BuyBtn")

local StaffTrainSoundPtsContainer = StaffTrainSkillPtsContainer.SoundPts
local StaffTrainSoundPtsText = StaffTrainSoundPtsContainer:FindFirstChild("PtsAmount")
local StaffTrainSoundPtsBuyBtn = StaffTrainSkillPtsContainer.SoundPts:FindFirstChild("BuyBtn")

local StaffTrainArtPtsContainer = StaffTrainSkillPtsContainer.ArtPts
local StaffTrainArtPtsText = StaffTrainArtPtsContainer:FindFirstChild("PtsAmount")
local StaffTrainArtPtsBuyBtn = StaffTrainSkillPtsContainer.ArtPts:FindFirstChild("BuyBtn")

local StaffTrainUpgradeOneBtn = StaffTrainContainer.StaffTrainContainerInner.UpgradeAmtBtns:FindFirstChild("Upgrade1")
local StaffTrainUpgradeFiveBtn = StaffTrainContainer.StaffTrainContainerInner.UpgradeAmtBtns:FindFirstChild("Upgrade5")
local StaffTrainUpgradeMaxBtn = StaffTrainContainer.StaffTrainContainerInner.UpgradeAmtBtns:FindFirstChild("UpgradeMax")
local StaffTrainUpgradeAllBtn = StaffTrainContainer.StaffTrainContainerInner:FindFirstChild("TrainAllStatsBtn")

-- STATIC VARIABLES --
local ENERGY_TEXT = "CURRENT / MAX"
local SPECIALTY_TEXT = "Specialty: SPECIALTY"
local ENERGY_FULL_IN_TEXT = "Full in: FORMATTED_TIME"

-- STATE VARIABLES --
local plrData = nil
local currentlyViewedStaffUUID: string | nil = nil -- uuid of the staff member currently being viewed (or trained)
local currentlyViewedStaffInstance: {} | nil = nil -- instance object of the staff member currently being viewed (or trained)
local currentlyViewedStaffPcModel: Model | nil = nil -- the PC model of the placed staff member model being viewed\
local selectedUpgradeBtn = "1" -- how many staff member skill upgrades occur at once ("1"=1, "2"=5, "3"=max)
local currentBtnPrices: {[string]: {}} = {} -- e.g. { ["code"]={ Level=5, Price=100 }, ["sound"]={..}, ["art"]={..} }

GuiServices.StoreInCache(StaffViewContainer)
GuiServices.StoreInCache(StaffTrainContainer)
GuiServices.DefaultMainGuiStyling(StaffViewContainer)
GuiServices.DefaultMainGuiStyling(StaffTrainContainer)

GuiTemplates.HeaderText(StaffViewHeader)
GuiTemplates.HeaderText(StaffTrainHeader)
GuiTemplates.CreateButton(StaffViewExitBtn, { Rotates = true })
GuiTemplates.CreateButton(StaffTrainExitBtn, { Rotates = true })
GuiTemplates.CreateButton(StaffTrainCodingPtsBuyBtn)
GuiTemplates.CreateButton(StaffTrainSoundPtsBuyBtn)
GuiTemplates.CreateButton(StaffTrainArtPtsBuyBtn)
GuiTemplates.CreateButton(StaffTrainUpgradeOneBtn)
GuiTemplates.CreateButton(StaffTrainUpgradeFiveBtn)
GuiTemplates.CreateButton(StaffTrainUpgradeMaxBtn)
GuiTemplates.CreateButton(StaffTrainUpgradeAllBtn)

local function resetViewedStaffVariables()
    currentlyViewedStaffUUID = nil
    currentlyViewedStaffInstance = nil
end

local function resetTrainStaffVariables()
    currentlyViewedStaffUUID = nil
    currentlyViewedStaffInstance = nil
    selectedUpgradeBtn = "1"
    currentBtnPrices = {}
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

    GuiServices.HideHUD()
    GuiServices.ShowGuiStandard(StaffViewContainer)
end

local function determineUpgradeBtnCurrency()
    local staffMemberConfig = StaffMemberConfig.GetConfig(currentlyViewedStaffInstance.Model)

    for _i, btn in {StaffTrainCodingPtsBuyBtn, StaffTrainSoundPtsBuyBtn, StaffTrainArtPtsBuyBtn} do
        local currencyImg: ImageLabel = btn:FindFirstChild("CurrencyImage")
        local currencyImgDropShadow: ImageLabel = btn.CurrencyImage:FindFirstChild("CurrencyImageDropshadow")
        if staffMemberConfig.UpgradeCurrency == "Coins" then
            currencyImg.Image = GeneralUtils.GetDecalUrl(GlobalVariables.Images.Icons.CoinIcon)
            currencyImgDropShadow.Image = GeneralUtils.GetDecalUrl(GlobalVariables.Images.Icons.CoinIconDropshadow)

        elseif staffMemberConfig.UpgradeCurrency == "Gems" then
            currencyImg.Image = GeneralUtils.GetDecalUrl(GlobalVariables.Images.Icons.GemIcon)
            currencyImgDropShadow.Image = GeneralUtils.GetDecalUrl(GlobalVariables.Images.Icons.GemIconDropshadow)
        end
    end
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

-- helper functions to styleUpgradeBuyBtns function
local function styleUpgradeBtnAfford(btn: TextButton)
    local btnUIStroke: UIStroke = btn:FindFirstChild("UIStroke")
    local CurrencyImageDropshadow: ImageLabel = btn:FindFirstChild("CurrencyImageDropshadow", true)
    btn.BackgroundColor3 = Color3.fromRGB(93, 217, 91)
    btnUIStroke.Color = Color3.fromRGB(61, 149, 41)
    CurrencyImageDropshadow.ImageColor3 = Color3.fromRGB(61, 149, 41)
end
local function styleUpgradeBtnCantAfford(btn: TextButton)
    local btnUIStroke: UIStroke = btn:FindFirstChild("UIStroke")
    local CurrencyImageDropshadow: ImageLabel = btn:FindFirstChild("CurrencyImageDropshadow", true)
    btn.BackgroundColor3 = Color3.fromRGB(168, 168, 168)
    btnUIStroke.Color = Color3.fromRGB(126, 126, 126)
    CurrencyImageDropshadow.ImageColor3 = Color3.fromRGB(126, 126, 126)
end

local function styleUpgradeBuyBtns()
    local plrCoins = plrData.Coins

    for _i, btn in {StaffTrainCodingPtsBuyBtn, StaffTrainSoundPtsBuyBtn, StaffTrainArtPtsBuyBtn} do
        if btn.Parent == StaffTrainCodePtsContainer then
            local upgradeCost = currentBtnPrices["code"].Price
            if upgradeCost <= plrCoins then styleUpgradeBtnAfford(btn) else styleUpgradeBtnCantAfford(btn) end

        elseif btn.Parent == StaffTrainSoundPtsContainer then
            local upgradeCost = currentBtnPrices["sound"].Price
            if upgradeCost <= plrCoins then styleUpgradeBtnAfford(btn) else styleUpgradeBtnCantAfford(btn) end
        
        elseif btn.Parent == StaffTrainArtPtsContainer then
            local upgradeCost = currentBtnPrices["art"].Price
            if upgradeCost <= plrCoins then styleUpgradeBtnAfford(btn) else styleUpgradeBtnCantAfford(btn) end 
        end
    end
end

local function populateStaffTrainSkillUpgradeContainer()
    print(currentlyViewedStaffInstance)
    if selectedUpgradeBtn == "1" then
        currentBtnPrices["code"].AmtOfUpgrades = 1
        currentBtnPrices["sound"].AmtOfUpgrades = 1
        currentBtnPrices["art"].AmtOfUpgrades = 1
        currentBtnPrices["code"].Level = currentlyViewedStaffInstance:GetSpecificSkillLevel("code") + 1
        currentBtnPrices["sound"].Level = currentlyViewedStaffInstance:GetSpecificSkillLevel("sound") + 1
        currentBtnPrices["art"].Level = currentlyViewedStaffInstance:GetSpecificSkillLevel("art") + 1
    elseif selectedUpgradeBtn == "2" then
        currentBtnPrices["code"].AmtOfUpgrades = 5
        currentBtnPrices["sound"].AmtOfUpgrades = 5
        currentBtnPrices["art"].AmtOfUpgrades = 5
        currentBtnPrices["code"].Level = currentlyViewedStaffInstance:GetSpecificSkillLevel("code") + 5
        currentBtnPrices["sound"].Level = currentlyViewedStaffInstance:GetSpecificSkillLevel("sound") + 5
        currentBtnPrices["art"].Level = currentlyViewedStaffInstance:GetSpecificSkillLevel("art") + 5
    elseif selectedUpgradeBtn == "3" then
        local currentCodeLvl = currentlyViewedStaffInstance:GetSpecificSkillLevel("code")
        local currentSoundLvl = currentlyViewedStaffInstance:GetSpecificSkillLevel("sound")
        local currentArtLvl = currentlyViewedStaffInstance:GetSpecificSkillLevel("art")
        local maxAffordableCodeLvl = currentlyViewedStaffInstance:GetSpecificSkillLevel("code", { MaxAffordableLevel = true })
        local maxAffordableSoundLvl = currentlyViewedStaffInstance:GetSpecificSkillLevel("sound", { MaxAffordableLevel = true })
        local maxAffordableArtLvl = currentlyViewedStaffInstance:GetSpecificSkillLevel("art", { MaxAffordableLevel = true })
        -- when on "MAX" option and plr can't afford any extra levels, display the next level upgrade (even though it cannot be afforded)
        if maxAffordableCodeLvl <= currentCodeLvl then
            currentBtnPrices["code"].Level = currentCodeLvl + 1
            currentBtnPrices["code"].AmtOfUpgrades = 1
        else
            currentBtnPrices["code"].Level = maxAffordableCodeLvl
            currentBtnPrices["code"].AmtOfUpgrades = maxAffordableCodeLvl - currentCodeLvl
        end
        
        if maxAffordableSoundLvl <= currentSoundLvl then
            currentBtnPrices["sound"].Level = currentSoundLvl + 1
            currentBtnPrices["sound"].AmtOfUpgrades = 1
        else
            currentBtnPrices["sound"].Level = maxAffordableSoundLvl
            currentBtnPrices["sound"].AmtOfUpgrades = maxAffordableSoundLvl - currentSoundLvl
        end
        
        if maxAffordableArtLvl <= currentArtLvl then
            currentBtnPrices["art"].Level = currentArtLvl + 1
            currentBtnPrices["art"].AmtOfUpgrades = 1
        else
            currentBtnPrices["art"].Level = maxAffordableArtLvl
            currentBtnPrices["art"].AmtOfUpgrades = maxAffordableArtLvl - currentArtLvl
        end
    end

    local codeUpgradeCost = currentlyViewedStaffInstance:CalcSkillLevelUpgradeCost("code", currentBtnPrices["code"].AmtOfUpgrades)
    currentBtnPrices["code"].Price = codeUpgradeCost
    local currentCodePts = currentlyViewedStaffInstance:GetSpecificSkillPoints("code")
    local upgradedCodePts = currentlyViewedStaffInstance:GetSpecificSkillPoints("code", { SpecifiedSkillLevel = currentBtnPrices["code"].Level })
    StaffTrainCodingPtsText.Text = `<font color="#FFF"><stroke color="#76a8d6" thickness="3">{currentCodePts}</stroke></font><font color="#a0f2a8"><stroke color="#72b078" thickness="3"> >> {upgradedCodePts}</stroke></font>`
    StaffTrainCodingPtsBuyBtn:FindFirstChild("CostText").Text = tostring(codeUpgradeCost)

    local soundUpgradeCost = currentlyViewedStaffInstance:CalcSkillLevelUpgradeCost("sound", currentBtnPrices["sound"].AmtOfUpgrades)
    currentBtnPrices["sound"].Price = soundUpgradeCost
    local currentSoundPts = currentlyViewedStaffInstance:GetSpecificSkillPoints("sound")
    local upgradedSoundPts = currentlyViewedStaffInstance:GetSpecificSkillPoints("sound", { SpecifiedSkillLevel = currentBtnPrices["sound"].Level })
    StaffTrainSoundPtsText.Text = `<font color="#FFF"><stroke color="#76a8d6" thickness="3">{currentSoundPts}</stroke></font><font color="#a0f2a8"><stroke color="#72b078" thickness="3"> >> {upgradedSoundPts}</stroke></font>`
    StaffTrainSoundPtsBuyBtn:FindFirstChild("CostText").Text = tostring(soundUpgradeCost)

    local artUpgradeCost = currentlyViewedStaffInstance:CalcSkillLevelUpgradeCost("art", currentBtnPrices["art"].AmtOfUpgrades)
    currentBtnPrices["art"].Price = artUpgradeCost
    local currentArtPts = currentlyViewedStaffInstance:GetSpecificSkillPoints("art")
    local upgradedArtPts = currentlyViewedStaffInstance:GetSpecificSkillPoints("art", { SpecifiedSkillLevel = currentBtnPrices["art"].Level })
    StaffTrainArtPtsText.Text = `<font color="#FFF"><stroke color="#76a8d6" thickness="3">{currentArtPts}</stroke></font><font color="#a0f2a8"><stroke color="#72b078" thickness="3"> >> {upgradedArtPts}</stroke></font>`
    StaffTrainArtPtsBuyBtn:FindFirstChild("CostText").Text = tostring(artUpgradeCost)
end

local function populateStaffTrainGui()
    StaffTrainHeader.Text = `Train {currentlyViewedStaffInstance.Name}`
    StaffTrainSpecialtyText.Text = SPECIALTY_TEXT:gsub("SPECIALTY", currentlyViewedStaffInstance.Specialisation)
    StaffTrainEnergyBarProg.Size = UDim2.fromScale(currentlyViewedStaffInstance.CurrentEnergy / currentlyViewedStaffInstance:CalcMaxEnergy(), 1)
    StaffTrainEnergyText.Text = ENERGY_TEXT:gsub("CURRENT", currentlyViewedStaffInstance.CurrentEnergy):gsub("MAX", currentlyViewedStaffInstance:CalcMaxEnergy())

    populateStaffTrainSkillUpgradeContainer()
end

local function prepareStaffTrainGui()
    local studioPlacedItemsFolder = Workspace.TempAssets.Studios:FindFirstChild("PlacedObjects", true)
    local placedItem = studioPlacedItemsFolder:FindFirstChild(currentlyViewedStaffUUID)
    local cameraPosPart = placedItem:FindFirstChild("CameraPositionPart")
    local cameraLookAtPart = placedItem:FindFirstChild("CameraLookAt")
    
    determineUpgradeBtnCurrency()
    styleUpgradeAmtBtns()
    populateStaffTrainGui()
    styleUpgradeBuyBtns()

    PlayerServices.HidePlayer(localPlr, true)
    CameraControls.FocusOnObject(localPlr, camera, cameraPosPart.Position, cameraLookAtPart.Position, true, true)

    GuiServices.HideHUD()
    GuiServices.ShowGuiStandard(StaffTrainContainer)
end

local function hideStaffViewGui()
    PlayerServices.ShowPlayer(localPlr, true)
    GeneralUtils.ShowModel(currentlyViewedStaffPcModel, { Tween = true })
    CameraControls.SetDefault(localPlr, camera, true)
    GuiServices.ShowHUD()
    Remotes.Player.StopInspecting:Fire()
end

local function hideStaffTrainGui()
    PlayerServices.ShowPlayer(localPlr, true)
    CameraControls.SetDefault(localPlr, camera, true)
    GuiServices.ShowHUD()
    Remotes.Player.StopInspecting:Fire()
end

-- BTN ACTIVATIONS --
-- upgrade amt btns
for _i, btn in {StaffTrainUpgradeOneBtn, StaffTrainUpgradeFiveBtn, StaffTrainUpgradeMaxBtn} do
    btn.Activated:Connect(function()
        local btnID: string = btn:GetAttribute("ID")
        if selectedUpgradeBtn == btnID then return end -- if selecting the upgrade amt btn that is already selected

        selectedUpgradeBtn = btnID
        styleUpgradeAmtBtns()
        populateStaffTrainSkillUpgradeContainer()
        styleUpgradeBuyBtns()
    end)
end

StaffViewExitBtn.Activated:Connect(function()
    local hideTween = GuiServices.HideGuiStandard(StaffViewContainer)
    hideTween.Completed:Connect(function()
        hideStaffViewGui()
        resetViewedStaffVariables() -- reset gui dependant variables before opening
    end)
end)

StaffTrainExitBtn.Activated:Connect(function()
    local hideTween = GuiServices.HideGuiStandard(StaffTrainContainer)
    hideTween.Completed:Connect(function()
        hideStaffTrainGui()
        resetTrainStaffVariables()
    end)
end)

-- upgrade buy btn activations
StaffTrainCodingPtsBuyBtn.Activated:Connect(function()
    if plrData.Coins < currentBtnPrices["code"].Price then return end

    Remotes.Staff.LevelUpSkill:FireServer(currentlyViewedStaffUUID, "code", currentBtnPrices["code"].AmtOfUpgrades)
end)
StaffTrainSoundPtsBuyBtn.Activated:Connect(function()
    if plrData.Coins < currentBtnPrices["sound"].Price then return end

    Remotes.Staff.LevelUpSkill:FireServer(currentlyViewedStaffUUID, "sound", currentBtnPrices["sound"].AmtOfUpgrades)
end)
StaffTrainArtPtsBuyBtn.Activated:Connect(function()
    if plrData.Coins < currentBtnPrices["art"].Price then return end

    Remotes.Staff.LevelUpSkill:FireServer(currentlyViewedStaffUUID, "art", currentBtnPrices["art"].AmtOfUpgrades)
end)

-- REMOTES --
Remotes.GUI.ChangeGuiStatusBindable.Event:Connect(function(guiName, showGui, options)
    plrData = Remotes.Data.GetAllData:InvokeServer()

    if showGui then
        if guiName == "viewStaffMemberStudio" or guiName == "trainStaffMemberStudio" then
            currentlyViewedStaffUUID = options.StaffMemberUUID
            local staffMemberData = plrData.Inventory.StaffMembers[currentlyViewedStaffUUID]
            currentBtnPrices["code"] = { Price = nil, Level = nil, AmtOfUpgrades = nil } -- define
            currentBtnPrices["sound"] = { Price = nil, Level = nil, AmtOfUpgrades = nil }
            currentBtnPrices["art"] = { Price = nil, Level = nil, AmtOfUpgrades = nil }

            if not staffMemberData then
                resetViewedStaffVariables()
                resetTrainStaffVariables()
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

-- when plr earns more coins
-- also gets fired when a staff members skill gets levelled up, as the method responsible for that called AdjustPlrCoins method
Remotes.Character.AdjustPlrCoins.OnClientEvent:Connect(function(_newCoinAmt: number)
    if StaffTrainContainer.Visible then
        plrData = Remotes.Data.GetAllData:InvokeServer()
        local staffMemberData = plrData.Inventory.StaffMembers[currentlyViewedStaffUUID]

        -- refresh staff member instance w/ new data, for cases such as staff member skill levelling up
        currentlyViewedStaffInstance = StaffMemberConfig.new(currentlyViewedStaffUUID, staffMemberData)

        styleUpgradeAmtBtns()
        populateStaffTrainSkillUpgradeContainer()
        styleUpgradeBuyBtns()
    end
end)

-- on plr spawn & death
local function characterAdded(char: Model)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        if StaffViewContainer.Visible then
            resetViewedStaffVariables()
        end
        if StaffTrainContainer.Visible then
            resetTrainStaffVariables()
        end
    end)
end

if localPlr.Character then characterAdded(localPlr.Character) end

localPlr.CharacterAdded:Connect(characterAdded)