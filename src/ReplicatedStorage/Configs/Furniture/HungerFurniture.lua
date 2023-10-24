local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modelFolder = ReplicatedStorage.Assets.Models.StudioFurnishing.Hunger

local HungerFurniture = {}

type HungerFurnitureConfig = {
    HungerPerSec: number;
    Price: number;
    ImageUrl: string -- model render image (ADD TO CONFIG BELOW)
}

local Config: { [string]: HungerFurnitureConfig } = {
    Default = {
        HungerPerSec = 1
    },
    Basic = {
        HungerPerSec = 2
    },
    Modern = {
        HungerPerSec = 3
    },
    Rustic = {
        HungerPerSec = 5
    },
    Fancy = {
        HungerPerSec = 7
    },
    Futuristic = {
        HungerPerSec = 9
    },
    Greek = {
        HungerPerSec = 12
    },
    Steampunk = {
        HungerPerSec = 15
    },
    Tropical = {
        HungerPerSec = 18
    },
    Space = {
        HungerPerSec = 22
    },
    Retro = {
        HungerPerSec = 26
    },
    Rgb = {
        HungerPerSec = 30
    },
    Prehistoric = {
        HungerPerSec = 35
    },
    Crystal = {
        HungerPerSec = 40
    },
}

HungerFurniture.Config = Config

function HungerFurniture.GetConfig(itemName: string): HungerFurnitureConfig
    return HungerFurniture.Config[itemName]
end

function HungerFurniture.GetModel(itemName: string): Model
    return modelFolder:FindFirstChild(itemName):Clone()
end

return HungerFurniture