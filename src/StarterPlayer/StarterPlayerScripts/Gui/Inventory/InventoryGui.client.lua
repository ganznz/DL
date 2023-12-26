local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))
local GuiTemplates = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiTemplates"))
local GeneralUtils = require(ReplicatedStorage.Utils:WaitForChild("GeneralUtils"))
local GlobalVariables = require(ReplicatedStorage.GlobalVariables)
local StudioConfig = require(ReplicatedStorage.Configs.Studio:WaitForChild("Studio"))
local HungerFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("HungerFurniture"))
local EnergyFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("EnergyFurniture"))
local MoodFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("MoodFurniture"))
local DecorFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("DecorFurniture"))

local Remotes = ReplicatedStorage.Remotes

local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui

-- GUI VARIABLES --
local AllGuiScreenGui = PlayerGui:WaitForChild("AllGui")
local InventoryContainer = AllGuiScreenGui.Inventory:WaitForChild("InventoryContainerOuter")
local InventoryExitBtn = InventoryContainer:WaitForChild("ExitBtn")
local AmtSelectedText = InventoryContainer.InventoryContainerInner:WaitForChild("AmtSelectedText")

local InventoryCategoryContainer = InventoryContainer.CategoryContainerOuter.CategoryContainerInner.CategoryContainer
local StaffInventoryBtnContainer = InventoryCategoryContainer:WaitForChild("StaffBtnContainer")
local FurnitureInventoryBtnContainer = InventoryCategoryContainer:WaitForChild("FurnitureBtnContainer")
local ItemsInventoryBtnContainer = InventoryCategoryContainer:WaitForChild("ItemsBtnContainer")
local StaffInventoryBtn = StaffInventoryBtnContainer:WaitForChild("StaffBtn")
local FurnitureInventoryBtn = FurnitureInventoryBtnContainer:WaitForChild("FurnitureBtn")
local ItemsInventoryBtn = ItemsInventoryBtnContainer:WaitForChild("ItemsBtn")

local EditSettingsContainer = InventoryContainer.EditSettingsOuter.EditSettingsInner:WaitForChild("Container")
local LockModeBtn = EditSettingsContainer:FindFirstChild("LockModeBtn")
local TrashModeBtn = EditSettingsContainer:FindFirstChild("TrashModeBtn")
local ConfirmBtn = EditSettingsContainer:FindFirstChild("ConfirmBtn")
local CancelBtn = EditSettingsContainer:FindFirstChild("CancelBtn")
local ExitModeBtn = EditSettingsContainer:FindFirstChild("ExitModeBtn") -- btn only applies to lock-mode

local InventoryScrollingFrame = InventoryContainer.InventoryContainerInner:WaitForChild("ScrollingFrame")
local ScrollingFrameFurnitureTemplateContainer = InventoryScrollingFrame:WaitForChild("FurnitureTemplateContainer")
local ScrollingFrameStaffTemplateContainer = InventoryScrollingFrame:WaitForChild("StaffTemplateContainer")

local FurnitureInfoPanel = InventoryContainer.InventoryContainerInner:WaitForChild("FurnitureInfoPanel")
local FurnitureInfoItemIcon = FurnitureInfoPanel:WaitForChild("ItemIcon")
local FurnitureInfoItemTypeIcon = FurnitureInfoPanel:WaitForChild("ItemTypeIcon")
local FurnitureInfoItemName = FurnitureInfoPanel:WaitForChild("ItemName")
local FurnitureItemPlacedInText = FurnitureInfoPanel:WaitForChild("PlacedInText")
local FurnitureInfoPlaceBtn = FurnitureInfoPanel:WaitForChild("PlaceBtn")
local FurnitureInfoStatContainer = FurnitureInfoPanel:WaitForChild("ItemStatContainer")
local FurnitureInfoStatTemplate = FurnitureInfoStatContainer:WaitForChild("FurnitureInfoTemplate")

