local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlobalVariables = require(ReplicatedStorage.GlobalVariables)
local GeneralUtils = require(ReplicatedStorage.Utils.GeneralUtils)
local GeneralConfig = require(ReplicatedStorage.Configs.General)
local FormatNumber = require(ReplicatedStorage.Libs.FormatNumber.Simple)
local PlayerServices = require(ReplicatedStorage.Utils.Player.Player)
local GuiServices = require(ReplicatedStorage.Utils.Gui.GuiServices)
local GuiTemplates = require(ReplicatedStorage.Utils.Gui.GuiTemplates)
local CameraControls = require(ReplicatedStorage.Utils.Camera.CameraControls)
local ComputerConfig = require(ReplicatedStorage.Configs.GameDev.Computer)
local MaterialsConfig = require(ReplicatedStorage.Configs.Materials.Materials)

local Remotes = ReplicatedStorage.Remotes

local localPlr = Players.LocalPlayer

local PlayerGui = localPlr.PlayerGui
local camera = Workspace:WaitForChild("Camera")

-- GUI REFERENCE VARIABLES --
local AllGuiScreenGui = PlayerGui:WaitForChild("AllGui")
-- general
local ComputerUpgradeContainer = AllGuiScreenGui.Computer:WaitForChild("ComputerUpgradeContainer")
local ContainerInner = ComputerUpgradeContainer.ComputerUpgradeContainerInner
local HeaderText = ComputerUpgradeContainer.Header
local ExitBtn: TextButton = ComputerUpgradeContainer.ExitBtn
local LevelUpComputerBtn: TextButton = ContainerInner.UpgradeBtn
-- stats container
local StatsContainer = ContainerInner.StatsContainer
local CoinsBuffText = StatsContainer:FindFirstChild("Coins", true)
local CodePtsBuffText = StatsContainer:FindFirstChild("CodePts", true)
local SoundPtsBuffText = StatsContainer:FindFirstChild("SoundPts", true)
local ArtPtsBuffText = StatsContainer:FindFirstChild("ArtPts", true)
-- scrolling frame
local ScrollingFrame = ContainerInner.ScrollingFrame
local CompletedTemplate = ScrollingFrame.CompletedTemplate
local LockedTemplate = ScrollingFrame.LockedTemplate
-- -- inprogress template
local InprogressTemplate = ScrollingFrame.InProgressTemplate
-- -- -- requirements view
local RequirementsView = InprogressTemplate.Info.RequirementsView
local InProgComputerIcon = RequirementsView.ComputerIcon
local InProgComputerIconDropshadow = InProgComputerIcon.ComputerIconDropshadow
local InProgComputerName = RequirementsView.ComputerName
local MaterialsContainer = RequirementsView.MaterialsContainer
local MaterialsContainerTemplate = MaterialsContainer.Template
local UpgradesContainer = RequirementsView.UpgradesContainer
local UpgradesTemplateContainer = UpgradesContainer.TemplateContainer
-- -- -- upgrade view
local UpgradeView = InprogressTemplate.Info.UpgradeView
local UpgradeName = UpgradeView.UpgradeName
local UpgradeDesc = UpgradeView.UpgradeDesc
local UpgradeViewSelectBtn = UpgradeView.SelectBtn
local UpgradeViewBackBtn = UpgradeView.BackBtn
local UpgradeViewProgBar = UpgradeView.ProgressContainer.ProgressBar.ProgressBarProg
local UpgradeViewProgText = UpgradeView.ProgressContainer.Progress


-- STATIC VARIABLES --
local materialRequirementText = "CURR/REQUIRED"
local upgradeGoalProgressText = "CURR/REQUIRED"

-- STATE VARIABLES --
local plrData = nil
local studioPcModel: Model = nil
local currentlyViewedComputerUpgrade: string = nil -- this variable stores the name of the upgrade being currently viewed
local backBtnConnection: RBXScriptConnection = nil
local selectBtnConnection: RBXScriptConnection = nil

GuiServices.StoreInCache(ComputerUpgradeContainer)

GuiServices.DefaultMainGuiStyling(ComputerUpgradeContainer)

