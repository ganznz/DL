local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LaptopConfig = require(ReplicatedStorage.Configs.GameDev.Laptop)

local Player = {}

export type LevelUpInformation = {
    Rewards: {
        Currencies: {
            Coins: number?,
            Gems: number?,
        }?,
        UnlockedFeatures: {
            -- e.g. ["GameDev"] = { Description = "Balancing Phase" }
            --      ["Laptop"] = { Description = "Laptop 1" }
            --      ["QuestLine"] = { Description = "Cafe Questline" }
            [string]: { Description: string, Icon: string, IconDropshadow: string }
        }?,
        OtherRewards: {
            -- e.g. ["NeedsPotion"] = { Type = "Potion", Amount = 1 }
            -- e.g. ["Pizza"] = { Type = "Staff Food", Amount = 4 }
            [string]: { Type: string, Amount: number }
        }
    }
}

local lvlUpInfo: { [string]: LevelUpInformation } = {
    ["2"] = {
        Rewards = {
            Currencies = {
                Gems = 5,
            },
            UnlockedFeatures = {
                Laptop = {
                    Description = LaptopConfig.GetConfig("1").Name,
                    Icon = LaptopConfig.GetConfig("1").IconStroke,
                    IconDropshadow = LaptopConfig.GetConfig("1").IconFill
                }
            }
        }
    },
    ["3"] = {
        Rewards = {
            Currencies = {
                Gems = 10,
            },
            UnlockedFeatures = {
                GameDev = {
                    Description = "Balancing Phase",
                    Icon = "",
                    IconDropshadow = ""
                },
                -- potentially make first questline available for unlocking staff food
                QuestLine = {
                    Description = "Questline",
                    Icon = "",
                    IconDropshadow = ""
                },
            }
        }
    },
    ["4"] = {
        Rewards = {
            Currencies = {
                Gems = 10,
            },
            OtherRewards = {
                Coffee = { Type = "Staff Food", Amount = 5 },
                Pizza = { Type = "Staff Food", Amount = 5 },
            }
        }
    },
    ["5"] = {
        Rewards = {
            Currencies = {
                Gems = 20,
            }
        }
    }
}

Player.LevelUpInformation = lvlUpInfo

Player.XpPerLevel = 100

function Player.CalcMaxNeed(plrData): number
    return 10 * math.pow(2, plrData.Character.Level - 1)
end

function Player.CalcLevelUpXpRequirement(plrData): number
    local plrLevel = plrData.Character.Level

    return 10 * math.pow(1.35, plrLevel + 1)
end


return Player