local StaffInfoPanel = InventoryContainer.InventoryContainerInner:WaitForChild("StaffInfoPanel")
local StaffInfoItemIcon = StaffInfoPanel:WaitForChild("ItemIcon")
local StaffInfoItemName = StaffInfoPanel:WaitForChild("ItemName")
local StaffInfoPlaceBtn = StaffInfoPanel:WaitForChild("PlaceBtn")
local StaffInfoPtsContainer = StaffInfoPanel:WaitForChild("SkillPtsContainer")
local CodingPtsContainer = StaffInfoPtsContainer:WaitForChild("CodingPts")
local CodingPtsAmt = CodingPtsContainer:WaitForChild("PtsAmt")
local ModelingPtsContainer = StaffInfoPtsContainer:WaitForChild("ModelingPts")
local ModelingPtsAmt = ModelingPtsContainer:WaitForChild("PtsAmt")
local SoundPtsContainer = StaffInfoPtsContainer:WaitForChild("SoundPts")
local SoundPtsAmt = SoundPtsContainer:WaitForChild("PtsAmt")

-- STATE VARIABLES --
local plrData = nil
local studioAllPlrsInfo = nil
local inventoryCategory = "staff" -- category that is currently being viewed, defaults to Staff when UI opens ("staff" | "furniture" | "items")
local inLockMode = false
local inTrashMode = false
local placeBtnConnection = nil
local itemsInTrashMode = {}
local amtOfItemsInTrashMode = 0

-- CONSTANT VARIABLES --
local REMOVE_FROM_STUDIO_TEXT = "Remove from Studio"
local PLACE_IN_STUDIO_TEXT = "Place in Studio"
local BE_IN_STUDIO_TEXT = "Enter your Studio to place"
local CURRENTLY_PLACED_TEXT = "Placed in: STUDIO_NAME"
local NOT_PLACED_TEXT = "Item not placed yet!"
local STAT_BOOST_BASE_TEXT = "+AMT STAT"
local AMT_SELECTED_TEXT = "AMT SELECTED!" 
local ALL_TRASH_MODE_ICON_IDS = {}

GuiServices.StoreInCache(InventoryContainer)

GuiServices.DefaultMainGuiStyling(InventoryContainer)

GuiTemplates.CreateButton(StaffInventoryBtn, { Rotates = true })
GuiTemplates.CreateButton(FurnitureInventoryBtn, { Rotates = true })
GuiTemplates.CreateButton(ItemsInventoryBtn, { Rotates = true })

GuiTemplates.HeaderText(AmtSelectedText)

local function clearScrollingFrame()
    for _i, instance in InventoryScrollingFrame:GetChildren() do
        if instance.Name == "UIGridLayout" or instance.Name == "UIPadding" or instance.Name == "FurnitureTemplateContainer" or instance.Name == "StaffTemplateContainer" then continue end

        instance:Destroy()
    end
end

local function defineTrashModeTable()
    -- reset trash mode table
    itemsInTrashMode = {}

    if inventoryCategory == "staff" then
        
    elseif inventoryCategory == "furniture" then
        itemsInTrashMode["Energy"] = {}
        itemsInTrashMode["Mood"] = {}
        itemsInTrashMode["Hunger"] = {}
        itemsInTrashMode["Decor"] = {}
        for _i, itemName in EnergyFurnitureConfig.GetAllFurnitureNames() do itemsInTrashMode["Energy"][itemName] = {} end
        for _i, itemName in MoodFurnitureConfig.GetAllFurnitureNames() do itemsInTrashMode["Mood"][itemName] = {} end
        for _i, itemName in HungerFurnitureConfig.GetAllFurnitureNames() do itemsInTrashMode["Hunger"][itemName] = {} end
        for _i, itemName in DecorFurnitureConfig.GetAllFurnitureNames() do itemsInTrashMode["Decor"][itemName] = {} end
    end
end

local function toggleItemTrashMode(itemInfo: {}): boolean
    -- check if item is locked first
    local isLocked = plrData.Inventory.StudioFurnishing[itemInfo.ItemCategory][itemInfo.ItemName][itemInfo.ItemUUID].Locked
    if isLocked then return false end

    if inventoryCategory == "furniture" then
        local index = table.find(itemsInTrashMode[itemInfo.ItemCategory][itemInfo.ItemName], itemInfo.ItemUUID)
        if index then
            -- item is currently in trash table, remove from table
            table.remove(itemsInTrashMode[itemInfo.ItemCategory][itemInfo.ItemName], index)
            amtOfItemsInTrashMode -= 1
            return false
        else
            table.insert(itemsInTrashMode[itemInfo.ItemCategory][itemInfo.ItemName], itemInfo.ItemUUID)
            amtOfItemsInTrashMode += 1
            return true
        end
    end
