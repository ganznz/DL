local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))
local GuiTemplates = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiTemplates"))
local GeneralUtils = require(ReplicatedStorage.Utils:WaitForChild("GeneralUtils"))
local GeneralConfig = require(ReplicatedStorage.Configs:WaitForChild("General"))
local GlobalVariables = require(ReplicatedStorage.GlobalVariables)
local StudioConfig = require(ReplicatedStorage.Configs.Studio:WaitForChild("Studio"))
local StaffMemberConfig = require(ReplicatedStorage.Configs.Staff:WaitForChild("StaffMember"))
local StaffFoodConfig = require(ReplicatedStorage.Configs.Staff:WaitForChild("StaffFood"))
local MaterialsConfig = require(ReplicatedStorage.Configs.Materials:WaitForChild("Materials"))
local HungerFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("HungerFurniture"))
local EnergyFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("EnergyFurniture"))
local MoodFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("MoodFurniture"))
local DecorFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("DecorFurniture"))
local DateTimeUtils = require(ReplicatedStorage.Utils.DateTime:WaitForChild("DateTime"))
local FormatNumber = require(ReplicatedStorage.Libs.FormatNumber.Simple)

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

local InventoryScrollingFrame = InventoryContainer.InventoryContainerInner:FindFirstChild("ScrollingFrame")
local ScrollingFrameFurnitureTemplateContainer = InventoryScrollingFrame:FindFirstChild("FurnitureTemplateContainer")
local ScrollingFrameStaffTemplateContainer = InventoryScrollingFrame:FindFirstChild("StaffTemplateContainer")
local ScrollingFrameItemTemplateContainer = InventoryScrollingFrame:FindFirstChild("ItemTemplateContainer")

local FurnitureInfoPanel = InventoryContainer.InventoryContainerInner:FindFirstChild("FurnitureInfoPanel")
local FurnitureInfoItemIcon = FurnitureInfoPanel:FindFirstChild("ItemIcon")
local FurnitureInfoItemTypeIcon = FurnitureInfoPanel:FindFirstChild("ItemTypeIcon")
local FurnitureInfoItemName = FurnitureInfoPanel:FindFirstChild("ItemName")
local FurnitureItemPlacedInText = FurnitureInfoPanel:FindFirstChild("PlacedInText")
local FurnitureInfoPlaceBtn = FurnitureInfoPanel:FindFirstChild("PlaceBtn")
local FurnitureInfoStatContainer = FurnitureInfoPanel:FindFirstChild("ItemStatContainer")
local FurnitureInfoStatTemplate = FurnitureInfoStatContainer:FindFirstChild("FurnitureInfoTemplate")

local StaffInfoPanel = InventoryContainer.InventoryContainerInner:FindFirstChild("StaffInfoPanel")
local StaffInfoItemIcon = StaffInfoPanel:FindFirstChild("ItemIcon")
local StaffInfoRarity = StaffInfoPanel:FindFirstChild("Rarity")
local StaffInfoItemName = StaffInfoPanel:FindFirstChild("ItemName")
local StaffInfoEnergyContainer = StaffInfoPanel:FindFirstChild("EnergyContainer")
local StaffInfoEnergyBarProg = StaffInfoEnergyContainer:FindFirstChild("EnergyProg", true)
local StaffInfoEnergyBarText = StaffInfoEnergyContainer:FindFirstChild("Energy")
local StaffInfoEnergyTimer = StaffInfoPanel:FindFirstChild("EnergyTimer")
local StaffInfoPtsContainer = StaffInfoPanel:FindFirstChild("SkillPtsContainer")
local CodingPtsContainer = StaffInfoPtsContainer:FindFirstChild("CodingPts")
local CodingPtsAmt = CodingPtsContainer:FindFirstChild("PtsAmt")
local ArtistPtsContainer = StaffInfoPtsContainer:FindFirstChild("ArtistPts")
local ArtistPtsAmt = ArtistPtsContainer:FindFirstChild("PtsAmt")
local SoundPtsContainer = StaffInfoPtsContainer:FindFirstChild("SoundPts")
local SoundPtsAmt = SoundPtsContainer:FindFirstChild("PtsAmt")
local StaffInfoPlaceBtn = StaffInfoPanel:FindFirstChild("PlaceBtn")

