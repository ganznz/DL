local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local PlrPlatformManager = require(ReplicatedStorage:WaitForChild("PlrPlatformManager"))
local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))
local PlayerServices = require(ReplicatedStorage.Utils.Player:WaitForChild("Player"))
local GlobalVariables = require(ReplicatedStorage.GlobalVariables)
local CameraControls = require(ReplicatedStorage.Libs:WaitForChild("CameraControls"))
local StudioConfig = require(ReplicatedStorage.Configs.Studio:WaitForChild("Studio"))
local HungerFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("HungerFurniture"))
local EnergyFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("EnergyFurniture"))
local MoodFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("MoodFurniture"))
local DecorFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("DecorFurniture"))
local GenreConfig = require(ReplicatedStorage.Configs.GameDev:WaitForChild("Genre"))
local TopicConfig = require(ReplicatedStorage.Configs.GameDev:WaitForChild("Topic"))

local Remotes = ReplicatedStorage.Remotes
local furnitureModelFolder = ReplicatedStorage.Assets.Models.Studio.StudioFurnishing

local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui
local plrPlatformProfile = PlrPlatformManager.GetProfile(localPlr)
local camera = Workspace:WaitForChild("Camera")

-- GUI REFERENCE VARIABLES
local AllGuiScreenGui = PlayerGui:WaitForChild("AllGui")
local LeftScreenGui = AllGuiScreenGui.Hud:WaitForChild("Left")
local RightScreenGui = AllGuiScreenGui.Hud:WaitForChild("Right")

local LeftSideContainer = LeftScreenGui:WaitForChild("LeftBtnContainer")
local StudioTeleportBtn = LeftSideContainer.StudioTpBtn
local StudioBuildModeBtn = LeftSideContainer.StudioBuildModeBtn

local PlrInfoContainer = LeftScreenGui:WaitForChild("PlrInfoContainer")

local RightSideContainer = RightScreenGui:WaitForChild("RightBtnContainer")
local PlrStudiosBtn = RightSideContainer.PlrStudiosBtn

local StudioListContainer = AllGuiScreenGui.Studio:WaitForChild("StudioGeneral"):WaitForChild("StudioListContainer")
local StudioListExitBtn = StudioListContainer.ExitBtn
local StudioListScrollingFrame = StudioListContainer.ScrollingFrame
local StudioListScrollingFrameTemplate = StudioListScrollingFrame:WaitForChild("Template")
local StudioWhitelistBtn = StudioListContainer.StudioSettings.WhitelistBtn
local StudioKickAllBtn = StudioListContainer.StudioSettings.KickBtn

local StudioBuildModeContainer = AllGuiScreenGui.Studio:WaitForChild("StudioBuildMode"):WaitForChild("BuildModeContainer")
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

local ItemInteractionButtons = AllGuiScreenGui.Studio:WaitForChild("StudioBuildMode"):WaitForChild("ItemInteractionBtns")
local ItemInteractionBtnsPc = ItemInteractionButtons:WaitForChild("PcPlatform")
local ItemRotateBtnPc = ItemInteractionBtnsPc:WaitForChild("RotateBtn")
local ItemCancelBtnPc = ItemInteractionBtnsPc:WaitForChild("CancelBtn")
local ItemInteractionBtnsMobile = ItemInteractionButtons:WaitForChild("MobilePlatform")
local ItemRotateBtnMobile = ItemInteractionBtnsMobile:WaitForChild("RotateBtn")
local ItemCancelBtnMobile = ItemInteractionBtnsMobile:WaitForChild("CancelBtn")

local DeleteItemsPopup = AllGuiScreenGui.Studio.StudioBuildMode:WaitForChild("DeleteItemsPopup")
local DeleteItemsScrollingFrame = DeleteItemsPopup:WaitForChild("ScrollingFrame")
local DeleteItemsTemplate = DeleteItemsScrollingFrame:FindFirstChild("Template")
local DeleteItemsYesBtn = DeleteItemsPopup:FindFirstChild("YesBtn")
local DeleteItemsNoBtn = DeleteItemsPopup:FindFirstChild("NoBtn")
local DeleteItemsTotalRefundText = DeleteItemsPopup:FindFirstChild("TotalRefund")