end

local function resetPlaceBtnConnection()
    if placeBtnConnection then placeBtnConnection:Disconnect() end
    placeBtnConnection = nil
end

-- function determines place btn look and functionality
local function determinePlaceBtnSettings(placeBtn: TextButton, itemInfo: {})
    resetPlaceBtnConnection()

    local isInOwnStudio = Workspace.TempAssets.Studios:FindFirstChild(localPlr.UserId)

    -- plr not in their own studio
    if not isInOwnStudio then
        placeBtn.Text = BE_IN_STUDIO_TEXT
        placeBtn.BackgroundColor3 = GlobalVariables.Gui.InvalidGreyColour
        return
    end

    -- plr in their own studio
    if inventoryCategory == "furniture" then
        local studioPlrInfo = studioAllPlrsInfo[tostring(localPlr.UserId)]
        if not studioPlrInfo or studioPlrInfo["PlrVisitingId"] ~= localPlr.UserId then return end

        local studioConfig = StudioConfig.GetConfig(studioPlrInfo.StudioIndex)
        if not studioConfig then return end

        local studioType = studioConfig.StudioType
        local itemInStudio = StudioConfig.ItemInStudio(plrData, itemInfo.ItemName, itemInfo.ItemCategory, itemInfo.ItemUUID, studioPlrInfo.StudioIndex, studioType)

        -- if item is in studio, button should remove item
        if itemInStudio then
            placeBtn.Text = REMOVE_FROM_STUDIO_TEXT
            placeBtn.BackgroundColor3 = GlobalVariables.Gui.InvalidRedColour

            placeBtnConnection = placeBtn.Activated:Connect(function()
                Remotes.Studio.BuildMode.StoreItem:FireServer("furniture", itemInfo)
                GuiServices.HideGuiStandard(InventoryContainer)
            end)

        -- btn when activated should enter place mode w that item
        else
            placeBtn.Text = PLACE_IN_STUDIO_TEXT
            placeBtn.BackgroundColor3 = GlobalVariables.Gui.ValidGreenColour

            placeBtnConnection = placeBtn.Activated:Connect(function()
                Remotes.Studio.BuildMode.EnterBuildMode:FireServer()
                Remotes.Studio.BuildMode.EnterPlaceMode:FireServer("furniture", itemInfo, false)
                GuiServices.HideGuiStandard(InventoryContainer)
            end)
        end
    end
end

-- function determines *what* place btn gets used
local function registerPlaceItemBtn(itemInfo: {})
    if inventoryCategory == "furniture" then
        determinePlaceBtnSettings(FurnitureInfoPlaceBtn, itemInfo)
    end
end

local function populateFurnitureInfoPanel(itemInfo: {})
    FurnitureInfoItemIcon.Image = GeneralUtils.GetDecalUrl(itemInfo.ItemConfig.Image)
    FurnitureInfoItemTypeIcon.Image = GeneralUtils.GetDecalUrl(itemInfo.CategoryConfig.CategoryImage)
    FurnitureInfoItemName.Text = itemInfo.ItemName

    -- determine PlacedInText status
    if itemInfo.ItemCategory == "Special" then
        local studioItemIsPlacedIn = StudioConfig.IndexOfSpecialFurnitureItemParent(plrData, itemInfo.ItemName, itemInfo.ItemUUID)
        if not studioItemIsPlacedIn then
            FurnitureItemPlacedInText.Text = NOT_PLACED_TEXT
        else
            local studioConfig = StudioConfig.GetConfig(studioItemIsPlacedIn)
            FurnitureItemPlacedInText.Text = CURRENTLY_PLACED_TEXT:gsub("STUDIO_NAME", studioConfig.Name)
        end
        FurnitureItemPlacedInText.Visible = true

    else
        FurnitureItemPlacedInText.Visible = false
    end

    -- populate stat section
    if itemInfo.ItemConfig["Stats"] then
        for statName, boostValue in itemInfo.ItemConfig.Stats do
            local template = FurnitureInfoStatTemplate:Clone()
            local icon = template:FindFirstChild("Icon")
            local text = template:FindFirstChild("Text")

            -- default item stat
            if statName == "Base" then
                text.Text = STAT_BOOST_BASE_TEXT:gsub("AMT", boostValue):gsub("STAT", itemInfo.ItemCategory)
                template.LayoutOrder = -999999999999 -- this stat always appears first
            end

            template.Name = statName
            template.Parent = FurnitureInfoStatContainer
        end
    end

    -- register place btn
    registerPlaceItemBtn(itemInfo)
