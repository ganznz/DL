local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlobalVariables = require(ReplicatedStorage:WaitForChild("GlobalVariables"))

local StaffFood = {}

StaffFood.CategoryImage = "15814511118"

export type StaffFoodConfig = {
    Rarity: number,
    IconOriginal: string,
    IconStroke: string,
    IconFill: string,
}

local config: { [string]: StaffFoodConfig } = {
    ["Coffee"] = {
        Rarity = 1,
        IconOriginal = "",
        IconStroke = "",
        IconFill = "",
    },
    ["Pizza"] = {
        Rarity = 1,
        IconOriginal = "",
        IconStroke = "15998279544",
        IconFill = "15998277391",
    },
    ["Energy Drink"] = {
        Rarity = 2,
        IconOriginal = "",
        IconStroke = "",
        IconFill = "",
    },
    ["Porridge"] = {
        Rarity = 2,
        IconOriginal = "",
        IconStroke = "",
        IconFill = "",
    },
    ["Uranium"] = {
        Rarity = 5,
        IconOriginal = "",
        IconStroke = "",
        IconFill = "",
    },
    ["Holy White Powder"] = {
        Rarity = 5,
        IconOriginal = "",
        IconStroke = "",
        IconFill = "",
    },
}

StaffFood.Config = config

function StaffFood.GetConfig(foodName: string): StaffFoodConfig | nil
    return StaffFood.Config[foodName]
end

function StaffFood.GetAllStaffFoodNames(): {}
    local allStaffFoodNames = {}
    for itemName, _itemInfo in StaffFood.Config do table.insert(allStaffFoodNames, itemName) end

    return allStaffFoodNames
end

function StaffFood.GetRarityName(foodName: string): string | nil
    local staffFoodConfig = StaffFood.GetConfig(foodName)
    if not staffFoodConfig then return nil end

    if staffFoodConfig.Rarity == 1 then
        return "Common"
    elseif staffFoodConfig.Rarity == 2 then
        return "Uncommon"
    elseif staffFoodConfig.Rarity == 3 then
        return "Rare"
    elseif staffFoodConfig.Rarity == 4 then
        return "Very Rare"
    elseif staffFoodConfig.Rarity == 5 then
        return "Epic"
    elseif staffFoodConfig.Rarity == 6 then
        return "Legendary"
    elseif staffFoodConfig.Rarity == 7 then
        return "Mythical"
    end
end

function StaffFood.GetEnergyAmt(foodName: string): number | nil
    local staffFoodConfig = StaffFood.GetConfig(foodName)
    if not staffFoodConfig then return nil end

    if staffFoodConfig.Rarity == 1 then
        return 99
    elseif staffFoodConfig.Rarity == 2 then
        return 99
    elseif staffFoodConfig.Rarity == 3 then
        return 99
    elseif staffFoodConfig.Rarity == 4 then
        return 99
    elseif staffFoodConfig.Rarity == 5 then
        return 99
    elseif staffFoodConfig.Rarity == 6 then
        return 99
    elseif staffFoodConfig.Rarity == 7 then
        return 99
    end
end


return StaffFood