local GenreTopicViewContainer = AllGuiScreenGui.Studio.StudioGeneral:WaitForChild("GenreTopicView")
local AllGenresTopicsContainer = GenreTopicViewContainer:WaitForChild("AllGenresTopics")
local GenresScrollingFrame = AllGenresTopicsContainer:WaitForChild("GenresContainer")
local TopicsScrollingFrame = AllGenresTopicsContainer:WaitForChild("TopicsContainer")
local GenreTopicTemplate = GenresScrollingFrame:WaitForChild("Template")
local GenreTopicViewExitBtn = AllGenresTopicsContainer:WaitForChild("ExitBtn")

local GenreTopicInfoDisplay = GenreTopicViewContainer:WaitForChild("GenreTopicInfoDisplay")
local GenreTopicInfoHeaderText = GenreTopicInfoDisplay:WaitForChild("HeaderText")
local GenreTopicInfoNoPerksText = GenreTopicInfoDisplay:WaitForChild("NoPerksPlaceholder")
local GenreTopicInfoLevelBarProg = GenreTopicInfoDisplay.LevelContainer.LevelBar:WaitForChild("LevelProg")
local GenreTopicInfoLevelText = GenreTopicInfoDisplay.LevelContainer:WaitForChild("LevelText")
local GenreTopicInfoLevelXp = GenreTopicInfoDisplay.LevelContainer:WaitForChild("LevelXp")
local GenreTopicInfoCompatibleText = GenreTopicInfoDisplay.CompatibilityInfo:WaitForChild("CompatibleText")
local GenreTopicInfoIncompatibleText = GenreTopicInfoDisplay.CompatibilityInfo:WaitForChild("IncompatibleText")
local GenreTopicInfoPerksContainer = GenreTopicInfoDisplay:WaitForChild("PerksContainer")
local GenreTopicInfoPerkTemplate = GenreTopicInfoPerksContainer:WaitForChild("Template")
local GenreTopicInfoBackBtn = GenreTopicViewContainer:WaitForChild("BackBtn")

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

local deleteItemsPopupVisiblePos: UDim2 = DeleteItemsPopup.Position
local deleteItemsPopupVisibleSize: UDim2 = DeleteItemsPopup.Size

local itemInteractionBtnContainerVisiblePos: UDim2 = ItemInteractionButtons.Position
local itemInteractionBtnContainerHiddenPos: UDim2 = UDim2.fromScale(0.5, 1.2)
local itemInteractionBtnContainerSize: UDim2 = ItemInteractionButtons.Size

local genreTopicViewVisiblePos: UDim2 = GenreTopicViewContainer.Position
local genreTopicViewVisibleSize: UDim2 = GenreTopicViewContainer.Size


-- STATIC VARIABLES
local WHITELIST_BTN_TEXT_TEMPLATE = "Studio: SETTING"
local ITEM_STAT_TEXT_TEMPLATE = "+AMT/sec"
local ITEM_AMOUNT_TEXT_TEMPLATE = "xAMT"
local DELETE_ITEM_CARD_NAME_TEMPLATE = "ITEM_NAME (xAMT)"
local DELETE_ITEM_CARD_REFUND_TEMPLATE = "+ AMT CURRENCY_TYPE"
local KICK_PLRS_COOLDOWN = 1 -- seconds


-- STATE VARIABLES
local plrData = Remotes.Data.GetAllData:InvokeServer()
local inBuildMode = false
local inPlaceMode = false
local viewingShelf = false
local char = localPlr.Character or localPlr.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local studioInteriorModel = nil
local studioFurnitureInventory = nil
local currentItemsToDelete = nil -- keeps track of what items have been added/removed when the delete items popup is visible
local currentViewedBook = nil -- when plr is viewing bookshelf, this holds cframe info for what book is 'pulled' from the shelf at a given time

-- set what item interaction btns are visible by default
ItemInteractionBtnsPc.Visible = plrPlatformProfile.Platform == "pc" and true or false
ItemInteractionBtnsMobile.Visible = plrPlatformProfile.Platform == "mobile" and true or false