end

local function registerItemClickConnection(itemBtn, itemInfo: {})
    itemBtn.Activated:Connect(function()
        if inLockMode then
            Remotes.Inventory.General.LockItem:FireServer(inventoryCategory, itemInfo)
            plrData = Remotes.Data.GetAllData:InvokeServer() -- update plrData variable to include new locked data for the item

        return
        elseif inTrashMode then
            local trashModeIcon = itemBtn:FindFirstChild("TrashModeIcon", true)
            local itemInTrashMode = toggleItemTrashMode(itemInfo)
            trashModeIcon.Visible = itemInTrashMode
            AmtSelectedText.Text = AMT_SELECTED_TEXT:gsub("AMT", amtOfItemsInTrashMode)
        return
        end

        if inventoryCategory == "staff" then
            
        elseif inventoryCategory == "furniture" then
            populateFurnitureInfoPanel(itemInfo)
            FurnitureInfoPanel.Visible = true

        elseif inventoryCategory == "items" then
        
        end
    end)
end

local function createItemTemplate(itemInfo: {})
    local template
    local furnitureConfig
    local config

    if inventoryCategory == "staff" then
        
    elseif inventoryCategory == "furniture" then
        if itemInfo.ItemCategory == "Mood" then
            furnitureConfig = MoodFurnitureConfig
            config = MoodFurnitureConfig.GetConfig(itemInfo.ItemName)
        elseif itemInfo.ItemCategory == "Energy" then
            furnitureConfig = EnergyFurnitureConfig
            config = EnergyFurnitureConfig.GetConfig(itemInfo.ItemName)
        elseif itemInfo.ItemCategory == "Hunger" then
            furnitureConfig = HungerFurnitureConfig
            config = HungerFurnitureConfig.GetConfig(itemInfo.ItemName)
        elseif itemInfo.ItemCategory == "Decor" then
            furnitureConfig = DecorFurnitureConfig
            config = DecorFurnitureConfig.GetConfig(itemInfo.ItemName)
        end

        template = ScrollingFrameFurnitureTemplateContainer:Clone()
        local templateBtn = template:FindFirstChild("FurnitureTemplate")
        GuiTemplates.CreateButton(templateBtn, { Rotates = true })

        local nameText = templateBtn:FindFirstChild("Name")
        local itemIcon = templateBtn:FindFirstChild("Icon")
        local itemTypeIcon = templateBtn:FindFirstChild("TypeIcon")
        local itemLockedIcon = templateBtn:FindFirstChild("LockIcon")

        itemTypeIcon.Image = GeneralUtils.GetDecalUrl(furnitureConfig.CategoryImage)
        local isLocked = plrData.Inventory.StudioFurnishing[itemInfo.ItemCategory][itemInfo.ItemName][itemInfo.ItemUUID].Locked
        itemLockedIcon.Visible = isLocked

        nameText.Text = itemInfo.ItemName
        itemIcon.Image = config.Image

        itemInfo["ItemConfig"] = config
        itemInfo["CategoryConfig"] = furnitureConfig
        registerItemClickConnection(templateBtn, itemInfo)
    end

    template.Name = itemInfo.ItemUUID
    template.Visible = true
    template.Parent = InventoryScrollingFrame

    return template
end

local function populateScrollingFrame()
    local furnitureData = plrData.Inventory.StudioFurnishing

    if inventoryCategory == "staff" then
        
    elseif inventoryCategory == "furniture" then
        -- display special-tier furniture items first
        for itemName, itemInstances in furnitureData.Special do
            for itemUUID, _itemData in itemInstances do
                createItemTemplate( { ItemName = itemName, ItemCategory = "Special", ItemUUID = itemUUID } )
            end
        end

        -- then display items from other categories
        for categoryName, categoryItems in furnitureData do
            for itemName, itemInstances in categoryItems do
                for itemUUID, _itemData in itemInstances do
                    createItemTemplate( { ItemName = itemName, ItemCategory = categoryName, ItemUUID = itemUUID } )
                end
            end
        end
    end
