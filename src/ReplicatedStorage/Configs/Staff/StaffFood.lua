local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlobalVariables = require(ReplicatedStorage:WaitForChild("GlobalVariables"))

local StaffFood = {}

export type StaffFoodConfig = {
    Rarity: number,
    IconOriginal: string,
    IconStroke: string
}

local config: { [string]: StaffFoodConfig } = {
    ["Coffee"] = {
        Rarity = 1,
        IconOriginal = "",
        IconStroke = "",
    },
    ["Pizza"] = {
        Rarity = 1,
        IconOriginal = "",
        IconStroke = "",
    },
    ["Energy Drink"] = {
        Rarity = 2,
        IconOriginal = "",
        IconStroke = "",
    },
    ["Porridge"] = {
        Rarity = 2,
        IconOriginal = "",
        IconStroke = "",
    },
    ["Uranium"] = {
        Rarity = 5,
        IconOriginal = "",
        IconStroke = "",
    },
    ["Holy White Powder"] = {
        Rarity = 5,
        IconOriginal = "",
        IconStroke = "",
    },
}

StaffFood.Config = config

function StaffFood.GetConfig(foodName: string): StaffFoodConfig | nil
    return StaffFood.Config[foodName]
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