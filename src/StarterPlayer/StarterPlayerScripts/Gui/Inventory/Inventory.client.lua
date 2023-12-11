local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))
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

local InventoryCategoryContainer = InventoryContainer.CategoryContainerOuter.CategoryContainerInner.CategoryContainer
local StaffFurnitureBtn = InventoryCategoryContainer:WaitForChild("StaffBtn")
local InventoryFurnitureBtn = InventoryCategoryContainer:WaitForChild("FurnitureBtn")
local ItemsFurnitureBtn = InventoryCategoryContainer:WaitForChild("ItemsBtn")

local EditSettingsContainer = InventoryContainer.EditSettingsOuter.EditSettingsInner:WaitForChild("Container")
local LockModeBtn = EditSettingsContainer:FindFirstChild("LockModeBtn")
local TrashModeBtn = EditSettingsContainer:FindFirstChild("TrashModeBtn")
local ConfirmBtn = EditSettingsContainer:FindFirstChild("ConfirmBtn")
local CancelBtn = EditSettingsContainer:FindFirstChild("CancelBtn")
local ExitModeBtn = EditSettingsContainer:FindFirstChild("ExitModeBtn") -- btn only applies to lock-mode

local InventoryScrollingFrame = InventoryContainer.InventoryContainerInner:WaitForChild("ScrollingFrame")
local ScrollingFrameFurnitureTemplate = InventoryScrollingFrame:WaitForChild("FurnitureTemplate")
local ScrollingFrameStaffTemplate = InventoryScrollingFrame:WaitForChild("StaffTemplate")

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

-- CONSTANT VARIABLES --
local REMOVE_FROM_STUDIO_TEXT = "Remove from Studio"
local PLACE_IN_STUDIO_TEXT = "Place in Studio"
local BE_IN_STUDIO_TEXT = "Enter your Studio to place"
local CURRENTLY_PLACED_TEXT = "Placed in: STUDIO_NAME"
local NOT_PLACED_TEXT = "Item not placed yet!"
local STAT_BOOST_BASE_TEXT = "+AMT STAT"
local LOCKED_ICON = "rbxassetid://15532080670"

GuiServices.StoreInCache(InventoryContainer)

GuiServices.DefaultMainGuiStyling(InventoryContainer)


local function clearScrollingFrame()
    for _i, instance in InventoryScrollingFrame:GetChildren() do
        if instance.Name == "UIGridLayout" or instance.Name == "UIPadding" or instance.Name == "FurnitureTemplate" or instance.Name == "StaffTemplate" then continue end

        instance:Destroy()
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

local function populateFurnitureInfoPanel(furnitureConfig, itemInfo: {})
    FurnitureInfoItemIcon.Image = furnitureConfig.Image
    -- FurnitureInfoItemTypeIcon.Image = 
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
    if furnitureConfig["Stats"] then
        for statName, boostValue in furnitureConfig.Stats do
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

local function registerItemClickConnection(itemBtn, config, itemInfo: {})
    itemBtn.Activated:Connect(function()
        if inLockMode then
            Remotes.Inventory.General.LockItem:FireServer("furniture", itemInfo)

        return
        elseif inTrashMode then
        
        return
        end

        if inventoryCategory == "staff" then
            
        elseif inventoryCategory == "furniture" then
            populateFurnitureInfoPanel(config, itemInfo)
            FurnitureInfoPanel.Visible = true

        elseif inventoryCategory == "items" then
        
        end
    end)
end

local function createItemTemplate(itemInfo: {})
    local template
    local config

    if inventoryCategory == "staff" then
        
    elseif inventoryCategory == "furniture" then
        if itemInfo.ItemCategory == "Mood" then
            config = MoodFurnitureConfig.GetConfig(itemInfo.ItemName)
        elseif itemInfo.ItemCategory == "Energy" then
            config = EnergyFurnitureConfig.GetConfig(itemInfo.ItemName)
        elseif itemInfo.ItemCategory == "Hunger" then
            config = HungerFurnitureConfig.GetConfig(itemInfo.ItemName)
        elseif itemInfo.ItemCategory == "Decor" then
            config = DecorFurnitureConfig.GetConfig(itemInfo.ItemName)
        end

        template = ScrollingFrameFurnitureTemplate:Clone()
        local nameText = template:FindFirstChild("Name")
        local itemIcon = template:FindFirstChild("Icon")
        local itemTypeIcon = template:FindFirstChild("TypeIcon")
        local itemLockedIcon = template:FindFirstChild("LockIcon")

        local isLocked = plrData.Inventory.StudioFurnishing[itemInfo.ItemCategory][itemInfo.ItemName][itemInfo.ItemUUID].Locked
        itemLockedIcon.Image = if isLocked then LOCKED_ICON else ""

        nameText.Text = itemInfo.ItemName
        itemIcon.Image = config.Image

        if config then
            registerItemClickConnection(template, config, itemInfo)
        end
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
        inTrashMode = true
        ConfirmBtn.Visible = true
        CancelBtn.Visible = true
    end

    LockModeBtn.Visible = false
    TrashModeBtn.Visible = false
end

local function disableEditMode()
    inLockMode = false
    inTrashMode = false

    LockModeBtn.Visible = true
    TrashModeBtn.Visible = true

    ConfirmBtn.Visible = false
    CancelBtn.Visible = false
    ExitModeBtn.Visible = false
end

local function updateItemTemplate(itemType: string, itemInfo: {}, isLocked: boolean)
    local itemScrollingFrameBtn = InventoryScrollingFrame:FindFirstChild(itemInfo.ItemUUID)
    if not itemScrollingFrameBtn then return end

    local itemLockedIcon = itemScrollingFrameBtn:FindFirstChild("LockIcon")
    itemLockedIcon.Image = if isLocked then LOCKED_ICON else ""
end


-- ACTIVATE EVENTS --
LockModeBtn.Activated:Connect(function() enableEditMode("lock") end)

TrashModeBtn.Activated:Connect(function() enableEditMode("trash") end)

CancelBtn.Activated:Connect(disableEditMode)

ExitModeBtn.Activated:Connect(disableEditMode)

StaffFurnitureBtn.Activated:Connect(function()
    if inventoryCategory == "staff" then return end

    inventoryCategory = "staff"
    disableEditMode()
    populateInventoryFrame()
end)

InventoryFurnitureBtn.Activated:Connect(function()
    if inventoryCategory == "furniture" then return end

    inventoryCategory = "furniture"
    disableEditMode()
    populateInventoryFrame()
end)

ItemsFurnitureBtn.Activated:Connect(function()
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