local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local GeneralUtils = require(ReplicatedStorage.Utils:WaitForChild("GeneralUtils"))

local Computer = {}

type ComputerUpgradeConfig = {
    Stat: "design" | "graphics" | "sound" | "coins",
    StatIncrease: number, -- e.g. 20 (+20% for respective stat)
    GoalValue: number, -- the value the player needs to reach to complete the upgrade
    Description: string,
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
            ["Code I"] = {
                Stat = "code",
                StatIncrease = 10,
                GoalValue = 99,
                Description = "Put a total of 99 Code Points into developing games"
            },
            ["Sound I"] = {
                Stat = "sound",
                StatIncrease = 10,
                GoalValue = 99,
                Description = "Put a total of 99 Sound Points into developing games"
            },
            ["Art I"] = {
                Stat = "art",
                StatIncrease = 10,
                GoalValue = 99,
                Description = "Put a total of 99 Art Points into developing games"
            },
            ["Coins I"] = {
                Stat = "coins",
                StatIncrease = 10,
                GoalValue = 499,
                Description = "Earn a total of 499 Coins from developing games"
            },
        }
    },
    [2] = {
        Name = "Computer 2",
        Upgrades = {
            ["Code II"] = {
                Stat = "code",
                StatIncrease = 10,
                GoalValue = 999,
                Description = "Put a total of 999 Code Points into developing games"
            },
            ["Sound II"] = {
                Stat = "sound",
                StatIncrease = 10,
                GoalValue = 999,
                Description = "Put a total of 999 Sound Points into developing games"
            },
            ["Art II"] = {
                Stat = "art",
                StatIncrease = 10,
                GoalValue = 999,
                Description = "Put a total of 999 Art Points into developing games"
            },
            ["Coins II"] = {
                Stat = "coins",
                StatIncrease = 10,
                GoalValue = 7499,
                Description = "Earn a total of 7499 Coins from developing games"
            },
        }
    },
    [3] = {
        Name = "Computer 3",
        Upgrades = {
            ["Code III"] = {
                Stat = "code",
                StatIncrease = 15,
                GoalValue = 4999,
                Description = "Put a total of 4999 Code Points into developing games"
            },
            ["Sound III"] = {
                Stat = "sound",
                StatIncrease = 15,
                GoalValue = 4999,
                Description = "Put a total of 4999 Sound Points into developing games"
            },
            ["Art III"] = {
                Stat = "art",
                StatIncrease = 15,
                GoalValue = 4999,
                Description = "Put a total of 4999 Art Points into developing games"
            },
            ["Coins III"] = {
                Stat = "coins",
                StatIncrease = 15,
                GoalValue = 49999,
                Description = "Earn a total of 49,999 Coins from developing games"
            },
        }
    },
}

Computer.Config = Config

Computer.Constants = {
    NeedReqToMakeGame = 0.3 -- (30% of max need)
}

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
    return plrData.GameDev.Computer.Level == GeneralUtils.LengthOfDict(Computer.Config)
end

function Computer.CanUpgrade(plrData): boolean
    local currentComputerLevel = plrData.GameDev.Computer.Level
    if Computer.HasLastItem(plrData) then return false end

    local nextComputerConfig = Computer.GetConfig(currentComputerLevel + 1)
    local plrCoins = plrData.Coins
    return plrCoins >= nextComputerConfig.Price
end

return Computer