local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modelFolder = ReplicatedStorage.Assets.Models.StudioFurnishing.Decor

local DecorFurniture = {}

type DecorFurnitureConfig = {
}

local Config: { [string]: DecorFurnitureConfig } = {
}

DecorFurniture.Config = Config

function DecorFurniture.GetConfig(itemName: string): DecorFurnitureConfig
    return DecorFurniture.Config[itemName]
end

function DecorFurniture.GetModel(itemName: string): Model
    return modelFolder:FindFirstChild(itemName):Clone()
end

return DecorFurniture