local ItemInfoPanel = InventoryContainer.InventoryContainerInner:FindFirstChild("ItemInfoPanel")
local ItemInfoItemIcon = ItemInfoPanel:FindFirstChild("ItemIcon")
local ItemInfoItemTypeIcon = ItemInfoPanel:FindFirstChild("ItemTypeIcon")
local ItemInfoRarity = ItemInfoPanel:FindFirstChild("Rarity")
local ItemInfoItemName = ItemInfoPanel:FindFirstChild("ItemName")
local ItemInfoTotalOwnedText = ItemInfoPanel:FindFirstChild("TotalOwned")

-- STATE VARIABLES --
local plrData = nil
local studioAllPlrsInfo = nil
local inventoryCategory = "staff" -- category that is currently being viewed, defaults to Staff when UI opens ("staff" | "furniture" | "items")
local inLockMode = false
local inTrashMode = false
local placeBtnConnection = nil
local itemsInTrashMode = {}
local amtOfItemsInTrashMode = 0
local currentlyViewedItemInfo = nil -- item info of the instance that is being viewed in the info panel

-- CONSTANT VARIABLES --
local REMOVE_FROM_STUDIO_TEXT = "Remove from Studio"
local PLACE_IN_STUDIO_TEXT = "Place in Studio"
local BE_IN_STUDIO_TEXT = "Enter your Studio to place"
local CURRENTLY_PLACED_TEXT = "Placed in: STUDIO_NAME"
local NOT_PLACED_TEXT = "Item not placed yet!"
local AMT_TEXT = "xAMT"
local TOTAL_OWNED_TEXT = "Total Owned: xAMT"
local STAT_BOOST_BASE_TEXT = "+AMT STAT"
local AMT_SELECTED_TEXT = "AMT SELECTED!"
local ENERGY_TEXT = "CURRENT / MAX"
local ENERGY_FULL_IN_TEXT = "Full in: FORMATTED_TIME"
local ALL_TRASH_MODE_ICON_IDS = {}

GuiServices.StoreInCache(InventoryContainer)

GuiServices.DefaultMainGuiStyling(InventoryContainer)

GuiTemplates.CreateButton(StaffInventoryBtn, { Rotates = true })
GuiTemplates.CreateButton(FurnitureInventoryBtn, { Rotates = true })
GuiTemplates.CreateButton(ItemsInventoryBtn, { Rotates = true })
GuiTemplates.CreateButton(LockModeBtn)
GuiTemplates.CreateButton(TrashModeBtn)
GuiTemplates.CreateButton(ConfirmBtn)
GuiTemplates.CreateButton(CancelBtn)
GuiTemplates.CreateButton(ExitModeBtn)

GuiTemplates.HeaderText(AmtSelectedText)

local function clearScrollingFrame()
    for _i, instance in InventoryScrollingFrame:GetChildren() do
        if instance.Name == "UIGridLayout" or instance.Name == "UIPadding" or instance.Name == "FurnitureTemplateContainer" or instance.Name == "StaffTemplateContainer"
            or instance.Name == "ItemTemplateContainer" then continue end

        instance:Destroy()
    end
end