GuiTemplates.HeaderText(HeaderText)
GuiTemplates.CreateButton(ExitBtn, { Rotates = true })
GuiTemplates.CreateButton(LevelUpComputerBtn, { Rotates = true })
GuiTemplates.CreateButton(UpgradeViewSelectBtn)
GuiTemplates.CreateButton(UpgradeViewBackBtn)

-- set some GUI instances to invisible by default
CompletedTemplate.Visible = false
InprogressTemplate.Visible = false
LockedTemplate.Visible = false
RequirementsView.Visible = false
UpgradeView.Visible = false
UpgradesTemplateContainer.Visible = false
MaterialsContainerTemplate.Visible = false

local function resetVariablesAndConnections()
    -- variables
    plrData = nil
    studioPcModel = nil
    currentlyViewedComputerUpgrade = nil

    -- connections
    if backBtnConnection then backBtnConnection:Disconnect() end
    backBtnConnection = nil
    if selectBtnConnection then selectBtnConnection:Disconnect() end
    selectBtnConnection = nil
end

-- function populates the upgrade view of a specific upgrade, when that upgrade btn is clicked/tapped on
local function populateSpecificComputerUpgradeView(upgradeName: string)
    local plrCurrentComputerLvl: number = plrData.GameDev.Computer.Level
    local computerUpgradeConfig: ComputerConfig.ComputerUpgradeConfig = ComputerConfig.GetUpgradeConfig(plrCurrentComputerLvl, upgradeName)
    if not computerUpgradeConfig then return end

    local plrUpgradeData = plrData.GameDev.Computer.UpgradeProgress[plrCurrentComputerLvl][upgradeName]
    local isUpgradeActive: boolean = plrData.GameDev.Computer.ActiveUpgrade == upgradeName

    local upgradeProgress: number = plrUpgradeData.Progress
    local upgradeGoalValue: number = plrUpgradeData.Goal

    -- style selectBtn
    if isUpgradeActive then
        UpgradeViewSelectBtn.BackgroundColor3 = Color3.fromRGB(97, 234, 76)
        UpgradeViewSelectBtn.UIStroke.Color = Color3.fromRGB(56, 134, 44)
        UpgradeViewSelectBtn.SelectText.UIStroke.Color = Color3.fromRGB(56, 134, 44)
        UpgradeViewSelectBtn.SelectText.Text = "Active"

    -- upgrade is incomplete, but not active
    elseif upgradeProgress < upgradeGoalValue then
        UpgradeViewSelectBtn.BackgroundColor3 = Color3.fromRGB(234, 167, 59)
        UpgradeViewSelectBtn.UIStroke.Color = Color3.fromRGB(165, 106, 24)
        UpgradeViewSelectBtn.SelectText.UIStroke.Color = Color3.fromRGB(165, 106, 24)
        UpgradeViewSelectBtn.SelectText.Text = "Select"
    
    -- upgrade is complete
    elseif upgradeProgress >= upgradeGoalValue then
        UpgradeViewSelectBtn.BackgroundColor3 = Color3.fromRGB(166, 181, 182)
        UpgradeViewSelectBtn.UIStroke.Color = Color3.fromRGB(77, 84, 84)
        UpgradeViewSelectBtn.SelectText.UIStroke.Color = Color3.fromRGB(77, 84, 84)
        UpgradeViewSelectBtn.SelectText.Text = "Completed"
    end

    UpgradeName.Text = upgradeName
    UpgradeDesc.Text = computerUpgradeConfig.Description

    -- style prog bar
    UpgradeViewProgBar.Size = UDim2.fromScale(upgradeProgress / upgradeGoalValue, 1)
    UpgradeViewProgText.Text = upgradeGoalProgressText:gsub("CURR", FormatNumber.FormatCompact(upgradeProgress)):gsub("REQUIRED", FormatNumber.FormatCompact(upgradeGoalValue))
end

