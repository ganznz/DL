local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local GeneralUtils = require(ReplicatedStorage.Utils:WaitForChild("GeneralUtils"))
local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))
local PlayerServices = require(ReplicatedStorage.Utils.Player:WaitForChild("Player"))
local GlobalVariables = require(ReplicatedStorage.GlobalVariables)
local CameraControls = require(ReplicatedStorage.Utils.Camera:WaitForChild("CameraControls"))
local StudioConfig = require(ReplicatedStorage.Configs.Studio:WaitForChild("Studio"))
local HungerFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("HungerFurniture"))
local EnergyFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("EnergyFurniture"))
local MoodFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("MoodFurniture"))
local DecorFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("DecorFurniture"))
local GenreConfig = require(ReplicatedStorage.Configs.GameDev:WaitForChild("Genre"))
local TopicConfig = require(ReplicatedStorage.Configs.GameDev:WaitForChild("Topic"))

local Remotes = ReplicatedStorage.Remotes

local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui
local plrPlatformProfile = Remotes.Player.GetPlrPlatformData:InvokeServer()
local camera = Workspace:WaitForChild("Camera")

-- GUI REFERENCE VARIABLES
local AllGuiScreenGui = PlayerGui:WaitForChild("AllGui")
local LeftScreenGui = AllGuiScreenGui.Hud:WaitForChild("Left")
local RightScreenGui = AllGuiScreenGui.Hud:WaitForChild("Right")

local LeftSideContainer = LeftScreenGui:WaitForChild("LeftBtnContainer")
local StudioTeleportBtnContainer = LeftSideContainer.StudioTpBtnContainer
local StudioBuildModeBtnContainer = LeftSideContainer.StudioBuildModeBtnContainer
local StudioTeleportBtn = StudioTeleportBtnContainer.StudioTpBtn
local StudioBuildModeBtn = StudioBuildModeBtnContainer.StudioBuildModeBtn

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
local leftSideContainerVisiblePos: UDim2 = LeftSideContainer.Position
local leftSideContainerVisibleSize: UDim2 = LeftSideContainer.Size

local rightSideContainerVisiblePos: UDim2 = RightSideContainer.Position
local rightSideContainerVisibleSize: UDim2 = RightSideContainer.Size

local plrInfoContainerVisiblePos: UDim2 = PlrInfoContainer.Position
local plrInfoContainerVisibleSize: UDim2 = PlrInfoContainer.Size

local studioBuildModeVisiblePos: UDim2 = StudioBuildModeContainer.Position
local studioBuildModeHiddenPos: UDim2 = UDim2.fromScale(0.5, 1.25)

local itemInteractionBtnContainerVisiblePos: UDim2 = ItemInteractionButtons.Position
local itemInteractionBtnContainerHiddenPos: UDim2 = UDim2.fromScale(0.5, 1.2)

-- STATIC VARIABLES
local WHITELIST_BTN_TEXT_TEMPLATE = "Studio: SETTING"
local ITEM_STAT_TEXT_TEMPLATE = "+AMT/sec"
local ITEM_AMOUNT_TEXT_TEMPLATE = "xAMT"
local KICK_PLRS_COOLDOWN = 1 -- seconds


-- STATE VARIABLES
local plrData = Remotes.Data.GetAllData:InvokeServer()
local studioInteriorModel = nil
local studioFurnitureInventory = nil
local currentViewedBook = nil -- when plr is viewing bookshelf, this holds cframe info for what book is 'pulled' from the shelf at a given time

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

GuiServices.StoreInCache(StudioListContainer)
GuiServices.StoreInCache(GenreTopicViewContainer)

GuiServices.DefaultMainGuiStyling(StudioListContainer)
GuiServices.DefaultMainGuiStyling(GenreTopicViewContainer)

local function setItemInteractionBtns()
    ItemInteractionBtnsPc.Visible = plrPlatformProfile.Platform == "pc" and true or false
    ItemInteractionBtnsMobile.Visible = plrPlatformProfile.Platform == "mobile" and true or false
end
-- set what item interaction btns are visible by default
setItemInteractionBtns()

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
    showBuildModeGui()

    BuildModeItemViewport.Visible = false
    SelectCategoryText.Visible = true
end

