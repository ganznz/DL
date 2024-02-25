local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GeneralUtils = require(ReplicatedStorage.Utils.GeneralUtils)

local Computer = {}

export type LaptopConfig = {
    LaptopType: "Standard" | "Premium",
    Name: string,
    IconOriginal: string,
    IconStroke: string,
    IconFill: string,
    Price: number,
    Currency: "Coins" | "Gems" | "Robux",
    Rewards: { [string]: {  } },
    Previous: "string" | nil
}

local Config: { [number]: LaptopConfig } = {
    ["1"]  = {
        LaptopType = "Standard",
        Name = "Laptop 1",
        IconOriginal = "",
        IconStroke = "",
        IconFill = "",
        Price = 0,
        Currency = "Coins",
    },
    ["2"]  = {
        LaptopType = "Standard",
        Name = "Laptop 2",
        IconOriginal = "",
        IconStroke = "",
        IconFill = "",
        Price = 10000,
        Currency = "Coins",
        Previous = "1"
    },
    ["3"]  = {
        LaptopType = "Standard",
        Name = "Laptop 3",
        IconOriginal = "",
        IconStroke = "",
        IconFill = "",
        Price = 100000,
        Currency = "Coins",
        Previous = "2"
    },
}

local Laptop = {}

Laptop.Config = Config

function Laptop.GetConfig(LaptopIndex: string): LaptopConfig
    return Laptop.Config[LaptopIndex]
end


return Laptop