local function styleUpgradeBtn(upgradeBtnContainer: Frame, upgradeName: string)
    local plrCurrentComputerLvl: number = plrData.GameDev.Computer.Level
    local plrActiveUpgrade = plrData.GameDev.Computer.ActiveUpgrade
    local plrUpgradeData = plrData.GameDev.Computer.UpgradeProgress[plrCurrentComputerLvl][upgradeName]

    local upgradeBtn: TextButton = upgradeBtnContainer.Template
    local upgradeBtnUIStroke: UIStroke = upgradeBtn.UIStroke
    local upgradeBtnIconDropshadow: ImageLabel = upgradeBtn.Icon.IconDropshadow
    local upgradeTemplateCheckIcon: ImageLabel = upgradeBtn.CheckIcon
    upgradeTemplateCheckIcon.Visible = false

    -- display btn as incomplete & active (yellow)
    if plrActiveUpgrade == upgradeName then
        upgradeBtn.BackgroundColor3 = Color3.fromRGB(255, 237, 165)
        upgradeBtnUIStroke.Color = Color3.fromRGB(218, 173, 84)
        upgradeBtnIconDropshadow.ImageColor3 = Color3.fromRGB(218, 173, 84)
        upgradeBtnContainer.LayoutOrder = 0
        return
    end

    local upgradeProgress: number = plrUpgradeData.Progress
    local upgradeGoalValue: number = plrUpgradeData.Goal
    
    -- display btn as completed (green)
    if upgradeProgress >= upgradeGoalValue then
        upgradeBtn.BackgroundColor3 = Color3.fromRGB(213, 255, 193)
        upgradeBtnUIStroke.Color = Color3.fromRGB(99, 156, 81)
        upgradeBtnIconDropshadow.ImageColor3 = Color3.fromRGB(99, 156, 81)
        upgradeTemplateCheckIcon.Visible = true
        upgradeBtnContainer.LayoutOrder = -99 -- always display completed upgrades first

    -- display btn as incomplete & inactive (grey)
    else
        upgradeBtn.BackgroundColor3 = Color3.fromRGB(185, 184, 184)
        upgradeBtnUIStroke.Color = Color3.fromRGB(131, 130, 130)
        upgradeBtnIconDropshadow.ImageColor3 = Color3.fromRGB(131, 130, 130)
        upgradeBtnContainer.LayoutOrder = 99 -- always display incomplete & inactive upgrades last
    end
end

local function populateComputerUpgrades(computerConfigInformation: ComputerConfig.ComputerConfig)
    for upgradeName: string, upgradeInfo: ComputerConfig.ComputerUpgradeConfig in computerConfigInformation.Upgrades do
        local upgradeTemplateContainer: Frame = UpgradesTemplateContainer:Clone()
        local upgradeTemplateBtn: TextButton = upgradeTemplateContainer.Template
        local upgradeTemplateIcon: ImageLabel = upgradeTemplateBtn.Icon
        local upgradeTemplateIconDropshadow: ImageLabel = upgradeTemplateIcon.IconDropshadow

        upgradeTemplateContainer.Name = upgradeName

        GuiTemplates.CreateButton(upgradeTemplateBtn, { Rotates = true })

        if upgradeInfo.Stat == "coins" then
            upgradeTemplateIcon.Image = GeneralUtils.GetDecalUrl(GlobalVariables.Images.Icons.CoinBundleSmallStroke)
            upgradeTemplateIconDropshadow.Image = GeneralUtils.GetDecalUrl(GlobalVariables.Images.Icons.CoinBundleSmallDropshadow)
            
        elseif upgradeInfo.Stat == "code" then
            -- upgradeTemplateIcon.Image = GeneralUtils.GetDecalUrl("")
            -- upgradeTemplateIconDropshadow.Image = GeneralUtils.GetDecalUrl("")

        elseif upgradeInfo.Stat == "sound" then
            -- upgradeTemplateIcon.Image = GeneralUtils.GetDecalUrl("")
            -- upgradeTemplateIconDropshadow.Image = GeneralUtils.GetDecalUrl("")

        elseif upgradeInfo.Stat == "art" then
            -- upgradeTemplateIcon.Image = GeneralUtils.GetDecalUrl("")
            -- upgradeTemplateIconDropshadow.Image = GeneralUtils.GetDecalUrl("")

        end

        styleUpgradeBtn(upgradeTemplateContainer, upgradeName)
        
        upgradeTemplateBtn.Activated:Connect(function()
            currentlyViewedComputerUpgrade = upgradeName
            populateSpecificComputerUpgradeView(upgradeName)
            RequirementsView.Visible = false
            UpgradeView.Visible = true
        end)

        upgradeTemplateContainer.Parent = UpgradesContainer
        upgradeTemplateContainer.Visible = true
    end
