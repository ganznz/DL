local Bed = {}

type BedConfig = {
    EnergyPerSec: number
}

local Config: { [string]: BedConfig } = {
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

Bed.Config = Config

return Bed