local function defineTrashModeTable()
    -- reset trash mode table
    itemsInTrashMode = {}

    if inventoryCategory == "staff" then
        -- keep as as empty table
        
    elseif inventoryCategory == "furniture" then
        itemsInTrashMode["Energy"] = {}
        itemsInTrashMode["Mood"] = {}
        itemsInTrashMode["Hunger"] = {}
        itemsInTrashMode["Decor"] = {}
        for _i, itemName in EnergyFurnitureConfig.GetAllFurnitureNames() do itemsInTrashMode["Energy"][itemName] = {} end
        for _i, itemName in MoodFurnitureConfig.GetAllFurnitureNames() do itemsInTrashMode["Mood"][itemName] = {} end
        for _i, itemName in HungerFurnitureConfig.GetAllFurnitureNames() do itemsInTrashMode["Hunger"][itemName] = {} end
        for _i, itemName in DecorFurnitureConfig.GetAllFurnitureNames() do itemsInTrashMode["Decor"][itemName] = {} end
    
    elseif inventoryCategory == "items" then
        itemsInTrashMode["Staff Food"] = {}
        itemsInTrashMode["Material"] = {}
        for _i, itemName in StaffFoodConfig.GetAllStaffFoodNames() do itemsInTrashMode["Staff Food"][itemName] = {} end
        for _i, itemName in MaterialsConfig.GetAllMaterialNames() do itemsInTrashMode["Material"][itemName] = {} end
    end
end

local function toggleItemTrashMode(itemInfo: {}): boolean
    -- check if item is locked first
    if inventoryCategory == "staff" then
        local isLocked = plrData.Inventory.StaffMembers[itemInfo.ItemInstance.UUID].Locked
        if isLocked then return false end

    elseif inventoryCategory == "furniture" then
        local isLocked = plrData.Inventory.StudioFurnishing[itemInfo.ItemCategory][itemInfo.ItemName][itemInfo.ItemUUID].Locked
        if isLocked then return false end
    end

    if inventoryCategory == "staff" then
        local index = table.find(itemsInTrashMode, itemInfo.ItemInstance.UUID)
        if index then
            -- item is currently in trash table, remove from table
            table.remove(itemsInTrashMode, index)
            amtOfItemsInTrashMode -= 1
            return false
        else
            table.insert(itemsInTrashMode, itemInfo.ItemInstance.UUID)
            amtOfItemsInTrashMode += 1
            return true
        end

    elseif inventoryCategory == "furniture" then
        local index = table.find(itemsInTrashMode[itemInfo.ItemCategory][itemInfo.ItemName], itemInfo.ItemUUID)
        if index then
            table.remove(itemsInTrashMode[itemInfo.ItemCategory][itemInfo.ItemName], index)
            amtOfItemsInTrashMode -= 1
            return false
        else
            table.insert(itemsInTrashMode[itemInfo.ItemCategory][itemInfo.ItemName], itemInfo.ItemUUID)
            amtOfItemsInTrashMode += 1
            return true
        end
    
    elseif inventoryCategory == "items" then
        if itemsInTrashMode[itemInfo.ItemCategory][itemInfo.ItemName][itemInfo.FakeUUID] then
            itemsInTrashMode[itemInfo.ItemCategory][itemInfo.ItemName][itemInfo.FakeUUID] = nil
            amtOfItemsInTrashMode -= 1
            return false
        else
            itemsInTrashMode[itemInfo.ItemCategory][itemInfo.ItemName][itemInfo.FakeUUID] = { Amount = itemInfo.ItemAmt }
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
    studioAllPlrsInfo = Remotes.Studio.General.GetPlrsInStudioInfo:InvokeServer()

    local studioPlrInfo = studioAllPlrsInfo[tostring(localPlr.UserId)]

    -- plr not in their own studio
    if not studioPlrInfo or studioPlrInfo["PlrVisitingId"] ~= localPlr.UserId then
        placeBtn.Text = BE_IN_STUDIO_TEXT
        placeBtn.BackgroundColor3 = GlobalVariables.Gui.InvalidGreyColour
        return
    end

    -- plr in their own studio
    local studioConfig = StudioConfig.GetConfig(studioPlrInfo.StudioIndex)

    local studioType = studioConfig.StudioType
    local itemInStudio = StudioConfig.ItemInStudio(plrData, inventoryCategory, studioType, studioPlrInfo.StudioIndex, itemInfo)

    -- if item is in studio, button should remove item
    if itemInStudio then
        placeBtn.Text = REMOVE_FROM_STUDIO_TEXT
        placeBtn.BackgroundColor3 = GlobalVariables.Gui.InvalidRedColour

        placeBtnConnection = placeBtn.Activated:Connect(function()
            Remotes.Studio.BuildMode.StoreItem:FireServer(inventoryCategory, itemInfo)
            GuiServices.HideGuiStandard()
        end)

    -- btn when activated should enter place mode w that item
    else
        placeBtn.Text = PLACE_IN_STUDIO_TEXT
        placeBtn.BackgroundColor3 = GlobalVariables.Gui.ValidGreenColour

        placeBtnConnection = placeBtn.Activated:Connect(function()
            Remotes.Studio.BuildMode.EnterBuildMode:FireServer()
            task.wait(0.2) -- let EnterBuildMode remote do its thing before calling EnterPlaceMode remote (thanks to my shit code)
            Remotes.Studio.BuildMode.EnterPlaceMode:FireServer(inventoryCategory, itemInfo, false)
            GuiServices.HideGuiStandard()
        end)
    end
