local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))
local GlobalVariables = require(ReplicatedStorage.GlobalVariables)
local StudioConfig = require(ReplicatedStorage.Configs:WaitForChild("Studio"))
local HungerFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("HungerFurniture"))
local EnergyFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("EnergyFurniture"))
local MoodFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("MoodFurniture"))
local DecorFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("DecorFurniture"))

local Remotes = ReplicatedStorage.Remotes
local furnitureModelFolder = ReplicatedStorage.Assets.Models.StudioFurnishing

local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui

-- GUI REFERENCE VARIABLES
local LeftSideContainer = PlayerGui:WaitForChild("Left"):WaitForChild("LeftBtnContainer")
local StudioTeleportBtn = LeftSideContainer.StudioTpBtn
local StudioBuildModeBtn = LeftSideContainer.StudioBuildModeBtn

local PlrInfoContainer = PlayerGui:WaitForChild("Left"):WaitForChild("PlrInfoContainer")

local RightSideContainer = PlayerGui:WaitForChild("Right"):WaitForChild("RightBtnContainer")
local PlrStudiosBtn = RightSideContainer.PlrStudiosBtn

local StudioListContainer = PlayerGui:WaitForChild("Studios"):WaitForChild("StudioListContainer")
local StudioListExitBtn = StudioListContainer.ExitBtn
local StudioListScrollingFrame = StudioListContainer.ScrollingFrame
local StudioListScrollingFrameTemplate = StudioListScrollingFrame:WaitForChild("Template")
local StudioWhitelistBtn = StudioListContainer.StudioSettings.WhitelistBtn
local StudioKickAllBtn = StudioListContainer.StudioSettings.KickBtn

local StudioBuildModeContainer = PlayerGui:WaitForChild("BuildMode"):WaitForChild("BuildModeContainer")
local BuildModeHeader = StudioBuildModeContainer.Header
local BuildModeCategoryContainer = BuildModeHeader.CategoryButtons
local MoodCategoryBtn = BuildModeCategoryContainer:WaitForChild("MoodCategoryBtn")
local EnergyCategoryBtn = BuildModeCategoryContainer:WaitForChild("EnergyCategoryBtn")
local HungerCategoryBtn = BuildModeCategoryContainer:WaitForChild("HungerCategoryBtn")
local DecorCategoryBtn = BuildModeCategoryContainer:WaitForChild("DecorCategoryBtn")
local BuildModeDeleteModeBtn = BuildModeHeader:WaitForChild("DeleteModeBtn")
local BuildModeExitBtn = BuildModeHeader:WaitForChild("ExitBtn")
local BuildModeShopBtn = BuildModeHeader:WaitForChild("ShopBtn")

local BuildModeItemViewport = StudioBuildModeContainer.ItemDisplay.ItemDisplayViewport
local NeedItemTemplate = BuildModeItemViewport:WaitForChild("NeedItemTemplate")
local DecoItemTemplate = BuildModeItemViewport:WaitForChild("DecoItemTemplate")
local SelectCategoryText = StudioBuildModeContainer.ItemDisplay:WaitForChild("SelectCategory")


-- GUI PROPERTY VARIABLES
local visibleGuiPos: UDim2 = StudioListContainer.Position
local visibleGuiSize: UDim2 = StudioListContainer.Size

local leftSideContainerVisiblePos: UDim2 = LeftSideContainer.Position
local leftSideContainerVisibleSize: UDim2 = LeftSideContainer.Size

local rightSideContainerVisiblePos: UDim2 = RightSideContainer.Position
local rightSideContainerVisibleSize: UDim2 = RightSideContainer.Size

local plrInfoContainerVisiblePos: UDim2 = PlrInfoContainer.Position
local plrInfoContainerVisibleSize: UDim2 = PlrInfoContainer.Size

local studioBuildModeVisiblePos: UDim2 = StudioBuildModeContainer.Position
local studioBuildModeHiddenPos: UDim2 = UDim2.fromScale(0.5, 1.25)


-- STATIC VARIABLES
local WHITELIST_BTN_TEXT_TEMPLATE = "Studio: SETTING"
local ITEM_STAT_TEXT_TEMPLATE = "+AMT/sec"
local ITEM_AMOUNT_TEXT_TEMPLATE = "xAMT"
local KICK_PLRS_COOLDOWN = 1 -- seconds


-- STATE VARIABLES
local char = localPlr.Character or localPlr.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local selectedBuildModeCategory = nil
local studioFurnitureInventory = nil

