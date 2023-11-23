local ReplicatedFirst = game:GetService("ReplicatedFirst")

local Computer = {}

type ComputerUpgradeConfig = {
    StatIncrease: "design" | "graphics" | "sound" | "cash",
    StatIncreaseAmt: number -- e.g. 20 (+20% for respective stat)
}

export type ComputerConfig = {
    Name: string,
    Upgrades: {
        [string]: ComputerUpgradeConfig
    }
}

local Config: { [number]: ComputerConfig } = {
    [1] = {
        Name = "Computer 1",
        Upgrades = {
            ["Design I"] = { StatIncrease = "design", StatIncreaseAmt = 10 },
            ["Graphics I"] = { StatIncrease = "graphics", StatIncreaseAmt = 10 },
            ["Sound I"] = { StatIncrease = "sound", StatIncreaseAmt = 10 },
            ["Cash I"] = { StatIncrease = "cash", StatIncreaseAmt = 10 },
        }
    },
    [2] = {
        Name = "Computer 2",
        Upgrades = {
            ["Design II"] = { StatIncrease = "design", StatIncreaseAmt = 15 },
            ["Graphics II"] = { StatIncrease = "graphics", StatIncreaseAmt = 15 },
            ["Sound II"] = { StatIncrease = "sound", StatIncreaseAmt = 15 },
            ["Cash II"] = { StatIncrease = "cash", StatIncreaseAmt = 10 },
        }
    },
    [3] = {
        Name = "Computer 3",
        Upgrades = {
            ["Design III"] = { StatIncrease = "design", StatIncreaseAmt = 15 },
            ["Graphics III"] = { StatIncrease = "graphics", StatIncreaseAmt = 15 },
            ["Sound III"] = { StatIncrease = "sound", StatIncreaseAmt = 15 },
            ["Cash III"] = { StatIncrease = "cash", StatIncreaseAmt = 10 },
        }
    },
}

Computer.Config = Config

function Computer.GetConfig(itemIndex: number): ComputerConfig
    return Computer.Config[itemIndex]
end

function Computer.GetItemPrice(itemIndex: number): number
    return Computer.GetConfig(itemIndex).Price
end

function Computer.GetModel(itemIndex: number): Model | nil
    local computersFolder = ReplicatedFirst.Assets.Models.Computers
    local model = computersFolder:FindFirstChild(tostring(itemIndex)):Clone()
    return model
end

function Computer.HasLastItem(plrData): boolean
    return plrData.GameDev.Computer == #(Computer.Config)
end

function Computer.CanUpgrade(plrData): boolean
    local currentComputerLevel = plrData.GameDev.Computer
    if Computer.HasLastItem(plrData) then return false end

    local nextComputerConfig = Computer.GetConfig(currentComputerLevel + 1)
    local plrCash = plrData.Cash
    return plrCash >= nextComputerConfig.Price
end

return Computer