end

-- function determines *what* place btn gets used
local function registerPlaceItemBtn(itemInfo: {})
    if inventoryCategory == "furniture" then
        determinePlaceBtnSettings(FurnitureInfoPlaceBtn, itemInfo)
    elseif inventoryCategory == "staff" then
        determinePlaceBtnSettings(StaffInfoPlaceBtn, itemInfo.ItemInfo)
    end
end

local function populateFurnitureInfoPanel(itemInfo: {})
    FurnitureInfoItemIcon.Image = GeneralUtils.GetDecalUrl(itemInfo.ItemConfig.IconStroke)
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

local function setStaffInfoPanelEnergyBar(itemInstance: {})
    local tween = TweenService:Create(StaffInfoEnergyBarProg, TweenInfo.new(0.3), { Size = UDim2.fromScale(itemInstance.CurrentEnergy / itemInstance:CalcMaxEnergy(), 1) })
    tween:Play()

    StaffInfoEnergyBarText.Text = ENERGY_TEXT:gsub("CURRENT", FormatNumber.FormatCompact(itemInstance.CurrentEnergy)):gsub("MAX", FormatNumber.FormatCompact(itemInstance:CalcMaxEnergy()))
end

local function setStaffInfoPanelEnergyTime(secUntilFull: number)
    local hideTextTween
    local showTextTween

    if secUntilFull <= 0 then
        hideTextTween = TweenService:Create(StaffInfoEnergyTimer, TweenInfo.new(0.2), { TextTransparency = 1 })

    elseif StaffInfoEnergyTimer.TextTransparency == 1 then
        showTextTween = TweenService:Create(StaffInfoEnergyTimer, TweenInfo.new(0.2), { TextTransparency = 0 })
    end

    StaffInfoEnergyTimer.Text = ENERGY_FULL_IN_TEXT:gsub("FORMATTED_TIME", DateTimeUtils.FormatTimeLeft(secUntilFull))

    if hideTextTween then hideTextTween:Play() end
    if showTextTween then showTextTween:Play() end

    StaffInfoEnergyTimer.Text = ENERGY_FULL_IN_TEXT:gsub("FORMATTED_TIME", DateTimeUtils.FormatTimeLeft(secUntilFull))
end

local function populateStaffInfoPanel(itemInfo: {})
    StaffInfoItemIcon.Image = GeneralUtils.GetDecalUrl(itemInfo.ItemConfig.IconStroke)
    StaffInfoRarity.Text = itemInfo.CategoryConfig.GetRarityName(itemInfo.ItemInstance.Model)
    StaffInfoItemName.Text = itemInfo.ItemInstance.Name
    CodingPtsAmt.Text = tostring(itemInfo.ItemInstance:GetSpecificSkillPoints("code"))
    SoundPtsAmt.Text = tostring(itemInfo.ItemInstance:GetSpecificSkillPoints("sound"))
    ArtistPtsAmt.Text = tostring(itemInfo.ItemInstance:GetSpecificSkillPoints("art"))

    setStaffInfoPanelEnergyBar(itemInfo.ItemInstance)
    setStaffInfoPanelEnergyTime(itemInfo.ItemInstance:CalcTimeUntilFullEnergy())

    -- register place btn
    registerPlaceItemBtn(itemInfo)
