local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modelFolder = ReplicatedStorage.Assets.Models.StudioFurnishing.Energy

local EnergyFurniture = {}

type EnergyFurnitureConfig = {
    EnergyPerSec: number
}

local Config: { [string]: EnergyFurnitureConfig } = {
    Default = {
        EnergyPerSec = 1
    },
    Basic = {
        EnergyPerSec = 2
    },
    Modern = {
        EnergyPerSec = 3
    },
    Rustic = {
        EnergyPerSec = 5
    },
    Fancy = {
        EnergyPerSec = 7
    },
    Futuristic = {
        EnergyPerSec = 9
    },
    Greek = {
        EnergyPerSec = 12
    },
    Steampunk = {
        EnergyPerSec = 15
    },
    Tropical = {
        EnergyPerSec = 18
    },
    Space = {
        EnergyPerSec = 22
    },
    Retro = {
        EnergyPerSec = 26
    },
    Rgb = {
        EnergyPerSec = 30
    },
    Prehistoric = {
        EnergyPerSec = 35
    },
    Crystal = {
        EnergyPerSec = 40
    },
}

EnergyFurniture.Config = Config

function EnergyFurniture.GetConfig(itemName: string): EnergyFurnitureConfig
    return EnergyFurniture.Config[itemName]
end

function EnergyFurniture.GetModel(itemName: string): Model
    return modelFolder:FindFirstChild(itemName):Clone()
end

return EnergyFurniture