-- hide buildmode gui by default
StudioBuildModeContainer.Visible = false
StudioBuildModeContainer.Position = studioBuildModeHiddenPos

-- stores Activated connections for when visit buttons get clicked
-- { [userId] = connection }
local visitBtnConnections = {}

-- stores Activated connections for when build-mode viewport items get clicked
-- { [viewportItemInstance] = connection }
local buildModeItemConnections = {}

GuiServices.DefaultMainGuiStyling(StudioListContainer, GlobalVariables.Gui.MainGuiInvisiblePosOffset)

local function getPlrNameFromUserId(userId: number)
    local username = nil
    local success, errorMsg = pcall(function()
        username = Players:GetNameFromUserIdAsync(userId)
    end)
    return username
end

local function getPlrIconImage(userId: number, thumbType: Enum.ThumbnailType, thumbSize: Enum.ThumbnailSize)
    local iconImg = nil
    local success, errorMsg = pcall(function()
        iconImg = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
    end)
    return iconImg
end

local function getPlrStudioName(studioIndex: number)
    local studioConfig = StudioConfig.GetConfig(studioIndex)
    return studioConfig.Name
end

local function setStudioVisitBtn(visitBtn, plrStudioStatus)
    if plrStudioStatus == "open" then
        visitBtn.BackgroundColor3 = Color3.fromRGB(70, 184, 255)
        visitBtn.Text = "Visit Studio"

    elseif plrStudioStatus == "closed" then
        visitBtn.BackgroundColor3 = GlobalVariables.Gui.InvalidRedColour
        visitBtn.Text = "Studio closed"
    
    elseif plrStudioStatus == "friends" then
        visitBtn.BackgroundColor3 = GlobalVariables.Gui.InvalidGreyColour
        visitBtn.Text = "Friends only"
    end
end

local function registerStudioVisitBtnListener(visitBtn, userIdOfPlrToVisit)
    local connection = visitBtn.Activated:Connect(function()
        Remotes.Studio.VisitOtherStudio:FireServer(userIdOfPlrToVisit)
    end)
    return connection
end

local function removeStudioListItem(userId: number)
    local instance = StudioListScrollingFrame:FindFirstChild(tostring(userId))
    instance:Destroy()

    -- disconnect and remove connection if any
    local visitBtnConnection = visitBtnConnections[userId]
    if visitBtnConnection then
        visitBtnConnections[userId]:Disconnect()
        visitBtnConnections[userId] = nil
    end
end

local function clearStudioList()
    for _i, instance in StudioListScrollingFrame:GetChildren() do
        if instance.Name == "Template" or instance.Name == "UIListLayout" then continue end

        removeStudioListItem(tonumber(instance.Name))
    end
end

