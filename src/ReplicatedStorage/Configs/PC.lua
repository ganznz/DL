local Platforms = {}

type PlatformConfig = {
    Name: string,
    EnergyCapacity: number
}

local Config: { [number]: PlatformConfig } = {
    [1]  = {
        Name = "Default",
        EnergyCapacity = 5
    },
    [2] = {
        -- add more PC types here
    }
}

Platforms.Config = Config

return Platforms