end

local function clearUpgradeBtns()
    local instancesToIgnore = {"UIListLayout", "TemplateContainer"}

    for _i, instance in UpgradesContainer:GetChildren() do
        if table.find(instancesToIgnore, instance.Name) then continue end

        instance:Destroy()
    end
end

local function clearMaterialRequirementsDisplay()
    local instancesToIgnore = {"UIListLayout", "Template"}

    for _i, instance in MaterialsContainer:GetChildren() do
        if table.find(instancesToIgnore, instance.Name) then continue end

        instance:Destroy()
    end
end

local function setupComputerTemplate(computerTemplate: Frame, status: "completed" | "inprogress", computerConfigInformation: ComputerConfig.ComputerConfig)
    -- clear upgrade btns & required material displays from previous viewing of this GUI, if any
    clearUpgradeBtns()
    clearMaterialRequirementsDisplay()

    if status == "completed" then
        local computerIcon: ImageLabel = computerTemplate.ComputerIcon
        local computerIconDropshadow: ImageLabel = computerIcon.ComputerIconDropshadow
        computerIcon.Image = GeneralUtils.GetDecalUrl(computerConfigInformation.IconStroke)
        computerIconDropshadow.Image = GeneralUtils.GetDecalUrl(computerConfigInformation.IconFill)
    
    elseif status == "inprogress" then
        currentlyViewedComputerUpgrade = nil
        RequirementsView.Visible = true
        UpgradeView.Visible = false
        
        -- requirements view
        InProgComputerIcon.Image = GeneralUtils.GetDecalUrl(computerConfigInformation.IconStroke)
        InProgComputerIconDropshadow.Image = GeneralUtils.GetDecalUrl(computerConfigInformation.IconFill)
        InProgComputerName.Text = computerConfigInformation.Name

        -- -- materials container
        for materialName: string, amountRequired: number in computerConfigInformation.Materials do
            local materialConfig: MaterialsConfig.MaterialConfig = MaterialsConfig.GetConfig(materialName)

            local materialTemplate = MaterialsContainerTemplate:Clone()
            local materialIcon: ImageLabel = materialTemplate.MaterialIcon
            local materialDropshadow: ImageLabel = materialIcon.MaterialIconDropshadow
            materialIcon.Image = GeneralUtils.GetDecalUrl(materialConfig.IconStroke)
            materialDropshadow.Image = GeneralUtils.GetDecalUrl(materialConfig.IconFill)
            
            local materialAmountText: TextLabel = materialTemplate.MaterialAmt
            local plrCurrentMaterialAmt: number = plrData.Inventory.Materials[materialName].Amount
            local requiredMaterialAmt: number = computerConfigInformation.Materials[materialName]
            materialAmountText.Text = materialRequirementText:gsub("CURR", plrCurrentMaterialAmt):gsub("REQUIRED", requiredMaterialAmt)

            -- style text
            if plrCurrentMaterialAmt < requiredMaterialAmt then
                materialAmountText.TextColor3 = Color3.fromRGB(255, 185, 185)
                materialAmountText:FindFirstChild("UIStroke").Color = Color3.fromRGB(177, 92, 90)
            else
                materialAmountText.TextColor3 = Color3.fromRGB(192, 255, 188)
                materialAmountText:FindFirstChild("UIStroke").Color = Color3.fromRGB(88, 147, 70)
            end

            materialTemplate.Name = materialName
            materialTemplate.Parent = MaterialsContainer
            materialTemplate.LayoutOrder = -amountRequired
            materialTemplate.Visible = true
        end

        selectBtnConnection = UpgradeViewSelectBtn.Activated:Connect(function()
            Remotes.GameDev.Computer.ChangeActiveComputerUpgrade:FireServer(currentlyViewedComputerUpgrade)
        end)

        backBtnConnection = UpgradeViewBackBtn.Activated:Connect(function()
            -- before making requirementsView visible again, restyle & reorder upgrade btns
            local instancesToIgnore = {"UIListLayout", "TemplateContainer"}
            for _i, instance in RequirementsView.UpgradesContainer:GetChildren() do
                if table.find(instancesToIgnore, instance.Name) then continue end

                styleUpgradeBtn(instance, instance.Name)
            end

            currentlyViewedComputerUpgrade = nil
            RequirementsView.Visible = true
            UpgradeView.Visible = false
        end)

        -- -- upgrades container
        populateComputerUpgrades(computerConfigInformation)
    end
