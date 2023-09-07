local Computer = {}

type ComputerConfig = {
    Name: string,
    EnergyCapacity: number
}

local Config: { [number]: ComputerConfig } = {
    [1]  = {
        Name = "Default",
        EnergyCapacity = 5
    },
    [2] = {
        -- add more computer types here
    }
}

Computer.Config = Config

return Computer