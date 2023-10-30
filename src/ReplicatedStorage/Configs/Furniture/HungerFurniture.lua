local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modelFolder = ReplicatedStorage.Assets.Models.StudioFurnishing.Hunger

local HungerFurniture = {}

type HungerFurnitureConfig = {
    HungerPerSec: number;
    Price: number;
    Currency: string,
    ImageUrl: string
}

local Config: { [string]: HungerFurnitureConfig } = {
    Default = {
        HungerPerSec = 1,
        Price = 99,
        Currency = "Cash"
    },
    Basic = {
        HungerPerSec = 2,
        Price = 99,
        Currency = "Cash"
    },
    Modern = {
        HungerPerSec = 3,
        Price = 99,
        Currency = "Cash"
    },
    Rustic = {
        HungerPerSec = 5,
        Price = 99,
        Currency = "Cash"
    },
    Fancy = {
        HungerPerSec = 7,
        Price = 99,
        Currency = "Cash"
    },
    Futuristic = {
        HungerPerSec = 9,
        Price = 99,
        Currency = "Cash"
    },
    Greek = {
        HungerPerSec = 12,
        Price = 99,
        Currency = "Cash"
    },
    Steampunk = {
        HungerPerSec = 15,
        Price = 99,
        Currency = "Cash"
    },
    Tropical = {
        HungerPerSec = 18,
        Price = 99,
        Currency = "Cash"
    },
    Space = {
        HungerPerSec = 22,
        Price = 99,
        Currency = "Cash"
    },
    Retro = {
        HungerPerSec = 26,
        Price = 99,
        Currency = "Cash"
    },
    Rgb = {
        HungerPerSec = 30,
        Price = 99,
        Currency = "Cash"
    },
    Prehistoric = {
        HungerPerSec = 35,
        Price = 99,
        Currency = "Cash"
    },
    Crystal = {
        HungerPerSec = 40,
        Price = 99,
        Currency = "Cash"
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