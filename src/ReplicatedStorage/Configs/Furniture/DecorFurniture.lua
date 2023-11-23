local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modelFolder = ReplicatedStorage.Assets.Models.Studio.StudioFurnishing.Decor

local DecorFurniture = {}

type DecorFurnitureConfig = {
    Price: number;
    Currency: string,
    ImageUrl: string
}

local Config: { [string]: DecorFurnitureConfig } = {
    ["Book Stack"] = {
        Price = 99,
        Currency = "Cash"
    },
    ["Crate"] = {
        Price = 99,
        Currency = "Cash"
    },
    ["Pot Plant"] = {
        Price = 99,
        Currency = "Cash"
    },
}

DecorFurniture.Config = Config

function DecorFurniture.GetConfig(itemName: string): DecorFurnitureConfig
    return DecorFurniture.Config[itemName]
end

function DecorFurniture.GetModel(itemName: string): Model
    return modelFolder:FindFirstChild(itemName):Clone()
end

return DecorFurniture