local ReplicatedFirst = game:GetService("ReplicatedFirst")

local Computer = {}

export type ComputerConfig = {
    Name: string,
    AddOns: number,
    Price: number,
}

local Config: { [number]: ComputerConfig } = {
    [1] = {
        Name = "1",
        AddOns = 2,
        Price = 0
    },
    [2]  = {
        Name = "2",
        AddOns = 3,
        Price = 999,
    },
    [3]  = {
        Name = "3",
        AddOns = 4,
        Price = 999,
    },
    [4]  = {
        Name = "4",
        AddOns = 5,
        Price = 999,
    },
    [5]  = {
        Name = "5",
        AddOns = 6,
        Price = 999,
    },
    [6]  = {
        Name = "6",
        AddOns = 7,
        Price = 999,
    },
    [7]  = {
        Name = "7",
        AddOns = 8,
        Price = 999,
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
    -- print(plrCash)
    -- print(nextComputerConfig.Price)
    -- print(plrCash >= nextComputerConfig.Price)
    return plrCash >= nextComputerConfig.Price
end

return Computer