end

local function clearScrollingFrame()
    local instancesToIgnore = {"UIListLayout", "UIPadding", "CompletedTemplate", "InProgressTemplate", "LockedTemplate"}

    for _i, instance in ScrollingFrame:GetChildren() do
        if table.find(instancesToIgnore, instance.Name) then continue end

        instance:Destroy()
    end
end

local function populateScrollingFrame()
    local plrComputerLevel = plrData.GameDev.Computer.Level

    local scrollingFrameTemplate

    clearScrollingFrame()
    for computerLevel: number, computerInformation: ComputerConfig.ComputerConfig in ComputerConfig.Config do
        if plrComputerLevel > computerLevel then
            scrollingFrameTemplate = CompletedTemplate:Clone()
            setupComputerTemplate(scrollingFrameTemplate, "completed", computerInformation)
            scrollingFrameTemplate.Name = computerLevel

        elseif plrComputerLevel == computerLevel then
            scrollingFrameTemplate = InprogressTemplate
            setupComputerTemplate(scrollingFrameTemplate, "inprogress", computerInformation)
        else
            scrollingFrameTemplate = LockedTemplate:Clone()
            GuiTemplates.CreateButton(scrollingFrameTemplate.LockIcon, { Rotates = true })
            scrollingFrameTemplate.Name = computerLevel
        end

        scrollingFrameTemplate.Parent = ScrollingFrame
        scrollingFrameTemplate.LayoutOrder = computerLevel
        scrollingFrameTemplate.Visible = true
    end
end

local function populateComputerUpgradeGui()
    -- computer buff section
    local computerBuffs = ComputerConfig.GetComputerBuffs(plrData)
    CoinsBuffText.Text = `Coins: <font color="#fff352"><stroke color="#d9a414" thickness="2">+{computerBuffs.CoinsBuff * 100}%</stroke></font>`
    CodePtsBuffText.Text = `Code Points: <font color="#fff352"><stroke color="#d9a414" thickness="2">+{computerBuffs.CodePtsBuff * 100}%</stroke></font>`
    SoundPtsBuffText.Text = `Sound Points: <font color="#fff352"><stroke color="#d9a414" thickness="2">+{computerBuffs.SoundPtsBuff * 100}%</stroke></font>`
    ArtPtsBuffText.Text = `Art Points: <font color="#fff352"><stroke color="#d9a414" thickness="2">+{computerBuffs.ArtPtsBuff * 100}%</stroke></font>`

    -- scrolling frame
    populateScrollingFrame()

    -- computer upgrade btn
    local canLevelUpComputer: boolean = ComputerConfig.AllAvailableComputerUpgradesCompleted(plrData)
    LevelUpComputerBtn.Visible = canLevelUpComputer
end

local function prepareComputerUpgradeGui()
    studioPcModel = Workspace.TempAssets.Studios:FindFirstChild("Computer", true)
    local studioPcModelComputer = studioPcModel:FindFirstChild("Pc")

    local cameraPosCFrame: CFrame = studioPcModel.PrimaryPart.CFrame + (-studioPcModel.PrimaryPart.CFrame.RightVector * 2.5) +  (-studioPcModel.PrimaryPart.CFrame.LookVector * 2) + (studioPcModel.PrimaryPart.CFrame.UpVector * 2)
    local cameraLookAtCFrame: CFrame = studioPcModelComputer.PrimaryPart.CFrame + (-studioPcModelComputer.PrimaryPart.CFrame.LookVector * 2)

    CameraControls.FocusOnObject(localPlr, camera, cameraPosCFrame, cameraLookAtCFrame, true, true)
    PlayerServices.HidePlayer(localPlr, true)

    GuiServices.HideHUD({ HideGuiFrames = true })

    populateComputerUpgradeGui()

    GuiServices.ShowGuiStandard(ComputerUpgradeContainer)