end

local function populateItemsInfoPanel(itemInfo: {})
    ItemInfoItemIcon.Image = GeneralUtils.GetDecalUrl(itemInfo.ItemConfig.IconStroke)
    ItemInfoItemTypeIcon.Image = GeneralUtils.GetDecalUrl(itemInfo.CategoryConfig.CategoryImage)
    ItemInfoRarity.Text = itemInfo.CategoryConfig.GetRarityName(itemInfo.ItemName)
    ItemInfoItemName.Text = itemInfo.ItemName
    ItemInfoTotalOwnedText.Text = TOTAL_OWNED_TEXT:gsub("AMT", tostring(itemInfo.TotalAmt))
end

local function registerItemClickConnection(itemBtn, itemInfo: {})
    itemBtn.Activated:Connect(function()
        currentlyViewedItemInfo = itemInfo

        if inLockMode then
            local itemInfoToSend
            if inventoryCategory == "furniture" then
                itemInfoToSend = itemInfo
            elseif inventoryCategory == "staff" then
                itemInfoToSend = itemInfo.ItemInstance
            end
            
            Remotes.Inventory.General.LockItem:FireServer(inventoryCategory, itemInfoToSend)
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
            populateStaffInfoPanel(itemInfo)
            StaffInfoPanel.Visible = true
            
        elseif inventoryCategory == "furniture" then
            populateFurnitureInfoPanel(itemInfo)
            FurnitureInfoPanel.Visible = true

        elseif inventoryCategory == "items" then
            populateItemsInfoPanel(itemInfo)
            ItemInfoPanel.Visible = true
            
        end
    end)
end