end

local function resetEditSection()
    LockModeBtn.Visible = true
    TrashModeBtn.Visible = true
    ConfirmBtn.Visible = false
    CancelBtn.Visible = false
end

local function setInfoPanelDefault()
    StaffInfoPanel.Visible = false
    FurnitureInfoPanel.Visible = false
end

local function populateInventoryFrame()
    plrData = Remotes.Data.GetAllData:InvokeServer()
    studioAllPlrsInfo = Remotes.Studio.General.GetPlrsInStudioInfo:InvokeServer()

    clearScrollingFrame()
    resetEditSection()
    setInfoPanelDefault() -- by default info panel is hidden
    populateScrollingFrame()
end

local function enableEditMode(mode: "lock" | "trash")
    setInfoPanelDefault() -- hide info panel during edit-mode

    if mode == "lock" then
        inLockMode = true
        ExitModeBtn.Visible = true
    
    elseif mode == "trash" then
        defineTrashModeTable()
        inTrashMode = true
        ConfirmBtn.Visible = true
        CancelBtn.Visible = true
        AmtSelectedText.Text = AMT_SELECTED_TEXT:gsub("AMT", 0)
        AmtSelectedText.Visible = true
    end

    LockModeBtn.Visible = false
    TrashModeBtn.Visible = false
end

local function disableLockMode()
    inLockMode = false
end

local function disableTrashMode()
    inTrashMode = false
    AmtSelectedText.Visible = false
    amtOfItemsInTrashMode = 0

    -- hide all trash mode icons on item buttons
    for _i, instance in InventoryScrollingFrame:GetDescendants() do -- called twice to access the actual template btn children
        if instance.Name == "TrashModeIcon" then
            instance.Visible = false
        end
    end
end

local function disableEditMode()
    LockModeBtn.Visible = true
    TrashModeBtn.Visible = true

    ConfirmBtn.Visible = false
    CancelBtn.Visible = false
    ExitModeBtn.Visible = false

    disableLockMode()
    disableTrashMode()
end

local function updateItemTemplate(itemType: string, itemInfo: {}, isLocked: boolean)
    local itemScrollingFrameBtn = InventoryScrollingFrame:FindFirstChild(itemInfo.ItemUUID)
    if not itemScrollingFrameBtn then return end

    local itemLockedIcon = itemScrollingFrameBtn:FindFirstChild("LockIcon", true)
    itemLockedIcon.Visible = isLocked
end


-- ACTIVATE EVENTS --
LockModeBtn.Activated:Connect(function() enableEditMode("lock") end)

TrashModeBtn.Activated:Connect(function() enableEditMode("trash") end)

CancelBtn.Activated:Connect(disableEditMode)

ExitModeBtn.Activated:Connect(disableEditMode)

ConfirmBtn.Activated:Connect(function()
    if inTrashMode then
        Remotes.GUI.Inventory.DeleteItemPopup:Fire(inventoryCategory, itemsInTrashMode)
        return
    end
end)

StaffInventoryBtn.Activated:Connect(function()
    if inventoryCategory == "staff" then return end

    inventoryCategory = "staff"
    disableEditMode()
    populateInventoryFrame()
end)

FurnitureInventoryBtn.Activated:Connect(function()
    if inventoryCategory == "furniture" then return end

    inventoryCategory = "furniture"
    disableEditMode()
    populateInventoryFrame()
end)

ItemsInventoryBtn.Activated:Connect(function()
    if inventoryCategory == "items" then return end

    inventoryCategory = "items"
    disableEditMode()
    populateInventoryFrame()
end)


-- REMOTES --
Remotes.GUI.ChangeGuiStatusBindable.Event:Connect(function(guiName, showGui, _options)
    if guiName == "inventory" then
        if showGui then
            inventoryCategory = "staff"
            disableEditMode()
            populateInventoryFrame()
            GuiServices.ShowGuiStandard(InventoryContainer, GlobalVariables.Gui.GuiBackdropColourDefault)

        else
            GuiServices.HideGuiStandard(InventoryContainer)
        end
    end
end)

Remotes.Inventory.General.LockItem.OnClientEvent:Connect(updateItemTemplate)