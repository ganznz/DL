local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modelFolder = ReplicatedStorage.Assets.Models.Studio.StudioFurnishing.Hunger

local HungerFurniture = {}

type HungerFurnitureConfig = {
    Price: number;
    Currency: string,
    IconOriginal: string,
    IconStroke: string,
    Stats: {}
}

HungerFurniture.CategoryImage = "15695739111"

local Config: { [string]: HungerFurnitureConfig } = {
    Default = {
        Price = 99,
        Currency = "Coins",
        IconOriginal = "",
        IconStroke = "",
        Stats = {
            Base = 1 -- base item stat boost (+1 hunger/sec)
        }
    },
    Basic = {
        Price = 99,
        Currency = "Coins",
        IconOriginal = "",
        IconStroke = "",
        Stats = {
            Base = 2
        }
    },
    Modern = {
        Price = 99,
        Currency = "Coins",
        IconOriginal = "",
        IconStroke = "",
        Stats = {
            Base = 3
        }
    },
    Rustic = {
        Price = 99,
        Currency = "Coins",
        IconOriginal = "",
        IconStroke = "",
        Stats = {
            Base = 5
        }
    },
    Fancy = {
        Price = 99,
        Currency = "Coins",
        IconOriginal = "",
        IconStroke = "",
        Stats = {
            Base = 7
        }
    },
    Futuristic = {
        Price = 99,
        Currency = "Coins",
        IconOriginal = "",
        IconStroke = "",
        Stats = {
            Base = 9
        }
    },
    Greek = {
        Price = 99,
        Currency = "Coins",
        IconOriginal = "",
        IconStroke = "",
        Stats = {
            Base = 12
        }
    },
    Steampunk = {
        Price = 99,
        Currency = "Coins",
        IconOriginal = "",
        IconStroke = "",
        Stats = {
            Base = 15
        }
    },
    Tropical = {
        Price = 99,
        Currency = "Coins",
        IconOriginal = "",
        IconStroke = "",
        Stats = {
            Base = 18
        }
    },
    Space = {
        Price = 99,
        Currency = "Coins",
        IconOriginal = "",
        IconStroke = "",
        Stats = {
            Base = 22
        }
    },
    Retro = {
        Price = 99,
        Currency = "Coins",
        IconOriginal = "",
        IconStroke = "",
        Stats = {
            Base = 26
        }
    },
    Rgb = {
        Price = 99,
        Currency = "Coins",
        IconOriginal = "",
        IconStroke = "",
        Stats = {
            Base = 30
        }
    },
    Prehistoric = {
        Price = 99,
        Currency = "Coins",
        IconOriginal = "",
        IconStroke = "",
        Stats = {
            Base = 35
        }
    },
    Crystal = {
        Price = 99,
        Currency = "Coins",
        IconOriginal = "",
        IconStroke = "",
        Stats = {
            Base = 40
        }
    },
}

HungerFurniture.Config = Config

function HungerFurniture.GetAllFurnitureNames(): {}
    local allFurnitureNames = {}
    for itemName, _itemInfo in HungerFurniture.Config do table.insert(allFurnitureNames, itemName) end

    return allFurnitureNames
end

function HungerFurniture.GetConfig(itemName: string): HungerFurnitureConfig
    return HungerFurniture.Config[itemName]
end

function HungerFurniture.GetModel(itemName: string): Model
    return modelFolder:FindFirstChild(itemName):Clone()
end

return HungerFurniture