local function createItemTemplate(itemInfo: {})
    local template
    local templateBtn
    local categoryConfig
    local itemConfig

    local itemIcon

    if inventoryCategory == "staff" then
        local itemInstance = itemInfo.ItemInstance
        categoryConfig = StaffMemberConfig
        itemConfig = categoryConfig.GetConfig(itemInstance.Name)

        template = ScrollingFrameStaffTemplateContainer:Clone()
        templateBtn = template:FindFirstChild("StaffTemplate")
        local totalPtsText = templateBtn:FindFirstChild("TotalPts")
        local itemLockedIcon = templateBtn:FindFirstChild("LockIcon")
        template.Name = itemInstance.UUID

        templateBtn.BackgroundColor3 = GeneralConfig.GetRarityColour(itemInstance.Rarity)

        local isLocked = plrData.Inventory.StaffMembers[itemInstance.UUID].Locked
        itemLockedIcon.Visible = isLocked

        totalPtsText.Text = itemInstance:GetTotalSkillPts()
        
    elseif inventoryCategory == "furniture" then
        if itemInfo.ItemCategory == "Mood" then
            categoryConfig = MoodFurnitureConfig
            itemConfig = categoryConfig.GetConfig(itemInfo.ItemName)
        elseif itemInfo.ItemCategory == "Energy" then
            categoryConfig = EnergyFurnitureConfig
            itemConfig = categoryConfig.GetConfig(itemInfo.ItemName)
        elseif itemInfo.ItemCategory == "Hunger" then
            categoryConfig = HungerFurnitureConfig
            itemConfig = categoryConfig.GetConfig(itemInfo.ItemName)
        elseif itemInfo.ItemCategory == "Decor" then
            categoryConfig = DecorFurnitureConfig
            itemConfig = categoryConfig.GetConfig(itemInfo.ItemName)
        end

        template = ScrollingFrameFurnitureTemplateContainer:Clone()
        templateBtn = template:FindFirstChild("FurnitureTemplate")
        local nameText = templateBtn:FindFirstChild("Name")
        local itemTypeIcon = templateBtn:FindFirstChild("TypeIcon")
        local itemLockedIcon = templateBtn:FindFirstChild("LockIcon")

        itemTypeIcon.Image = GeneralUtils.GetDecalUrl(categoryConfig.CategoryImage)
        local isLocked = plrData.Inventory.StudioFurnishing[itemInfo.ItemCategory][itemInfo.ItemName][itemInfo.ItemUUID].Locked
        itemLockedIcon.Visible = isLocked

        nameText.Text = itemInfo.ItemName
        template.Name = itemInfo.ItemUUID
    
    elseif inventoryCategory == "items" then
        if itemInfo.ItemCategory == "Staff Food" then
            categoryConfig = StaffFoodConfig
            itemConfig = categoryConfig.GetConfig(itemInfo.ItemName)
            
        elseif itemInfo.ItemCategory == "Material" then
            categoryConfig = MaterialsConfig
            itemConfig = categoryConfig.GetConfig(itemInfo.ItemName)
        end

        template = ScrollingFrameItemTemplateContainer:Clone()
        templateBtn = template:FindFirstChild("ItemTemplate")
        local nameText = templateBtn:FindFirstChild("Name")
        local itemAmtText = templateBtn:FindFirstChild("Amt")
        local itemTypeIcon = templateBtn:FindFirstChild("TypeIcon")

        templateBtn.BackgroundColor3 = GeneralConfig.GetRarityColour(itemConfig.Rarity)
        itemTypeIcon.Image = GeneralUtils.GetDecalUrl(categoryConfig.CategoryImage)

        nameText.Text = itemInfo.ItemName
        itemAmtText.Text = AMT_TEXT:gsub("AMT", tostring(itemInfo.ItemAmt))
        template.Name = itemInfo.FakeUUID
    end

    itemIcon = templateBtn:FindFirstChild("Icon")
    itemIcon.Image = GeneralUtils.GetDecalUrl(itemConfig.IconStroke)

    itemInfo["ItemConfig"] = itemConfig
    itemInfo["CategoryConfig"] = categoryConfig
    registerItemClickConnection(templateBtn, itemInfo)
    GuiTemplates.CreateButton(templateBtn, { Rotates = true })

    template.Visible = true
    template.Parent = InventoryScrollingFrame

    return template
end

