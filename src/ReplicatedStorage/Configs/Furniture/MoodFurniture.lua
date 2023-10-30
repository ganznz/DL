local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modelFolder = ReplicatedStorage.Assets.Models.StudioFurnishing.Mood

local MoodFurniture = {}

type MoodFurnitureConfig = {
    MoodPerSec: number,
    Price: number;
    Currency: string,
    ImageUrl: string
}

local Config: { [string]: MoodFurnitureConfig } = {
    ["Arcade Machine"] = {
        MoodPerSec = 1,
        Price = 99,
        Currency = "Cash"
    },
    ["TV"] = {
        MoodPerSec = 2,
        Price = 99,
        Currency = "Cash"
    },
    Modern = {
        MoodPerSec = 3,
        Price = 99,
        Currency = "Cash"
    },
    Rustic = {
        MoodPerSec = 5,
        Price = 99,
        Currency = "Cash"
    },
    Fancy = {
        MoodPerSec = 7,
        Price = 99,
        Currency = "Cash"
    },
    Futuristic = {
        MoodPerSec = 9,
        Price = 99,
        Currency = "Cash"
    },
    Greek = {
        MoodPerSec = 12,
        Price = 99,
        Currency = "Cash"
    },
    Steampunk = {
        MoodPerSec = 15,
        Price = 99,
        Currency = "Cash"
    },
    Tropical = {
        MoodPerSec = 18,
        Price = 99,
        Currency = "Cash"
    },
    Space = {
        MoodPerSec = 22,
        Price = 99,
        Currency = "Cash"
    },
    Retro = {
        MoodPerSec = 26,
        Price = 99,
        Currency = "Cash"
    },
    Rgb = {
        MoodPerSec = 30,
        Price = 99,
        Currency = "Cash"
    },
    Prehistoric = {
        MoodPerSec = 35,
        Price = 99,
        Currency = "Cash"
    },
    Crystal = {
        MoodPerSec = 40,
        Price = 99,
        Currency = "Cash"
    },
}

MoodFurniture.Config = Config

function MoodFurniture.GetConfig(itemName: string): MoodFurnitureConfig
    return MoodFurniture.Config[itemName]
end

function MoodFurniture.GetModel(itemName: string): Model
    return modelFolder:FindFirstChild(itemName):Clone()
end

return MoodFurniture