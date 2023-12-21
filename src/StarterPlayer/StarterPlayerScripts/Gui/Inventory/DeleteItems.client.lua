local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))
local GlobalVariables = require(ReplicatedStorage.GlobalVariables)
local FurnitureGeneralConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("Furniture"))
local MoodFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("MoodFurniture"))
local EnergyFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("EnergyFurniture"))
local HungerFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("HungerFurniture"))
local DecorFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("DecorFurniture"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui

-- GUI INSTANCES --
local AllGuiScreenGui = PlayerGui:WaitForChild("AllGui")

local DeleteItemsPopup = AllGuiScreenGui.Studio.StudioBuildMode:WaitForChild("DeleteItemsPopup")
local DeleteItemsScrollingFrame = DeleteItemsPopup:WaitForChild("ScrollingFrame")
local DeleteItemsTemplate = DeleteItemsScrollingFrame:FindFirstChild("Template")
local DeleteItemsYesBtn = DeleteItemsPopup:FindFirstChild("YesBtn")
local DeleteItemsNoBtn = DeleteItemsPopup:FindFirstChild("NoBtn")
local DeleteItemsCoinRefundText = DeleteItemsPopup.RefundContainer.CoinsContainer:WaitForChild("Amount")

-- STATE VARIABLES --
local currentItemsToDelete = nil
local itemTypeToDelete = nil
local totalCoinRefund = 0

-- STATIC VARIABLES --
local DELETE_ITEM_CARD_NAME_TEMPLATE = "ITEM_NAME (xAMT)"
local DELETE_ITEM_CARD_REFUND_TEMPLATE = "+ AMT CURRENCY_TYPE"
local TOTAL_COINS_REFUND_TEXT = "+AMT Coins"

GuiServices.StoreInCache(DeleteItemsPopup)
GuiServices.DefaultMainGuiStyling(DeleteItemsPopup)


local function createDeleteItemCard(amtOfItem: number, itemInfo: {})
    local template = DeleteItemsTemplate:Clone()
    local itemImage = template:FindFirstChild("ItemImage")
    local itemNameText = template:FindFirstChild("ItemName")
    local itemRefundText = template:FindFirstChild("ItemRefund")
    local removeBtn = template:FindFirstChild("RemoveBtn")

    template.Name = "DeleteItemCard"

    local numOfItemInstances = amtOfItem

    local itemConfig = itemInfo.FurnitureConfig.GetConfig(itemInfo.ItemName)

    itemNameText.Text = DELETE_ITEM_CARD_NAME_TEMPLATE:gsub("ITEM_NAME", itemInfo.ItemName):gsub("AMT", tostring(numOfItemInstances))

    local itemRefund
    if itemConfig.Currency == "Coins" then
        itemRefund = math.floor((itemConfig.Price * numOfItemInstances) * FurnitureGeneralConfig.FurnitureRefundRate)
        itemRefundText.Text = DELETE_ITEM_CARD_REFUND_TEMPLATE:gsub("AMT", tostring(itemRefund)):gsub("CURRENCY_TYPE", itemConfig.Currency)
        itemRefundText.Visible = true
    end

    removeBtn.Activated:Connect(function()
        numOfItemInstances -= 1

        -- remove an instance of the item
        local lastIndex = #currentItemsToDelete[itemInfo.ItemCategory][itemInfo.ItemName]
        table.remove(currentItemsToDelete[itemInfo.ItemCategory][itemInfo.ItemName], lastIndex)

        if itemConfig.Currency == "Coins" then
            itemRefund = math.floor((itemConfig.Price * numOfItemInstances) * FurnitureGeneralConfig.FurnitureRefundRate)
            totalCoinRefund -= math.floor(itemConfig.Price * FurnitureGeneralConfig.FurnitureRefundRate)
            DeleteItemsCoinRefundText.Text = TOTAL_COINS_REFUND_TEXT:gsub("AMT", tostring(totalCoinRefund))
        end

        if numOfItemInstances <= 0 then
            -- remove item from currentItemsToDelete table
            currentItemsToDelete[itemInfo.ItemCategory][itemInfo.ItemName] = nil
            template:Destroy()
            return
        end

        itemNameText.Text = DELETE_ITEM_CARD_NAME_TEMPLATE:gsub("ITEM_NAME", itemInfo.ItemName):gsub("AMT", tostring(numOfItemInstances))
        itemRefundText.Text = DELETE_ITEM_CARD_REFUND_TEMPLATE:gsub("AMT", tostring(itemRefund)):gsub("CURRENCY_TYPE", itemConfig.Currency)
    end)

    template.Visible = true
    return template
end

local function clearDeleteItemsPopup()
    for _i, instance in DeleteItemsScrollingFrame:GetChildren() do
        if instance.Name == "UIListLayout" or instance.Name == "UIPadding" or instance.Name == "Template" then continue end
        instance:Destroy()
    end
end

local function resetDeleteItemsGui()
    clearDeleteItemsPopup()
    totalCoinRefund = 0
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
                    local template = createDeleteItemCard(#itemInstances, options)
                    template.Parent = DeleteItemsScrollingFrame
                    
                    local itemConfig = furnitureConfig.GetConfig(itemName)
                    if itemConfig.Currency == "Coins" then
                        totalCoinRefund += math.floor((itemConfig.Price * #itemInstances) * FurnitureGeneralConfig.FurnitureRefundRate)
                        DeleteItemsCoinRefundText.Text = TOTAL_COINS_REFUND_TEXT:gsub("AMT", tostring(totalCoinRefund))
                    end
                end
            end
        end
    end
end

-- REMOTES --
Remotes.GUI.Inventory.DeleteItemPopup.Event:Connect(function(itemType: string, itemsToDelete: {})
    currentItemsToDelete = itemsToDelete
    itemTypeToDelete = itemType

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

    Remotes.Studio.BuildMode.EnterBuildMode:FireServer()
end)