end

local function displayNewComputer(newComputerLevel: number, oldComputerSetupModel: Model)
    local newComputerModel: Model = ComputerConfig.GetComputerModel(newComputerLevel)
    if not newComputerModel then return end

    newComputerModel.Name = "Computer"

    local oldComputerModelCFrame: CFrame = oldComputerSetupModel.PrimaryPart.CFrame

    GuiServices.TriggerFlashFrame()
    newComputerModel:PivotTo(oldComputerModelCFrame)
    oldComputerSetupModel:Destroy()

    newComputerModel.Parent = Workspace.TempAssets.Studios:FindFirstChild("Interior", true)
    studioPcModel = newComputerModel
end

local function populateUpgradedComputerGui()

end

-- this function is called upon the computer being levelled up
local function prepareComputerLevelupGui(newComputerLevel: number)
    studioPcModel = Workspace.TempAssets.Studios:FindFirstChild("Computer", true)
    local studioPcModelComputer: Model = studioPcModel:FindFirstChild("Pc")

    local cameraPosCFrame: CFrame = studioPcModel.PrimaryPart.CFrame + (-studioPcModel.PrimaryPart.CFrame.RightVector * 2.5) +  (-studioPcModel.PrimaryPart.CFrame.LookVector * 2) + (studioPcModel.PrimaryPart.CFrame.UpVector * 2)
    local cameraLookAtCFrame: CFrame = studioPcModelComputer.PrimaryPart.CFrame + (-studioPcModelComputer.PrimaryPart.CFrame.LookVector * 2)

    CameraControls.FocusOnObject(localPlr, camera, cameraPosCFrame, cameraLookAtCFrame, true, true)
    PlayerServices.HidePlayer(localPlr, true)

    GuiServices.HideHUD({ HideGuiFrames = true })

    -- disable studio interaction btns
    Remotes.Studio.General.DisableInteractionBtns:Fire()

    populateUpgradedComputerGui()

    GuiServices.ShowGuiStandard(ComputerUpgradeContainer)

    task.wait(1)
    displayNewComputer(newComputerLevel, studioPcModel)
end

-- BTN ACTIVATIONS --
ExitBtn.Activated:Connect(function()
    resetVariablesAndConnections()
    
    GuiServices.HideGuiStandard(ComputerUpgradeContainer)
    PlayerServices.ShowPlayer(localPlr, true)
    CameraControls.SetDefault(localPlr, camera, true)
    GuiServices.ShowHUD()
    Remotes.Studio.General.EnableInteractionBtns:Fire()
end)

LevelUpComputerBtn.Activated:Connect(function()
    Remotes.GameDev.Computer.LevelUpComputer:FireServer()
end)

-- REMOTES --
Remotes.GUI.ChangeGuiStatusBindable.Event:Connect(function(guiName, showGui, _options)
    if guiName == "upgradeComputer" then
        plrData = Remotes.Data.GetAllData:InvokeServer()
    
        if showGui then
            prepareComputerUpgradeGui()
        end
    end
end)

Remotes.GameDev.Computer.ChangeActiveComputerUpgrade.OnClientEvent:Connect(function(upgradeName: string)
    plrData = Remotes.Data.GetAllData:InvokeServer() -- refresh plr data

    if upgradeName == currentlyViewedComputerUpgrade then
        UpgradeViewSelectBtn.BackgroundColor3 = Color3.fromRGB(97, 234, 76)
        UpgradeViewSelectBtn.UIStroke.Color = Color3.fromRGB(56, 134, 44)
        UpgradeViewSelectBtn.SelectText.UIStroke.Color = Color3.fromRGB(56, 134, 44)
        UpgradeViewSelectBtn.SelectText.Text = "Active"
    end
end)

Remotes.GameDev.Computer.LevelUpComputer.OnClientEvent:Connect(prepareComputerLevelupGui)