local function createStudioListItem(userId: number, userStudioInfo)
    local template = StudioListScrollingFrameTemplate:clone()
    local plrNameText = template:FindFirstChild("PlrName")
    local plrIconImage = template:FindFirstChild("PlrIcon")
    local studioNameText = template:FindFirstChild("StudioName")
    local visitBtn = template:FindFirstChild("VisitBtn")
    
    template.Name = tostring(userId)
    studioNameText.Text = getPlrStudioName(userStudioInfo.StudioIndex)
    
    local plrName = getPlrNameFromUserId(userId)
    local plrIcon = getPlrIconImage(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    if not plrName or not plrIcon then
        return
    end
    plrNameText.Text = plrName
    plrIconImage.Image = plrIcon

    setStudioVisitBtn(visitBtn, userStudioInfo.StudioStatus)
    visitBtnConnections[userId] = registerStudioVisitBtnListener(visitBtn, userId)

    template.Visible = true
    template.Parent = StudioListScrollingFrame
end

local function populateStudioList()
    local studioPlrInfo = Remotes.Studio.GetStudioPlrInfo:InvokeServer()

    for userId, userStudioInfo in studioPlrInfo do
        -- don't show players own studio on the list
        if tonumber(userId) == localPlr.UserId then continue end

        createStudioListItem(userId, userStudioInfo)
    end
end

local function updateStudioListItem(userIdToUpdate: number, updateStatus: "add" | "remove" | "update", userStudioInfo)
    if updateStatus == "add" then
        createStudioListItem(userIdToUpdate, userStudioInfo)

    elseif updateStatus == "remove" then
        removeStudioListItem(userIdToUpdate)
    
    elseif updateStatus == "update" then
        local studioInfoFrame = StudioListScrollingFrame:FindFirstChild(tostring(userIdToUpdate))
        if not studioInfoFrame then return end

        local studioNameText = studioInfoFrame:FindFirstChild("StudioName")
        local visitBtn = studioInfoFrame:FindFirstChild("VisitBtn")
    
        -- disconnect old connection if any and replace
        local visitBtnConnection = visitBtnConnections[userIdToUpdate]
        if visitBtnConnection then
            visitBtnConnections[userIdToUpdate]:Disconnect()
            visitBtnConnections[userIdToUpdate] = registerStudioVisitBtnListener(visitBtn, userIdToUpdate)
        end
    
        setStudioVisitBtn(visitBtn, userStudioInfo.StudioStatus)
        studioNameText.Text = getPlrStudioName(userStudioInfo.StudioIndex)
    end
end

local function updateWhitelistBtn(whitelistSetting: "open" | "closed" | "friends")
    if whitelistSetting == "open" then
        StudioWhitelistBtn.BackgroundColor3 = GlobalVariables.Gui.ValidGreenColour
        StudioWhitelistBtn.Text = WHITELIST_BTN_TEXT_TEMPLATE:gsub("SETTING", "Open")

    elseif whitelistSetting == "closed" then
        StudioWhitelistBtn.BackgroundColor3 = GlobalVariables.Gui.InvalidRedColour
        StudioWhitelistBtn.Text = WHITELIST_BTN_TEXT_TEMPLATE:gsub("SETTING", "Closed")

    elseif whitelistSetting == "friends" then
        StudioWhitelistBtn.BackgroundColor3 = GlobalVariables.Gui.CantAffordColour
        StudioWhitelistBtn.Text = WHITELIST_BTN_TEXT_TEMPLATE:gsub("SETTING", "Friends")

    end
end

local function showBuildModeGui()
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    StudioBuildModeContainer.Visible = true

    local buildModeTween = TweenService:Create(StudioBuildModeContainer, tweenInfo, { Position = studioBuildModeVisiblePos })
    buildModeTween:Play()
end

local function hideBuildModeGui()
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

    local buildModeTween = TweenService:Create(StudioBuildModeContainer, tweenInfo, { Position = studioBuildModeHiddenPos })
    buildModeTween:Play()
end

local function setupBuildModeGui()
    -- hide unrelated gui
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    local hideLeftGuiTween = TweenService:Create(LeftSideContainer, tweenInfo, { Position = UDim2.fromScale(-leftSideContainerVisibleSize.X.Scale, leftSideContainerVisiblePos.Y.Scale) })
    local hideRightGuiTween = TweenService:Create(RightSideContainer, tweenInfo, { Position = UDim2.fromScale(rightSideContainerVisibleSize.X.Scale + 1, rightSideContainerVisiblePos.Y.Scale) })
    local hidePlrInfoTween = TweenService:Create(PlrInfoContainer, tweenInfo, { Position = UDim2.fromScale(-plrInfoContainerVisibleSize.X.Scale, plrInfoContainerVisiblePos.Y.Scale) })
    
    hideLeftGuiTween:Play()
    hideLeftGuiTween.Completed:Connect(function(_playbackState) LeftSideContainer.Visible = false end)

    hideRightGuiTween:Play()
    hideRightGuiTween.Completed:Connect(function(_playbackState) RightSideContainer.Visible = false end)
    
    hidePlrInfoTween:Play()
    hidePlrInfoTween.Completed:Connect(function(_playbackState) PlrInfoContainer.Visible = false end)
    
    showBuildModeGui()
    
    BuildModeItemViewport.Visible = false
    SelectCategoryText.Visible = true
end

local function disableBuildModeGui()
    -- show unrelated gui
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    local showLeftGuiTween = TweenService:Create(LeftSideContainer, tweenInfo, { Position = leftSideContainerVisiblePos })
    local showRightGuiTween = TweenService:Create(RightSideContainer, tweenInfo, { Position = rightSideContainerVisiblePos })
    local showPlrInfoTween = TweenService:Create(PlrInfoContainer, tweenInfo, { Position = plrInfoContainerVisiblePos })
    
    LeftSideContainer.Visible = true
    RightSideContainer.Visible = true
    PlrInfoContainer.Visible = true
    
    showLeftGuiTween:Play()
    showRightGuiTween:Play()
    showPlrInfoTween:Play()

    hideBuildModeGui()
end

local function clearBuildModeViewport()
    for _i, instance in BuildModeItemViewport:GetChildren() do
        if instance.Name == 'UIListLayout' or instance.Name == 'UIPadding' or instance.Name == 'DecoItemTemplate' or instance.Name == 'NeedItemTemplate' then continue end

        -- disconnect old connection if any and replace
        local itemBtnConnection = buildModeItemConnections[instance]
        if itemBtnConnection then
            buildModeItemConnections[instance]:Disconnect()
        end
        instance:Destroy()
    end
end

local function registerBuildModeItemListener(itemBtn, itemCategory)
    local connection = itemBtn.Activated:Connect(function()
        -- check that plr actually has item on server
        local itemName = itemBtn.Name
        Remotes.Studio.EnterPlaceMode:FireServer(itemName, itemCategory)
    end)
    return connection
end

local function createViewportItem(category: "Mood" | "Energy" | "Hunger" | "Decor", itemName: string, numOfItems: number)
    local template
    if category == "Decor" then template = DecoItemTemplate:Clone() else template = NeedItemTemplate:Clone() end
    template.Name = itemName
    local itemNameText = template:FindFirstChild("ItemName")
    itemNameText.Text = itemName
    local itemAmountText = template:FindFirstChild("ItemAmount")
    itemAmountText.Text = ITEM_AMOUNT_TEXT_TEMPLATE:gsub("AMT", numOfItems)

    local itemModel

    if category ~= "Decor" then
        local itemStatsText = template:FindFirstChild("ItemStats")
        local config
        if category == "Mood" then
            itemModel = MoodFurnitureConfig.GetModel(itemName)
            config = MoodFurnitureConfig.GetConfig(itemName)
            itemStatsText.Text = ITEM_STAT_TEXT_TEMPLATE:gsub("AMT", config.MoodPerSec)

        elseif category == "Energy" then
            itemModel = EnergyFurnitureConfig.GetModel(itemName)
            config = EnergyFurnitureConfig.GetConfig(itemName)
            itemStatsText.Text = ITEM_STAT_TEXT_TEMPLATE:gsub("AMT", config.EnergyPerSec)

        elseif category == "Hunger" then
            itemModel = HungerFurnitureConfig.GetModel(itemName)
            config = HungerFurnitureConfig.GetConfig(itemName)
            itemStatsText.Text = ITEM_STAT_TEXT_TEMPLATE:gsub("AMT", config.HungerPerSec)
        end
    else
        itemModel = DecorFurnitureConfig.GetModel(itemName)
    end

    if itemModel then
        local viewportFrame = template:FindFirstChild("ViewportFrame")
        local viewportCamera = Instance.new("Camera", viewportFrame)
        GuiServices.GenerateViewportFrame(viewportFrame, viewportCamera, itemModel, Vector3.new(-6, 4, 3))
    end

    buildModeItemConnections[template] = registerBuildModeItemListener(template, category)
    template.Visible = true

    return template
end

local function populateItemDisplay(category: "Mood" | "Energy" | "Hunger" | "Decor")
    if studioFurnitureInventory then
        for itemName, itemInstances in studioFurnitureInventory[category] do
            local numOfInstances = #itemInstances
            if numOfInstances <= 0 then continue end

            local viewportItem = createViewportItem(category, itemName, numOfInstances)
            viewportItem.Parent = BuildModeItemViewport
        end
    end
end

local function setupItemDisplay(category: "Mood" | "Energy" | "Hunger" | "Decor")
    clearBuildModeViewport()
    populateItemDisplay(category)
    SelectCategoryText.Visible = false
    BuildModeItemViewport.Visible = true
end

-- switches between the left-side studio btns (visit studio btn & build mode btn)
local function switchStudioBtns(btnToHide, btnToShow)
    btnToHide.Visible = false
    btnToShow.Visible = true
end

humanoid.Died:Connect(function()
    localPlr:SetAttribute("IsAlive", false)
end)

localPlr.CharacterAdded:Connect(function(character: Model)
    localPlr:SetAttribute("IsAlive", true)
    char = character
    humanoid = char:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        localPlr:SetAttribute("IsAlive", false)
    end)
end)

