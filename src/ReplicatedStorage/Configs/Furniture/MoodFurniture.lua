local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modelFolder = ReplicatedStorage.Assets.Models.StudioFurnishing.Mood

local MoodFurniture = {}

type MoodFurnitureConfig = {
    MoodPerSec: number
}

local Config: { [string]: MoodFurnitureConfig } = {
    ["Arcade Machine"] = {
        MoodPerSec = 1
    },
    ["TV"] = {
        MoodPerSec = 2
    },
    Modern = {
        MoodPerSec = 3
    },
    Rustic = {
        MoodPerSec = 5
    },
    Fancy = {
        MoodPerSec = 7
    },
    Futuristic = {
        MoodPerSec = 9
    },
    Greek = {
        MoodPerSec = 12
    },
    Steampunk = {
        MoodPerSec = 15
    },
    Tropical = {
        MoodPerSec = 18
    },
    Space = {
        MoodPerSec = 22
    },
    Retro = {
        MoodPerSec = 26
    },
    Rgb = {
        MoodPerSec = 30
    },
    Prehistoric = {
        MoodPerSec = 35
    },
    Crystal = {
        MoodPerSec = 40
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