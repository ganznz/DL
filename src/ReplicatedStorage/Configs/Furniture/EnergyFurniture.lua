local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modelFolder = ReplicatedStorage.Assets.Models.Studio.StudioFurnishing.Energy

local EnergyFurniture = {}

type EnergyFurnitureConfig = {
    Price: number;
    Currency: string,
    Image: string,
    Stats: {}
}

local Config: { [string]: EnergyFurnitureConfig } = {
    Default = {
        Price = 99,
        Currency = "Cash",
        Image = "",
        Stats = {
            Base = 1 -- base item stat boost (+1 energy/sec)
        }
    },
    Basic = {
        Price = 99,
        Currency = "Cash",
        Image = "",
        Stats = {
            Base = 2
        }
    },
    Modern = {
        Price = 99,
        Currency = "Cash",
        Image = "",
        Stats = {
            Base = 3
        }
    },
    Rustic = {
        Price = 99,
        Currency = "Cash",
        Image = "",
        Stats = {
            Base = 5
        }
    },
    Fancy = {
        Price = 99,
        Currency = "Cash",
        Image = "",
        Stats = {
            Base = 7
        }
    },
    Futuristic = {
        Price = 99,
        Currency = "Cash",
        Image = "",
        Stats = {
            Base = 9
        }
    },
    Greek = {
        Price = 99,
        Currency = "Cash",
        Image = "",
        Stats = {
            Base = 12
        }
    },
    Steampunk = {
        Price = 99,
        Currency = "Cash",
        Image = "",
        Stats = {
            Base = 15
        }
    },
    Tropical = {
        Price = 99,
        Currency = "Cash",
        Image = "",
        Stats = {
            Base = 18
        }
    },
    Space = {
        Price = 99,
        Currency = "Cash",
        Image = "",
        Stats = {
            Base = 22
        }
    },
    Retro = {
        Price = 99,
        Currency = "Cash",
        Image = "",
        Stats = {
            Base = 26
        }
    },
    Rgb = {
        Price = 99,
        Currency = "Cash",
        Image = "",
        Stats = {
            Base = 30
        }
    },
    Prehistoric = {
        Price = 99,
        Currency = "Cash",
        Image = "",
        Stats = {
            Base = 35
        }
    },
    Crystal = {
        Price = 99,
        Currency = "Cash",
        Image = "",
        Stats = {
            Base = 40
        }
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