local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modelFolder = ReplicatedStorage.Assets.Models.StudioFurnishing.Energy

local EnergyFurniture = {}

type EnergyFurnitureConfig = {
    EnergyPerSec: number,
    Price: number;
    Currency: string,
    ImageUrl: string
}

local Config: { [string]: EnergyFurnitureConfig } = {
    Default = {
        EnergyPerSec = 1,
        Price = 99,
        Currency = "Cash"
    },
    Basic = {
        EnergyPerSec = 2,
        Price = 99,
        Currency = "Cash"
    },
    Modern = {
        EnergyPerSec = 3,
        Price = 99,
        Currency = "Cash"
    },
    Rustic = {
        EnergyPerSec = 5,
        Price = 99,
        Currency = "Cash"
    },
    Fancy = {
        EnergyPerSec = 7,
        Price = 99,
        Currency = "Cash"
    },
    Futuristic = {
        EnergyPerSec = 9,
        Price = 99,
        Currency = "Cash"
    },
    Greek = {
        EnergyPerSec = 12,
        Price = 99,
        Currency = "Cash"
    },
    Steampunk = {
        EnergyPerSec = 15,
        Price = 99,
        Currency = "Cash"
    },
    Tropical = {
        EnergyPerSec = 18,
        Price = 99,
        Currency = "Cash"
    },
    Space = {
        EnergyPerSec = 22,
        Price = 99,
        Currency = "Cash"
    },
    Retro = {
        EnergyPerSec = 26,
        Price = 99,
        Currency = "Cash"
    },
    Rgb = {
        EnergyPerSec = 30,
        Price = 99,
        Currency = "Cash"
    },
    Prehistoric = {
        EnergyPerSec = 35,
        Price = 99,
        Currency = "Cash"
    },
    Crystal = {
        EnergyPerSec = 40,
        Price = 99,
        Currency = "Cash"
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