-- hide item interaction btns by default
ItemInteractionButtons.Position = itemInteractionBtnContainerHiddenPos
ItemInteractionButtons.Visible = false

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
GuiServices.DefaultMainGuiStyling(DeleteItemsPopup, GlobalVariables.Gui.MainGuiInvisiblePosOffset)
GuiServices.CustomMainGuiStyling(GenreTopicViewContainer, 0.65, GlobalVariables.Gui.MainGuiInvisiblePosOffset)

local function getPlrStudioName(studioIndex: string)
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
        Remotes.Studio.General.VisitOtherStudio:FireServer(userIdOfPlrToVisit)
    end)
    return connection
end

local function removeStudioListItem(userId: number)
    local instance = StudioListScrollingFrame:FindFirstChild(tostring(userId))
    if instance then instance:Destroy() end

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
    
    local plrName = PlayerServices.GetPlrNameFromUserId(userId)
    local plrIcon = PlayerServices.GetPlrIconImage(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
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
    local studioPlrInfo = Remotes.Studio.General.GetStudioPlrInfo:InvokeServer()

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

-- itemType: "furniture" | "essential", itemInfo: {}, movingItem: boolean
local function registerBuildModeItemListener(itemBtn, itemCategory)
    local connection = itemBtn.Activated:Connect(function()
        local itemInfo = {
            ItemName = itemBtn.Name,
            ItemCategory = itemCategory
        }

        Remotes.Studio.BuildMode.EnterPlaceMode:FireServer("furniture", itemInfo, false)
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

local function clearDeleteItemsPopup()
    for _i, instance in DeleteItemsScrollingFrame:GetChildren() do
        if instance.Name == "UIListLayout" or instance.Name == "UIPadding" or instance.Name == "Template" then continue end
        instance:Destroy()
    end
end

local function createDeleteItemCard(itemCategory: string, itemName: string, amtOfItem: number, itemUUID: string)
    local template = DeleteItemsTemplate:Clone()
    local itemImage = template:FindFirstChild("ItemImage")
    local itemNameText = template:FindFirstChild("ItemName")
    local itemRefundText = template:FindFirstChild("ItemRefund")
    local removeBtn = template:FindFirstChild("RemoveBtn")

    template.Name = "DeleteItemCard"

    local config
    if itemCategory == "Mood" then
        config = MoodFurnitureConfig
    elseif itemCategory == "Energy" then
        config = EnergyFurnitureConfig
    elseif itemCategory == "Hunger" then
        config = HungerFurnitureConfig
    elseif itemCategory == "Decor" then
        config = DecorFurnitureConfig
    end

    local itemConfig = config.GetConfig(itemName)

    itemNameText.Text = DELETE_ITEM_CARD_NAME_TEMPLATE:gsub("ITEM_NAME", itemName):gsub("AMT", tostring(amtOfItem))
    itemRefundText.Text = DELETE_ITEM_CARD_REFUND_TEMPLATE:gsub("AMT", tostring(itemConfig.Price)):gsub("CURRENCY_TYPE", itemConfig.Currency)

    removeBtn.Activated:Connect(function()
        currentItemsToDelete[itemCategory][itemName].Amount -= 1
        local newAmt = currentItemsToDelete[itemCategory][itemName].Amount
        
        if newAmt <= 0 then
            -- remove item from currentItemsToDelete table
            currentItemsToDelete[itemCategory][itemName] = nil
            template:Destroy()
        end

        itemNameText.Text = DELETE_ITEM_CARD_NAME_TEMPLATE:gsub("ITEM_NAME", itemName):gsub("AMT", tostring(newAmt))
    end)

    template.Visible = true
    return template
end

local function displayDeleteItemPopup(itemToDelete)
    clearDeleteItemsPopup()

    for itemCategory, itemsInCategory in itemToDelete do
        for itemName, itemInfo in itemsInCategory do
            local template = createDeleteItemCard(itemCategory, itemName, itemInfo.Amount, itemInfo.ItemUUID)
            template.Parent = DeleteItemsScrollingFrame
        end
    end

end

local function displayDeleteMultipleItemsPopup()
    clearDeleteItemsPopup()

    for category, furnitureItems in currentItemsToDelete do
        for itemName, itemDetails in furnitureItems do
            local template = createDeleteItemCard(category, itemName, itemDetails.Amount, nil)
            template.Parent = DeleteItemsScrollingFrame
        end
    end
end

-- when a user switches platform (e.g. attaches controller on PC), this function changes the item interaction buttons visually
local function changeItemInteractionBtnsPlatform(platform: "pc" | "mobile" | "console")
end

local function showItemInteractionBtns()
    ItemInteractionButtons.Visible = true

    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Elastic)
    local tween = TweenService:Create(ItemInteractionButtons, tweenInfo, { Position = itemInteractionBtnContainerVisiblePos })
    tween:Play()
end

local function hideItemInteractionBtns()
    local tweenInfo = TweenInfo.new(0.3)
    local tween = TweenService:Create(ItemInteractionButtons, tweenInfo, { Position = itemInteractionBtnContainerHiddenPos })
    tween:Play()
    tween.Completed:Connect(function(_playbackState) ItemInteractionButtons.Visible = false end)
end

-- switches between the left-side studio btns (visit studio btn & build mode btn)
local function switchStudioBtns(btnToHide, btnToShow)
    btnToHide.Visible = false
    btnToShow.Visible = true
end

local function resetGenreTopicGuiView()
    AllGenresTopicsContainer.Visible = true
    GenreTopicViewExitBtn.Visible = true
    
    GenreTopicInfoDisplay.Visible = false
    GenreTopicInfoBackBtn.Visible = false
end

local function clearShelfGui()
    for _i, instance in GenresScrollingFrame:GetChildren() do
        if instance.Name == 'UIListLayout' or instance.Name == 'UIPadding' or instance.Name == 'Template' then continue end
        instance:Destroy()
    end
    
    for _i, instance in TopicsScrollingFrame:GetChildren() do
        if instance.Name == 'UIListLayout' or instance.Name == 'UIPadding' or instance.Name == 'Template' then continue end
        instance:Destroy()
    end
end

local function showGenreTopicInfo(type: "genre" | "topic", object)
    GenreTopicInfoHeaderText.Text = (type == "genre" and "Genre" or "Topic") .. " - " .. object.Name

    GenreTopicInfoLevelText.Text = tostring(object.Level)
    GenreTopicInfoCompatibleText.Text = "Compatible with: " .. (object.CompatibleWith or "-")
    GenreTopicInfoIncompatibleText.Text = "Incompatible with: " .. (object.IncompatibleWith or "-")

    AllGenresTopicsContainer.Visible = false
    GenreTopicViewExitBtn.Visible = false

    GenreTopicInfoDisplay.Visible = true
    GenreTopicInfoBackBtn.Visible = true
end

local function pullBookModelOut(name: string)
    local bookshelf = studioInteriorModel:FindFirstChild("Shelf", true)
    local bookModel = bookshelf:FindFirstChild(name, true)
    if not bookModel then return end

    local x, y, z = bookModel.PrimaryPart.CFrame:ToEulerAnglesXYZ()
    currentViewedBook = {
        Name = name,
        OriginalPos = bookModel.PrimaryPart.Position,
        OriginalRot = { X = x, Y = y, Z = z }
    }

    local lookAtPart = bookshelf:FindFirstChild("CameraPositionPart")

    local posTween = TweenService:Create(bookModel.PrimaryPart, TweenInfo.new(0.5), { CFrame = bookModel.PrimaryPart.CFrame + (-bookModel.PrimaryPart.CFrame.rightVector * 2.5) })
    
    posTween:Play()
    posTween.Completed:Connect(function()
        local lookAtTween = TweenService:Create(bookModel.PrimaryPart, TweenInfo.new(0.5), { CFrame = CFrame.lookAt(bookModel.PrimaryPart.CFrame.Position, lookAtPart.Position) * CFrame.Angles(0, math.pi, 0)})
        lookAtTween:Play()
    end)
end

local function putBookModelBack()
    local bookModel = studioInteriorModel:FindFirstChild(currentViewedBook.Name, true)
    if not bookModel then return end

    local x, y, z = currentViewedBook.OriginalRot.X, currentViewedBook.OriginalRot.Y, currentViewedBook.OriginalRot.Z

    local rotationTween = TweenService:Create(bookModel.PrimaryPart, TweenInfo.new(0.35), { CFrame = CFrame.new(bookModel.PrimaryPart.Position) * CFrame.Angles(x, y, z) })
    local posTween = TweenService:Create(bookModel.PrimaryPart, TweenInfo.new(0.35), { CFrame = CFrame.new(currentViewedBook.OriginalPos) * CFrame.Angles(x, y, z) })

    rotationTween:Play()
    rotationTween.Completed:Connect(function() posTween:Play() end)

    -- reset currentViewedBook
    currentViewedBook = nil
end

local bookViewDebounce = true
local function registerGenreTopicViewBtn(name: string, type: "genre" | "topic", viewBtn, object)
    viewBtn.Activated:Connect(function()
        if bookViewDebounce then
            bookViewDebounce = false

            -- move book back to original position on shelf before pulling out new one
            if currentViewedBook then putBookModelBack() end

            pullBookModelOut(name)

            -- change gui
            showGenreTopicInfo(type, object)
        end
    end)
end

local function createShelfGuiTemplate(name: string, info, type: "genre" | "topic")
    local object = type == "genre" and GenreConfig.new(name, info.Level, info.XP, info.CompatibleWith, info.IncompatibleWith)
                                   or TopicConfig.new(name, info.Level, info.XP, info.CompatibleWith, info.IncompatibleWith)

    local template = GenreTopicTemplate:Clone()
    template.Name = name

    local templateImage = template:FindFirstChild("Icon")
    templateImage.Image = type == "genre" and GenreConfig.GetImage(name) or TopicConfig.GetImage(name)

    local levelText = template:FindFirstChild("Level")
    levelText.Text = tostring(object.Level)

    local viewBtn = template:FindFirstChild("ViewBtn")
    registerGenreTopicViewBtn(name, type, viewBtn, object)

    template.Visible = true

    return template
end

local function populateShelfGui()
    plrData = Remotes.Data.GetAllData:InvokeServer()
    local plrGenres = plrData.GameDev.Genres
    local plrTopics = plrData.GameDev.Topics

    clearShelfGui()

    -- populate with genre & topic cards
    for genreName, genreInfo in plrGenres do
        local template = createShelfGuiTemplate(genreName, genreInfo, "genre")
        template.Parent = GenresScrollingFrame
    end

    for topicName, topicInfo in plrTopics do
        local template = createShelfGuiTemplate(topicName, topicInfo, "topic")
        template.Parent = TopicsScrollingFrame
    end
end

-- BUTTON ACTIVATE EVENTS
local tpDebounce = true
StudioTeleportBtn.Activated:Connect(function()
    if tpDebounce and localPlr:GetAttribute("IsAlive") then
        tpDebounce = false
        Remotes.Studio.General.VisitOwnStudio:FireServer()
        task.wait(1)
        tpDebounce = true
    end
end)

local buildModeDebounce = true
StudioBuildModeBtn.Activated:Connect(function()
    if buildModeDebounce then
        buildModeDebounce = false
        setupBuildModeGui()
        Remotes.Studio.BuildMode.EnterBuildMode:FireServer()
        
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
    Remotes.Studio.General.UpdateWhitelist:FireServer()
end)

local kickAllDebounce = true
StudioKickAllBtn.Activated:Connect(function()
    if kickAllDebounce then
        kickAllDebounce = false
        Remotes.Studio.General.KickFromStudio:FireServer()
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


BuildModeExitBtn.Activated:Connect(function()
    disableBuildModeGui()
    Remotes.Studio.BuildMode.ExitBuildModeBindable:Fire()
    
    -- add cooldown so plr can't enter build mode again instantly
    buildModeDebounce = false
    task.wait(1)
    buildModeDebounce = true
end)

ItemRotateBtnPc.Activated:Connect(function()
    Remotes.Studio.BuildMode.FurnitureItemRotate:Fire()
end)

local cancelItemDebounce = true
ItemCancelBtnPc.Activated:Connect(function()
    if cancelItemDebounce then
        cancelItemDebounce = false
        Remotes.Studio.BuildMode.FurnitureItemCancel:Fire()

        task.wait(1)
        cancelItemDebounce = true
    end
end)

DeleteItemsYesBtn.Activated:Connect(function()
    GuiServices.HideGuiStandard(DeleteItemsPopup, UDim2.fromScale(deleteItemsPopupVisiblePos.X.Scale, deleteItemsPopupVisiblePos.Y.Scale + GlobalVariables.Gui.MainGuiInvisiblePosOffset), UDim2.fromScale(deleteItemsPopupVisibleSize.X.Scale, deleteItemsPopupVisibleSize.Y.Scale - 0.2))
    
    Remotes.Studio.BuildMode.DeleteItems:FireServer(currentItemsToDelete)

    setupBuildModeGui()
    Remotes.Studio.BuildMode.EnterBuildMode:FireServer()
end)

DeleteItemsNoBtn.Activated:Connect(function()
    currentItemsToDelete = nil

    GuiServices.HideGuiStandard(DeleteItemsPopup, UDim2.fromScale(deleteItemsPopupVisiblePos.X.Scale, deleteItemsPopupVisiblePos.Y.Scale + GlobalVariables.Gui.MainGuiInvisiblePosOffset), UDim2.fromScale(deleteItemsPopupVisibleSize.X.Scale, deleteItemsPopupVisibleSize.Y.Scale - 0.2))
    
    setupBuildModeGui()
    Remotes.Studio.BuildMode.EnterBuildMode:FireServer()
end)

GenreTopicViewExitBtn.Activated:Connect(function()
    GuiServices.HideGuiStandard(GenreTopicViewContainer, UDim2.fromScale(genreTopicViewVisiblePos.X.Scale, genreTopicViewVisiblePos.Y.Scale + GlobalVariables.Gui.MainGuiInvisiblePosOffset), UDim2.fromScale(genreTopicViewVisibleSize.X.Scale, genreTopicViewVisibleSize.Y.Scale - 0.2))
    
    -- stop viewing shelf
    Remotes.GUI.Studio.StopViewingShelf:Fire()
    viewingShelf = false
end)

GenreTopicInfoBackBtn.Activated:Connect(function()
    resetGenreTopicGuiView()

    putBookModelBack()

    -- apply cooldown before next book can be pulled out/viewed
    task.wait(1)
    bookViewDebounce = true
end)

-- REMOTE EVENTS
Remotes.Studio.General.VisitOwnStudio.OnClientEvent:Connect(function(_plr, _studioIndex, _interiorPlayerTpPart, _exteriorPlayerTpPart, _placedFurnitureData)
    task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
        switchStudioBtns(StudioTeleportBtn, StudioBuildModeBtn)
    end)
    studioInteriorModel = Workspace.TempAssets.Studios:WaitForChild(localPlr.UserId):WaitForChild("Interior")
end)

Remotes.Studio.General.VisitOtherStudio.OnClientEvent:Connect(function(_studioIndex, _interiorPlrTpPart, _exteriorPlrTpPart)
    GuiServices.HideGuiStandard(StudioListContainer, UDim2.new(visibleGuiPos.X.Scale, 0, visibleGuiPos.Y.Scale + GlobalVariables.Gui.MainGuiInvisiblePosOffset, 0), UDim2.new(visibleGuiSize.X.Scale, 0, visibleGuiSize.Y.Scale - 0.2, 0))
end)

Remotes.Studio.General.LeaveStudio.OnClientEvent:Connect(function()
    task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
        switchStudioBtns(StudioBuildModeBtn, StudioTeleportBtn)
    end)
    if inBuildMode then disableBuildModeGui() end
    if inPlaceMode then
        -- fire to server, which then fires to client to terminate place mode functionality
        Remotes.Studio.BuildMode.ExitPlaceMode:FireServer()
    end
    
    inPlaceMode = false
    inBuildMode = false
    currentViewedBook = nil
end)

