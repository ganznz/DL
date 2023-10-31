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

local DeleteItemsPopup = AllGuiScreenGui.Studio.StudioBuildMode:WaitForChild("DeleteItemsPopup")
local DeleteItemsScrollingFrame = DeleteItemsPopup:WaitForChild("ScrollingFrame")
local DeleteItemsTemplate = DeleteItemsScrollingFrame:FindFirstChild("Template")
local DeleteItemsYesBtn = DeleteItemsPopup:FindFirstChild("YesBtn")
local DeleteItemsNoBtn = DeleteItemsPopup:FindFirstChild("NoBtn")
local DeleteItemsTotalRefundText = DeleteItemsPopup:FindFirstChild("TotalRefund")


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


-- STATIC VARIABLES
local WHITELIST_BTN_TEXT_TEMPLATE = "Studio: SETTING"
local ITEM_STAT_TEXT_TEMPLATE = "+AMT/sec"
local ITEM_AMOUNT_TEXT_TEMPLATE = "xAMT"
local DELETE_ITEM_CARD_NAME_TEMPLATE = "ITEM_NAME (xAMT)"
local DELETE_ITEM_CARD_REFUND_TEMPLATE = "+ AMT CURRENCY_TYPE"
local KICK_PLRS_COOLDOWN = 1 -- seconds


-- STATE VARIABLES
local inBuildMode = false
local inPlaceMode = false
local char = localPlr.Character or localPlr.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local studioFurnitureInventory = nil
local currentItemsToDelete = nil -- keeps track of what items have been added/removed when the delete items popup is visible

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
        Remotes.Studio.General.VisitOtherStudio:FireServer(userIdOfPlrToVisit)
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

local function registerBuildModeItemListener(itemBtn, itemCategory)
    local connection = itemBtn.Activated:Connect(function()
        -- check that plr actually has item on server
        local itemName = itemBtn.Name
        Remotes.Studio.BuildMode.EnterPlaceMode:FireServer(itemName, itemCategory, false)
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

-- local DeleteItemsPopup = AllGuiScreenGui.Studio.StudioBuildMode:WaitForChild("DeleteItemsPopup")
-- local DeleteItemsScrollingFrame = DeleteItemsPopup:WaitForChild("ScrollingFrame")
-- local DeleteItemsTemplate = DeleteItemsScrollingFrame:FindFirstChild("Template")
-- local DeleteItemsYesBtn = DeleteItemsPopup:FindFirstChild("YesBtn")
-- local DeleteItemsNoBtn = DeleteItemsPopup:FindFirstChild("NoBtn")
-- local DeleteItemsTotalRefundText = DeleteItemsPopup:FindFirstChild("TotalRefund")

local function clearDeleteItemsPopup()
    for _i, instance in DeleteItemsScrollingFrame:GetChildren() do
        print(instance)
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

-- show furniture item delete popup
-- single item:    { [category] = { [itemName] = { amount = number } } }
-- multiple items: { [category] = { [itemName] = { amount = number } } }

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

-- switches between the left-side studio btns (visit studio btn & build mode btn)
local function switchStudioBtns(btnToHide, btnToShow)
    btnToHide.Visible = false
    btnToShow.Visible = true
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
    Remotes.Studio.BuildMode.ExitBuildMode:Fire()
    
    -- add cooldown so plr can't enter build mode again instantly
    buildModeDebounce = false
    task.wait(1)
    buildModeDebounce = true
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


-- REMOTE EVENTS
Remotes.Studio.General.VisitOwnStudio.OnClientEvent:Connect(function(_plr, _studioIndex, _interiorPlayerTpPart, _exteriorPlayerTpPart, _placedFurnitureData)
    task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
        switchStudioBtns(StudioTeleportBtn, StudioBuildModeBtn)
    end)
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
end)

-- show build-mode gui again
Remotes.Studio.BuildMode.ExitPlaceMode.OnClientEvent:Connect(function(studioInventoryData)
    if inBuildMode then
        studioFurnitureInventory = studioInventoryData
        setupBuildModeGui()
    end
end)

-- show furniture item delete popup
-- single item:    { [category] = { [itemName] = { amount = number } } }
-- multiple items: { [category] = { [itemName] = { amount = number } } }
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

humanoid.Died:Connect(function()
    if inBuildMode then
        disableBuildModeGui()
        inBuildMode = false
        inPlaceMode = false
    end
end)

localPlr.CharacterAdded:Connect(function(character: Model)
    char = character
    humanoid = char:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        if inBuildMode then
            disableBuildModeGui()
            inBuildMode = false
            inPlaceMode = false
        end
    end)
end)