local function disableBuildModeGui()
    GuiServices.ShowHUD()
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
            itemStatsText.Text = ITEM_STAT_TEXT_TEMPLATE:gsub("AMT", config.Stats.Base)

        elseif category == "Energy" then
            itemModel = EnergyFurnitureConfig.GetModel(itemName)
            config = EnergyFurnitureConfig.GetConfig(itemName)
            itemStatsText.Text = ITEM_STAT_TEXT_TEMPLATE:gsub("AMT", config.Stats.Base)

        elseif category == "Hunger" then
            itemModel = HungerFurnitureConfig.GetModel(itemName)
            config = HungerFurnitureConfig.GetConfig(itemName)
            itemStatsText.Text = ITEM_STAT_TEXT_TEMPLATE:gsub("AMT", config.Stats.Base)
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
            local numOfInstances = GeneralUtils.LengthOfDict(itemInstances)
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

    local itemConfig = type == "genre" and GenreConfig.GetConfig(name) or TopicConfig.GetConfig(name)

    local templateImage = template:FindFirstChild("Icon")
    if itemConfig["ImageIcon"] then templateImage.Image = GeneralUtils.GetDecalUrl(itemConfig.ImageIcon) end

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
    GuiServices.ShowGuiStandard(StudioListContainer, GlobalVariables.Gui.GuiBackdropColourDefault)
end)

StudioListExitBtn.Activated:Connect(function()
    GuiServices.HideGuiStandard(StudioListContainer)
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

GenreTopicViewExitBtn.Activated:Connect(function()
    GuiServices.HideGuiStandard(GenreTopicViewContainer)
    
    -- stop viewing shelf
    GuiServices.ShowHUD()
    PlayerServices.ShowPlayer(localPlr, true)
    CameraControls.SetDefault(localPlr, camera, true)
    Remotes.Player.StopInspecting:Fire()
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
        switchStudioBtns(StudioTeleportBtnContainer, StudioBuildModeBtnContainer)
    end)
    studioInteriorModel = Workspace.TempAssets.Studios:WaitForChild(localPlr.UserId):WaitForChild("Interior")
end)

Remotes.Studio.General.VisitOtherStudio.OnClientEvent:Connect(function(_studioIndex, _interiorPlrTpPart, _exteriorPlrTpPart)
    GuiServices.HideGuiStandard(StudioListContainer)
end)

Remotes.Studio.General.LeaveStudio.OnClientEvent:Connect(function()
    task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
        switchStudioBtns(StudioBuildModeBtnContainer, StudioTeleportBtnContainer)
    end)
    if localPlr:GetAttribute("InBuildMode") then disableBuildModeGui() end
    if localPlr:GetAttribute("InPlaceMode") then
        -- fire to server, which then fires to client to terminate place mode functionality
        Remotes.Studio.BuildMode.ExitPlaceMode:FireServer()
    end
    
    localPlr:SetAttribute("InPlaceMode", false)
    localPlr:SetAttribute("InBuildMode", false)
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
    localPlr:SetAttribute("InBuildMode", true)
    studioFurnitureInventory = studioInventoryData
    GuiServices.HideHUD({ HideGuiFrames = true })
end)

-- when plr enters place mode, hide build mode gui
Remotes.Studio.BuildMode.EnterPlaceMode.OnClientEvent:Connect(function(itemName: string, itemCategory: string)
    localPlr:SetAttribute("InPlaceMode", true)
    hideBuildModeGui()
    showItemInteractionBtns()
end)

-- show build-mode gui again
Remotes.Studio.BuildMode.ExitPlaceMode.OnClientEvent:Connect(function(studioInventoryData)
    if not studioInventoryData then return end

    hideItemInteractionBtns()
    if localPlr:GetAttribute("InBuildMode") then
        if studioInventoryData then
            studioFurnitureInventory = studioInventoryData
        end
        setupBuildModeGui()
    end
end)


Remotes.GUI.Inventory.DeleteItemPopup.Event:Connect(function(singleItem: boolean, _itemsToDelete)
    disableBuildModeGui()
end)

-- reopen build mode gui & related functionality
Remotes.Studio.BuildMode.ExitPlaceModeBindable.Event:Connect(function()
    hideItemInteractionBtns()
    if localPlr:GetAttribute("InBuildMode") then
        setupBuildModeGui()
    end
end)

-- view shelf
Remotes.GUI.Studio.ViewShelf.Event:Connect(function()
    populateShelfGui()
    GuiServices.ShowGuiStandard(GenreTopicViewContainer)
end)

Remotes.Player.PlatformChanged.OnClientEvent:Connect(function(newPlatformProfile)
    plrPlatformProfile = newPlatformProfile
    setItemInteractionBtns() -- update item interaction btns
end)

-- on plr spawn & death
local function characterAdded(char: Model)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        if localPlr:GetAttribute("InPlaceMode") then
            hideItemInteractionBtns()
        end
    
        if localPlr:GetAttribute("InBuildMode") then
            disableBuildModeGui()
        end
    
        resetGenreTopicGuiView()
        bookViewDebounce = true
    end)
end

if localPlr.Character then characterAdded(localPlr.Character) end

localPlr.CharacterAdded:Connect(characterAdded)