local Fridge = {}

type FridgeConfig = {
    Capacity: number;
    ImageUrl: string -- model render image (ADD TO CONFIG BELOW)
}

local Config: { [string]: FridgeConfig } = {
    Default = {
        Capacity = 3
    },
    Basic = {
        Capacity = 4
    },
    Modern = {
        Capacity = 5
    },
    Rustic = {
        Capacity = 6
    },
    Fancy = {
        Capacity = 7
    },
    Futuristic = {
        Capacity = 8
    },
    Greek = {
        Capacity = 9
    },
    Steampunk = {
        Capacity = 10
    },
    Tropical = {
        Capacity = 11
    },
    Space = {
        Capacity = 12
    },
    Retro = {
        Capacity = 13
    },
    Rgb = {
        Capacity = 14
    },
    Prehistoric = {
        Capacity = 15
    },
    Crystal = {
        Capacity = 16
    },
}

Fridge.Config = Config

return Fridge