Remotes.GUI.Studio.UpdateStudioList.OnClientEvent:Connect(function(userIdToUpdate: number, updateStatus: "add" | "remove" | "update", userStudioInfo)
    updateStudioListItem(userIdToUpdate, updateStatus, userStudioInfo)
end)

Remotes.Studio.General.UpdateWhitelist.OnClientEvent:Connect(function(newWhitelistSetting)
    updateWhitelistBtn(newWhitelistSetting)
end)

-- when plr enters build mode, save furniture inventory data to variable
Remotes.Studio.BuildMode.EnterBuildMode.OnClientEvent:Connect(function(studioInventoryData)
    inBuildMode = true
    studioFurnitureInventory = studioInventoryData
end)

-- when plr enters place mode, hide build mode gui
Remotes.Studio.BuildMode.EnterPlaceMode.OnClientEvent:Connect(function(itemName: string, itemCategory: string)
    inPlaceMode = true
    hideBuildModeGui()
    showItemInteractionBtns()
end)

-- show build-mode gui again
Remotes.Studio.BuildMode.ExitPlaceMode.OnClientEvent:Connect(function(studioInventoryData)
    hideItemInteractionBtns()
    if inBuildMode then
        if studioInventoryData then
            studioFurnitureInventory = studioInventoryData
        end
        setupBuildModeGui()
    end
end)