local function populateScrollingFrame()
    if inventoryCategory == "staff" then
        for staffMemberUUID, staffMemberData in plrData.Inventory.StaffMembers do
            local itemInstance = StaffMemberConfig.new(staffMemberUUID, staffMemberData)

            -- this is the table that gets sent w/ remotes. Cannot send itemInstance table as that is cyclic
            local itemInfo = { ItemUUID = staffMemberUUID, ItemModel = staffMemberData.Model }

            createItemTemplate({ ItemInstance = itemInstance, ItemInfo = itemInfo})
        end

    elseif inventoryCategory == "furniture" then
        -- display special-tier furniture items first
        for itemName, itemInstances in plrData.Inventory.StudioFurnishing.Special do
            for itemUUID, _itemData in itemInstances do
                createItemTemplate( {
                    ItemName = itemName,
                    ItemCategory = "Special",
                    ItemUUID = itemUUID
                } )
            end
        end

        -- then display items from other categories
        for categoryName, categoryItems in plrData.Inventory.StudioFurnishing do
            if categoryItems == "Special" then continue end

            for itemName, itemInstances in categoryItems do
                for itemUUID, _itemData in itemInstances do
                    createItemTemplate( {
                        ItemName = itemName,
                        ItemCategory = categoryName,
                        ItemUUID = itemUUID
                    } )
                end
            end
        end
    
    elseif inventoryCategory == "items" then
        -- staff food
        for foodName, foodData in plrData.Inventory.StaffFood do
            local index = 1 -- index is incremented and added to itemInfo, as a way of tracking 'uuid' in trash mode
            local amt = foodData.Amount
            if amt == 0 then continue end
            if amt <= 10 then
                createItemTemplate({ ItemName = foodName, ItemAmt = amt, TotalAmt = foodData.Amount, ItemCategory = "Staff Food", FakeUUID = `{foodName}{tostring(index)}` })
            else
                while amt > 0 do
                    createItemTemplate({ ItemName = foodName, ItemAmt = amt, TotalAmt = foodData.Amount, ItemCategory = "Staff Food", FakeUUID = `{foodName}{tostring(index)}` })
                    amt -= 10
                    index += 1
                end
            end
        end

        -- materials
        for materialName, materialData in plrData.Inventory.Materials do
            local index = 1
            local amt = materialData.Amount
            if amt == 0 then continue end
            if amt <= 10 then
                createItemTemplate({ ItemName = materialName, ItemAmt = amt, TotalAmt = materialData.Amount, ItemCategory = "Material", FakeUUID = `{materialName}{tostring(index)}` })
            else
                while amt > 0 do
                    createItemTemplate({ ItemName = materialName, ItemAmt = amt, TotalAmt = materialData.Amount, ItemCategory = "Material", FakeUUID = `{materialName}{tostring(index)}` })
                    amt -= 10
                    index += 1
                end
            end
        end
    end
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
    LockModeBtn.Visible = inventoryCategory == "staff" or inventoryCategory == "furniture"
    TrashModeBtn.Visible = true

    ConfirmBtn.Visible = false
    CancelBtn.Visible = false
    ExitModeBtn.Visible = false

    disableLockMode()
    disableTrashMode()
end

local function setInfoPanelDefault()
    StaffInfoPanel.Visible = false
    FurnitureInfoPanel.Visible = false
    ItemInfoPanel.Visible = false
end

local function populateInventoryFrame()
    plrData = Remotes.Data.GetAllData:InvokeServer()

    clearScrollingFrame()
    disableEditMode()
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

local function updateItemTemplate(_itemType: string, itemUUID: string, isLocked: boolean)
    local itemScrollingFrameBtn = InventoryScrollingFrame:FindFirstChild(itemUUID)
    if not itemScrollingFrameBtn then return end

    local itemLockedIcon = itemScrollingFrameBtn:FindFirstChild("LockIcon", true)
    itemLockedIcon.Visible = isLocked
end


-- ACTIVATE EVENTS --
InventoryExitBtn.Activated:Connect(function()
    GuiServices.HideGuiStandard(InventoryContainer)
    Remotes.GUI.ToggleBottomHUD:Fire(nil)
end)

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

Remotes.Staff.AdjustEnergy.OnClientEvent:Connect(function(staffMemberUUID: string, staffMemberData: {})
    if inventoryCategory ~= "staff" then return end

    if InventoryContainer.Visible and StaffInfoPanel.Visible and currentlyViewedItemInfo then
        local currentlyViewedItemInstance = currentlyViewedItemInfo.ItemInstance

        if currentlyViewedItemInstance.UUID == staffMemberUUID then
            currentlyViewedItemInfo.ItemInstance = StaffMemberConfig.new(currentlyViewedItemInstance.UUID, staffMemberData) -- refresh staff member instance
            
            setStaffInfoPanelEnergyBar(currentlyViewedItemInfo.ItemInstance)
        end
    end
end)

Remotes.Staff.UpdateEnergyFullTimer.OnClientEvent:Connect(function(staffMemberUUID: string, secondsUntilFull: number)
    if inventoryCategory ~= "staff" then return end

    if InventoryContainer.Visible and StaffInfoPanel.Visible and currentlyViewedItemInfo then
        local currentlyViewedItemInstance = currentlyViewedItemInfo.ItemInstance

        if currentlyViewedItemInstance.UUID == staffMemberUUID then
            setStaffInfoPanelEnergyTime(secondsUntilFull)
        end
    end
end)