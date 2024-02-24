-- // this file contains methods that are dependant on gameplay code, that don't fit into a specific category // --

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlobalVariables = require(ReplicatedStorage:WaitForChild("GlobalVariables"))
local StaffFoodConfig = require(ReplicatedStorage.Configs.Staff:WaitForChild("StaffFood"))
local MaterialsConfig = require(ReplicatedStorage.Configs.Materials:WaitForChild("Materials"))

local GeneralConfig = {}

-- holds all types of items that fall under the general "Items" category (staff food, materials, etc)
local allItems = {}
for foodName, _foodInfo in StaffFoodConfig.Config do allItems[foodName] = { Category = "Staff Food" } end
for materialName, _materialInfo in MaterialsConfig.Config do allItems[materialName] = { Category = "Material" } end

GeneralConfig.AllItems = allItems

function GeneralConfig.GetRarityColour(itemRarity: number, colourType: "Primary" | "Secondary"): Color3 | nil
    if itemRarity == 1 then
        return colourType == "Primary" and GlobalVariables.Gui.Rarity1PrimaryColour or GlobalVariables.Gui.Rarity1SecondaryColour
    elseif itemRarity == 2 then
        return colourType == "Primary" and GlobalVariables.Gui.Rarity2PrimaryColour or GlobalVariables.Gui.Rarity2SecondaryColour
    elseif itemRarity == 3 then
        return colourType == "Primary" and GlobalVariables.Gui.Rarity3PrimaryColour or GlobalVariables.Gu7.Rarity3SecondaryColour
    elseif itemRarity == 4 then
        return colourType == "Primary" and GlobalVariables.Gui.Rarity4PrimaryColour or GlobalVariables.Gui.Rarity4SecondaryColour
    elseif itemRarity == 5 then
        return colourType == "Primary" and GlobalVariables.Gui.Rarity5PrimaryColour or GlobalVariables.Gui.Rarity5SecondaryColour
    elseif itemRarity == 6 then
        return colourType == "Primary" and GlobalVariables.Gui.Rarity6PrimaryColour or GlobalVariables.Gui.Rarity6SecondaryColour
    elseif itemRarity == 7 then
        return colourType == "Primary" and GlobalVariables.Gui.Rarity7PrimaryColour or GlobalVariables.Gui.Rarity7SecondaryColour
    end
end

-- method gets the specific category of an item (staff food, material, etc) that falls under the general "Item" category
-- items fall under the general "Item" category in areas such as displayed in the inventory GUI
function GeneralConfig.GetItemCategory(itemName: string): string
    local itemInfo = GeneralConfig.AllItems[itemName]
    if not itemInfo then return end

    return itemInfo.Category
end

return GeneralConfig