-- BUTTON ACTIVATE EVENTS
local tpDebounce = true
StudioTeleportBtn.Activated:Connect(function()
    if tpDebounce and localPlr:GetAttribute("IsAlive") then
        tpDebounce = false
        Remotes.Studio.VisitOwnStudio:FireServer()
        task.wait(1)
        tpDebounce = true
    end
end)

local buildModeDebounce = true
StudioBuildModeBtn.Activated:Connect(function()
    if buildModeDebounce then
        buildModeDebounce = false
        setupBuildModeGui()
        Remotes.Studio.EnterBuildMode:FireServer()
        
        task.wait(2)
        buildModeDebounce = true
    end
end)

PlrStudiosBtn.Activated:Connect(function()
    clearStudioList()
    populateStudioList()
    GuiServices.ShowGuiStandard(StudioListContainer, visibleGuiPos, visibleGuiSize, GlobalVariables.Gui.GuiBackdropColourDefault)
end)

StudioListExitBtn.Activated:Connect(function()
    GuiServices.HideGuiStandard(StudioListContainer, UDim2.new(visibleGuiPos.X.Scale, 0, visibleGuiPos.Y.Scale + GlobalVariables.Gui.MainGuiInvisiblePosOffset, 0), UDim2.new(visibleGuiSize.X.Scale, 0, visibleGuiSize.Y.Scale - 0.2, 0))
end)

