local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modelFolder = ReplicatedStorage.Assets.Models.Studio.StudioFurnishing.Decor

local DecorFurniture = {}

type DecorFurnitureConfig = {
    Price: number;
    Currency: string,
    Image: string,
}

DecorFurniture.CategoryImage = "15696116166"

local Config: { [string]: DecorFurnitureConfig } = {
    ["Book Stack"] = {
        Price = 99,
        Currency = "Coins",
        Image = "",
    },
    ["Crate"] = {
        Price = 99,
        Currency = "Coins",
        Image = "",
    },
    ["Pot Plant"] = {
        Price = 99,
        Currency = "Coins",
        Image = "",
    },
}

DecorFurniture.Config = Config

function DecorFurniture.GetAllFurnitureNames(): {}
    local allFurnitureNames = {}
    for itemName, _itemInfo in DecorFurniture.Config do table.insert(allFurnitureNames, itemName) end

    return allFurnitureNames
end

function DecorFurniture.GetConfig(itemName: string): DecorFurnitureConfig
    return DecorFurniture.Config[itemName]
end

function DecorFurniture.GetModel(itemName: string): Model
    return modelFolder:FindFirstChild(itemName):Clone()
end

return DecorFurniture