Remotes.GUI.Studio.DeleteFurniturePopup.Event:Connect(function(singleItem: boolean, itemsToDelete)
    currentItemsToDelete = itemsToDelete

    if inBuildMode then
        disableBuildModeGui()
        inBuildMode = false
        inPlaceMode = false
    end

    if singleItem then
        displayDeleteItemPopup(currentItemsToDelete)
    else
        -- display potentially multiple items to delete
        displayDeleteMultipleItemsPopup(currentItemsToDelete)
    end

    GuiServices.ShowGuiStandard(DeleteItemsPopup, deleteItemsPopupVisiblePos, deleteItemsPopupVisibleSize, GlobalVariables.Gui.GuiBackdropColourDefault)
end)


-- reopen build mode gui & related functionality
Remotes.Studio.BuildMode.ExitPlaceModeBindable.Event:Connect(function()
    hideItemInteractionBtns()
    if inBuildMode then
        setupBuildModeGui()
    end
end)

-- view shelf
Remotes.GUI.Studio.ViewShelf.Event:Connect(function()
    viewingShelf = true
    populateShelfGui()
    GuiServices.ShowGuiStandard(GenreTopicViewContainer, genreTopicViewVisiblePos, genreTopicViewVisibleSize)
end)

humanoid.Died:Connect(function()
    if inPlaceMode then
        hideItemInteractionBtns()
        inPlaceMode = false
    end

    if inBuildMode then
        disableBuildModeGui()
        inBuildMode = false
    end

    if viewingShelf then
        GuiServices.HideGuiStandard(GenreTopicViewContainer, UDim2.fromScale(genreTopicViewVisiblePos.X.Scale, genreTopicViewVisiblePos.Y.Scale + GlobalVariables.Gui.MainGuiInvisiblePosOffset), UDim2.fromScale(genreTopicViewVisibleSize.X.Scale, genreTopicViewVisibleSize.Y.Scale - 0.2))
        resetGenreTopicGuiView()
        bookViewDebounce = true
        CameraControls.SetDefault(localPlr, camera, true)
    end
end)

localPlr.CharacterAdded:Connect(function(character: Model)
    char = character
    humanoid = char:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        if inPlaceMode then
            hideItemInteractionBtns()
            inPlaceMode = false
        end

        if inBuildMode then
            disableBuildModeGui()
            inBuildMode = false
        end

        if viewingShelf then
            GuiServices.HideGuiStandard(GenreTopicViewContainer, UDim2.fromScale(genreTopicViewVisiblePos.X.Scale, genreTopicViewVisiblePos.Y.Scale + GlobalVariables.Gui.MainGuiInvisiblePosOffset), UDim2.fromScale(genreTopicViewVisibleSize.X.Scale, genreTopicViewVisibleSize.Y.Scale - 0.2))
            resetGenreTopicGuiView()
            bookViewDebounce = true
            CameraControls.SetDefault(localPlr, camera, true)
        end
    end)
end)