local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlobalVariables = require(ReplicatedStorage:WaitForChild("GlobalVariables"))

local Materials = {}

Materials.CategoryImage = "15814491509"

export type MaterialConfig = {
    Rarity: number,
    IconOriginal: string,
    IconStroke: string
}

local config: { [string]: MaterialConfig } = {
    ["Metal Scrap"] = {
        Rarity = 1,
        IconOriginal = "",
        IconStroke = "",
    },
    ["Wire"] = {
        Rarity = 1,
        IconOriginal = "",
        IconStroke = "",
    },
    ["Glass"] = {
        Rarity = 2,
        IconOriginal = "",
        IconStroke = "",
    },
    ["Circuit Board"] = {
        Rarity = 2,
        IconOriginal = "",
        IconStroke = "",
    },
    ["Fan"] = {
        Rarity = 3,
        IconOriginal = "",
        IconStroke = "",
    },
}

Materials.Config = config

function Materials.GetConfig(materialName: string): MaterialConfig | nil
    return Materials.Config[materialName]
end

function Materials.GetAllMaterialNames(): {}
    local allMaterialNames = {}
    for itemName, _itemInfo in Materials.Config do table.insert(allMaterialNames, itemName) end

    return allMaterialNames
end

function Materials.GetRarityName(materialName: string): string | nil
    local materialConfig = Materials.GetConfig(materialName)
    if not materialConfig then return nil end

    if materialConfig.Rarity == 1 then
        return "Common"
    elseif materialConfig.Rarity == 2 then
        return "Uncommon"
    elseif materialConfig.Rarity == 3 then
        return "Rare"
    elseif materialConfig.Rarity == 4 then
        return "Very Rare"
    elseif materialConfig.Rarity == 5 then
        return "Epic"
    elseif materialConfig.Rarity == 6 then
        return "Legendary"
    elseif materialConfig.Rarity == 7 then
        return "Mythical"
    end
end

function Materials.GetEnergyAmt(materialName: string): number | nil
    local materialConfig = Materials.GetConfig(materialName)
    if not materialConfig then return nil end

    if materialConfig.Rarity == 1 then
        return 99
    elseif materialConfig.Rarity == 2 then
        return 99
    elseif materialConfig.Rarity == 3 then
        return 99
    elseif materialConfig.Rarity == 4 then
        return 99
    elseif materialConfig.Rarity == 5 then
        return 99
    elseif materialConfig.Rarity == 6 then
        return 99
    elseif materialConfig.Rarity == 7 then
        return 99
    end
end


return Materials