StudioWhitelistBtn.Activated:Connect(function()
    Remotes.Studio.UpdateWhitelist:FireServer()
end)

local kickAllDebounce = true
StudioKickAllBtn.Activated:Connect(function()
    if kickAllDebounce then
        kickAllDebounce = false
        Remotes.Studio.KickFromStudio:FireServer()
        StudioKickAllBtn.BackgroundColor3 = GlobalVariables.Gui.InvalidGreyColour
        StudioKickAllBtn.Text = "Wait..."
        task.wait(KICK_PLRS_COOLDOWN)
        kickAllDebounce = true
        StudioKickAllBtn.BackgroundColor3 = GlobalVariables.Gui.InvalidRedColour
        StudioKickAllBtn.Text = "Kick players"
    end
end)

MoodCategoryBtn.Activated:Connect(function()
    if studioFurnitureInventory then
        setupItemDisplay("Mood")
    end
end)

EnergyCategoryBtn.Activated:Connect(function()
    if studioFurnitureInventory then
        setupItemDisplay("Energy")
    end
end)

HungerCategoryBtn.Activated:Connect(function()
    if studioFurnitureInventory then
        setupItemDisplay("Hunger")
    end
end)

DecorCategoryBtn.Activated:Connect(function()
    if studioFurnitureInventory then
        setupItemDisplay("Decor")
    end
end)

-- local buildModeExitDebounce = true
BuildModeExitBtn.Activated:Connect(function()
    disableBuildModeGui()
end)


-- REMOTE EVENTS
Remotes.Studio.VisitOwnStudio.OnClientEvent:Connect(function(_plr, _studioIndex, _interiorPlayerTpPart, _exteriorPlayerTpPart, _placedFurnitureData)
    task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
        switchStudioBtns(StudioTeleportBtn, StudioBuildModeBtn)
    end)
end)

Remotes.Studio.VisitOtherStudio.OnClientEvent:Connect(function(_studioIndex, _interiorPlrTpPart, _exteriorPlrTpPart)
    GuiServices.HideGuiStandard(StudioListContainer, UDim2.new(visibleGuiPos.X.Scale, 0, visibleGuiPos.Y.Scale + GlobalVariables.Gui.MainGuiInvisiblePosOffset, 0), UDim2.new(visibleGuiSize.X.Scale, 0, visibleGuiSize.Y.Scale - 0.2, 0))
end)

Remotes.Studio.LeaveStudio.OnClientEvent:Connect(function()
    task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
        switchStudioBtns(StudioBuildModeBtn, StudioTeleportBtn)
    end)
end)

Remotes.GUI.Studio.UpdateStudioList.OnClientEvent:Connect(function(userIdToUpdate: number, updateStatus: "add" | "remove" | "update", userStudioInfo)
    updateStudioListItem(userIdToUpdate, updateStatus, userStudioInfo)
end)

Remotes.Studio.UpdateWhitelist.OnClientEvent:Connect(function(newWhitelistSetting)
    updateWhitelistBtn(newWhitelistSetting)
end)

-- when plr enters build mode, save furniture inventory data to variable
Remotes.Studio.EnterBuildMode.OnClientEvent:Connect(function(studioInventoryData)
    studioFurnitureInventory = studioInventoryData
end)

-- when plr enters place mode, hide build mode gui
Remotes.Studio.EnterPlaceMode.OnClientEvent:Connect(function(itemName: string, itemCategory: string)
    hideBuildModeGui()
end)

-- show build-mode gui again
Remotes.Studio.ExitPlaceMode.OnClientEvent:Connect(function(studioInventoryData)
    studioFurnitureInventory = studioInventoryData
    setupBuildModeGui()
end)