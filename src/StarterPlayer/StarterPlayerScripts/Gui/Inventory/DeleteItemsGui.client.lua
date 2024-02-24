local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))
local GuiTemplates = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiTemplates"))
local GlobalVariables = require(ReplicatedStorage.GlobalVariables)
local GeneralConfig = require(ReplicatedStorage.Configs:WaitForChild("General"))
local StaffMemberConfig = require(ReplicatedStorage.Configs.Staff:WaitForChild("StaffMember"))
local StaffFoodConfig = require(ReplicatedStorage.Configs.Staff:WaitForChild("StaffFood"))
local MaterialConfig = require(ReplicatedStorage.Configs.Materials:WaitForChild("Materials"))
local FurnitureGeneralConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("Furniture"))
local MoodFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("MoodFurniture"))
local EnergyFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("EnergyFurniture"))
local HungerFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("HungerFurniture"))
local DecorFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("DecorFurniture"))
local GeneralUtils = require(ReplicatedStorage.Utils:WaitForChild("GeneralUtils"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui

-- GUI INSTANCES --
local AllGuiScreenGui = PlayerGui:WaitForChild("AllGui")

local DeleteItemsPopup = AllGuiScreenGui.Studio.StudioBuildMode:WaitForChild("DeleteItemsPopup")
local DeleteItemsHeader = DeleteItemsPopup:FindFirstChild("Header")
local DeleteItemsScrollingFrame = DeleteItemsPopup:FindFirstChild("ScrollingFrame", true)
local StaffTemplate = DeleteItemsScrollingFrame:FindFirstChild("StaffTemplate", true)
local FurnitureTemplate = DeleteItemsScrollingFrame:FindFirstChild("FurnitureTemplate", true)
local ItemTemplate = DeleteItemsScrollingFrame:FindFirstChild("ItemTemplate", true)
local DeleteItemsYesBtn = DeleteItemsPopup:FindFirstChild("YesBtn")
local DeleteItemsNoBtn = DeleteItemsPopup:FindFirstChild("NoBtn")

-- STATE VARIABLES --
local plrData = Remotes.Data.GetAllData:InvokeServer()
local currentItemsToDelete = nil
local itemTypeToDelete = nil


GuiServices.StoreInCache(DeleteItemsPopup)
GuiServices.DefaultMainGuiStyling(DeleteItemsPopup)

GuiTemplates.HeaderText(DeleteItemsHeader)

local function createStaffItemCard(itemInfo: {})
    local template = StaffTemplate:Clone()
    template.Name = "DeleteItemCard"

    local itemImage = template:FindFirstChild("ItemImage")
    local itemNameText = template:FindFirstChild("ItemName")
    local totalPtsText = template:FindFirstChild("TotalPts", true)
    local removeBtn = template:FindFirstChild("RemoveBtn")
    local rarityBg = template:FindFirstChild("RarityColour")

    local staffMemberData = plrData.Inventory.StaffMembers[itemInfo.ItemUUID]
    local staffInstance = StaffMemberConfig.new(itemInfo.ItemUUID, staffMemberData)
    local staffMemberConfig = StaffMemberConfig.GetConfig(staffInstance.Model)

    itemNameText.Text = `{staffInstance.Name} - {StaffMemberConfig.GetRarityName(staffInstance.Model)}`
    rarityBg.BackgroundColor3 = GeneralConfig.GetRarityColour(staffInstance.Rarity, "Primary")
    totalPtsText.Text = tostring(staffInstance:GetTotalSkillPts())
    itemImage.Image = GeneralUtils.GetDecalUrl(staffMemberConfig.IconStroke)

    local clickConnection
    clickConnection = removeBtn.Activated:Connect(function()
        -- remove item from currentItemsToDelete table
        local index = table.find(currentItemsToDelete, itemInfo.ItemUUID)
        table.remove(currentItemsToDelete, index)
        clickConnection:Disconnect()
        template:Destroy()
        return
    end)

    template.Visible = true
    return template
end

local function createFurnitureCard(amtOfItem: number, itemInfo: {})
    local template = FurnitureTemplate:Clone()
    template.Name = "DeleteItemCard"

    local itemImage = template:FindFirstChild("ItemImage")
    local itemNameText = template:FindFirstChild("ItemName")
    local itemAmtText = template:FindFirstChild("Amount")
    local removeBtn = template:FindFirstChild("RemoveBtn")
    local rarityBg = template:FindFirstChild("RarityColour")

    local numOfItemInstances = amtOfItem
    itemAmtText.Text = `x{numOfItemInstances}`

    itemNameText.Text = `{itemInfo.ItemName} - {itemInfo.ItemCategory}`

    local clickConnection
    clickConnection = removeBtn.Activated:Connect(function()
        numOfItemInstances -= 1
        itemAmtText.Text = `x{numOfItemInstances}`

        -- remove an instance of the item
        local lastIndex = #currentItemsToDelete[itemInfo.ItemCategory][itemInfo.ItemName]
        table.remove(currentItemsToDelete[itemInfo.ItemCategory][itemInfo.ItemName], lastIndex)

        if numOfItemInstances <= 0 then
            -- remove item from currentItemsToDelete table
            currentItemsToDelete[itemInfo.ItemCategory][itemInfo.ItemName] = nil
            clickConnection:Disconnect()
            template:Destroy()
            return
        end
    end)

    template.Visible = true
    return template
end

local function createItemCard(amtOfItem: number, itemInfo: {})
    local template = ItemTemplate:Clone()
    template.Name = "DeleteItemCard"

    local itemImage = template:FindFirstChild("ItemImage")
    local itemNameText = template:FindFirstChild("ItemName")
    local itemAmtText = template:FindFirstChild("Amount")
    local removeBtn = template:FindFirstChild("RemoveBtn")
    local rarityBg = template:FindFirstChild("RarityColour")

    local itemConfig = itemInfo.CategoryConfig.GetConfig(itemInfo.ItemName)
    rarityBg.BackgroundColor3 = GeneralConfig.GetRarityColour(itemConfig.Rarity, "Primary")

    local numOfItemInstances = amtOfItem
    itemNameText.Text = `{itemInfo.ItemName} - {itemInfo.ItemCategory}`
    itemAmtText.Text = `x{numOfItemInstances}`

    local clickConnection
    clickConnection = removeBtn.Activated:Connect(function()
        numOfItemInstances -= 1
        itemAmtText.Text = `x{numOfItemInstances}`

        -- remove 1 of the item
        currentItemsToDelete[itemInfo.ItemCategory][itemInfo.ItemName].Amount -= 1

        if numOfItemInstances <= 0 then
            -- remove item from currentItemsToDelete table
            currentItemsToDelete[itemInfo.ItemCategory][itemInfo.ItemName] = nil
            clickConnection:Disconnect()
            template:Destroy()
            return
        end
    end)

    template.Visible = true
    return template
end

local function clearDeleteItemsPopup()
    for _i, instance in DeleteItemsScrollingFrame:GetChildren() do
        if instance.Name == "UIListLayout" or instance.Name == "UIPadding" or instance.Name == "FurnitureTemplate"
        or instance.Name == "StaffTemplate" or instance.Name == "ItemTemplate" then continue end
        instance:Destroy()
    end
end

local function resetDeleteItemsGui()
    clearDeleteItemsPopup()
end

local function displayDeleteItemPopup()
    resetDeleteItemsGui()

    if itemTypeToDelete == "furniture" then
        for itemCategory, itemsInCategory in currentItemsToDelete do
            for itemName, itemInstances in itemsInCategory do
                if #itemInstances > 0 then
                    local furnitureConfig
                    if itemCategory == "Mood" then
                        furnitureConfig = MoodFurnitureConfig
                    elseif itemCategory == "Energy" then
                        furnitureConfig = EnergyFurnitureConfig
                    elseif itemCategory == "Hunger" then
                        furnitureConfig = HungerFurnitureConfig
                    elseif itemCategory == "Decor" then
                        furnitureConfig = DecorFurnitureConfig
                    end
                    local options = { ItemCategory = itemCategory, ItemName = itemName, FurnitureConfig = furnitureConfig }
                    local template = createFurnitureCard(#itemInstances, options)
                    template.Parent = DeleteItemsScrollingFrame
                end
            end
        end
    
    elseif itemTypeToDelete == "staff" then
        for _i, staffMemberUUID in currentItemsToDelete do
            local options = { ItemUUID = staffMemberUUID }
            local template = createStaffItemCard(options)
            template.Parent = DeleteItemsScrollingFrame
        end

    
    elseif itemTypeToDelete == "items" then
        local newCurrentItemsToDelete = {} -- reorganise currentItemsToDelete table so that it doesn't feature the 'fake uuids'

        for itemCategory, itemNames in currentItemsToDelete do
            newCurrentItemsToDelete[itemCategory] = {}
            for itemName, itemStacks in itemNames do
                newCurrentItemsToDelete[itemCategory][itemName] = { Amount = 0 }
                for _stack, stackInfo in itemStacks do
                    newCurrentItemsToDelete[itemCategory][itemName].Amount += stackInfo.Amount
                end
            end
        end
        currentItemsToDelete = newCurrentItemsToDelete

        for itemCategory, itemNames in currentItemsToDelete do
            local categoryConfig
            if itemCategory == "Staff Food" then
                categoryConfig = StaffFoodConfig
            elseif itemCategory == "Material" then
                categoryConfig = MaterialConfig
            end

            for itemName, itemInfo in itemNames do
                if itemInfo.Amount > 0 then
                    local options = { ItemCategory = itemCategory, ItemName = itemName, CategoryConfig = categoryConfig }
                    local template = createItemCard(itemInfo.Amount, options)
                    template.Parent = DeleteItemsScrollingFrame
                end
            end
        end
    end
end

-- REMOTES --
Remotes.GUI.Inventory.DeleteItemPopup.Event:Connect(function(itemType: string, itemsToDelete: {})
    plrData = Remotes.Data.GetAllData:InvokeServer()
    itemTypeToDelete = itemType
    currentItemsToDelete = itemsToDelete

    displayDeleteItemPopup()

    GuiServices.ShowGuiStandard(DeleteItemsPopup, GlobalVariables.Gui.GuiBackdropColourDefault)
end)

-- BTN ACTIVATIONS --
DeleteItemsYesBtn.Activated:Connect(function()
    GuiServices.HideGuiStandard(DeleteItemsPopup)

    Remotes.Inventory.General.DeleteItems:FireServer(itemTypeToDelete, currentItemsToDelete)
end)

DeleteItemsNoBtn.Activated:Connect(function()
    currentItemsToDelete = nil

    GuiServices.HideGuiStandard(DeleteItemsPopup)
end)