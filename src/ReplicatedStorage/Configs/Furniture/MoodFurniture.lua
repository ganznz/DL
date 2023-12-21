local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modelFolder = ReplicatedStorage.Assets.Models.Studio.StudioFurnishing.Mood

local MoodFurniture = {}

type MoodFurnitureConfig = {
    Price: number;
    Currency: string,
    Image: string,
    Stats: {}
}

MoodFurniture.CategoryImage = "15695821832"

local Config: { [string]: MoodFurnitureConfig } = {
    ["Arcade Machine"] = {
        Price = 99,
        Currency = "Coins",
        Image = "",
        Stats = {
            Base = 1 -- base item stat boost (+1 mood/sec)
        }
    },
    ["TV"] = {
        Price = 99,
        Currency = "Coins",
        Image = "",
        Stats = {
            Base = 2
        }
    },
    Modern = {
        Price = 99,
        Currency = "Coins",
        Image = "",
        Stats = {
            Base = 3
        }
    },
    Rustic = {
        Price = 99,
        Currency = "Coins",
        Image = "",
        Stats = {
            Base = 5
        }
    },
    Fancy = {
        Price = 99,
        Currency = "Coins",
        Image = "",
        Stats = {
            Base = 7
        }
    },
    Futuristic = {
        Price = 99,
        Currency = "Coins",
        Image = "",
        Stats = {
            Base = 9
        }
    },
    Greek = {
        Price = 99,
        Currency = "Coins",
        Image = "",
        Stats = {
            Base = 12
        }
    },
    Steampunk = {
        Price = 99,
        Currency = "Coins",
        Image = "",
        Stats = {
            Base = 15
        }
    },
    Tropical = {
        Price = 99,
        Currency = "Coins",
        Image = "",
        Stats = {
            Base = 18
        }
    },
    Space = {
        Price = 99,
        Currency = "Coins",
        Image = "",
        Stats = {
            Base = 22
        }
    },
    Retro = {
        Price = 99,
        Currency = "Coins",
        Image = "",
        Stats = {
            Base = 26
        }
    },
    Rgb = {
        Price = 99,
        Currency = "Coins",
        Image = "",
        Stats = {
            Base = 30
        }
    },
    Prehistoric = {
        Price = 99,
        Currency = "Coins",
        Image = "",
        Stats = {
            Base = 35
        }
    },
    Crystal = {
        Price = 99,
        Currency = "Coins",
        Image = "",
        Stats = {
            Base = 40
        }
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