local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GeneralUtils = require(ReplicatedStorage.Utils.GeneralUtils)

local Computer = {}

export type ComputerUpgradeConfig = {
    Stat: "coins" | "code" | "sound" | "art",
    StatIncrease: number, -- e.g. 0.2 (+20% for respective stat)
    GoalValue: number, -- the value the player needs to reach to complete the upgrade
    Description: string,
}

export type ComputerConfig = {
    Name: string,
    IconOriginal: string,
    IconStroke: string,
    IconFill: string,
    Materials: { [string]: number }, -- materials required for next computer upgrade
    Upgrades: {
        [string]: ComputerUpgradeConfig
    }
}

local Config: { [number]: ComputerConfig } = {
    [1] = {
        Name = "Computer 1",
        IconOriginal = "15979407007",
        IconStroke = "15979408683",
        IconFill = "15979409741",
        Materials = {
            ["Metal Scrap"] = 20,
            ["Wire"] = 20,
            ["Glass"] = 5,
        },
        Upgrades = {
            ["Code I"] = {
                Stat = "code",
                StatIncrease = 0.1,
                GoalValue = 99,
                Description = "Put a total of 99 Code Points into developing games"
            },
            ["Sound I"] = {
                Stat = "sound",
                StatIncrease = 0.1,
                GoalValue = 99,
                Description = "Put a total of 99 Sound Points into developing games"
            },
            ["Art I"] = {
                Stat = "art",
                StatIncrease = 0.1,
                GoalValue = 99,
                Description = "Put a total of 99 Art Points into developing games"
            },
            ["Coins I"] = {
                Stat = "coins",
                StatIncrease = 0.1,
                GoalValue = 499,
                Description = "Earn a total of 499 Coins from developing games"
            },
        }
    },
    [2] = {
        Name = "Computer 2",
        IconOriginal = "",
        IconStroke = "",
        IconFill = "",
        Materials = {
            ["Glass"] = 20,
            ["Circuit Board"] = 20,
            ["Fan"] = 5,
        },
        Upgrades = {
            ["Code II"] = {
                Stat = "code",
                StatIncrease = 0.1,
                GoalValue = 999,
                Description = "Put a total of 999 Code Points into developing games"
            },
            ["Sound II"] = {
                Stat = "sound",
                StatIncrease = 0.1,
                GoalValue = 999,
                Description = "Put a total of 999 Sound Points into developing games"
            },
            ["Art II"] = {
                Stat = "art",
                StatIncrease = 0.1,
                GoalValue = 999,
                Description = "Put a total of 999 Art Points into developing games"
            },
            ["Coins II"] = {
                Stat = "coins",
                StatIncrease = 0.1,
                GoalValue = 7499,
                Description = "Earn a total of 7499 Coins from developing games"
            },
        }
    },
    [3] = {
        Name = "Computer 3",
        IconOriginal = "",
        IconStroke = "",
        IconFill = "",
        Materials = {
            ["Metal Scrap"] = 20,
            ["Wire"] = 20,
            ["Glass"] = 5,
        },
        Upgrades = {
            ["Code III"] = {
                Stat = "code",
                StatIncrease = 0.15,
                GoalValue = 4999,
                Description = "Put a total of 4999 Code Points into developing games"
            },
            ["Sound III"] = {
                Stat = "sound",
                StatIncrease = 0.15,
                GoalValue = 4999,
                Description = "Put a total of 4999 Sound Points into developing games"
            },
            ["Art III"] = {
                Stat = "art",
                StatIncrease = 0.15,
                GoalValue = 4999,
                Description = "Put a total of 4999 Art Points into developing games"
            },
            ["Coins III"] = {
                Stat = "coins",
                StatIncrease = 0.15,
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

function Computer.GetConfig(ComputerLevel: number): ComputerConfig
    return Computer.Config[ComputerLevel]
end

function Computer.GetUpgradeConfig(computerLevel: number, upgradeName: string): ComputerUpgradeConfig
    local computerConfig = Computer.GetConfig(computerLevel)
    if not computerConfig then return end

    local upgradeConfig = computerConfig.Upgrades[upgradeName]
    return upgradeConfig
end

function Computer.GetComputerModel(computerLevel: number): Model
    local computerModelsFolder: Folder = ReplicatedStorage.Assets.Models.Studio.Computers
    local computerModel: Model = computerModelsFolder:FindFirstChild(computerLevel):Clone()

    return computerModel
end

function Computer.GetItemPrice(itemIndex: number): number
    return Computer.GetConfig(itemIndex).Price
end

function Computer.HasLastComputer(plrData): boolean
    print(plrData.GameDev.Computer.Level == GeneralUtils.LengthOfDict(Computer.Config))
    return plrData.GameDev.Computer.Level == GeneralUtils.LengthOfDict(Computer.Config)
end

function Computer.AllAvailableComputerUpgradesCompleted(plrData): boolean
    local plrComputerLevel: number = plrData.GameDev.Computer.Level

    for _upgradeName: string, upgradeProgressData: {} in plrData.GameDev.Computer.UpgradeProgress[plrComputerLevel] do
        if upgradeProgressData.Progress < upgradeProgressData.Goal then return false end
    end

    return true
end

-- returns the buffs earned from computer upgrades
function Computer.GetComputerBuffs(plrData): {}
    local plrComputerLevel = plrData.GameDev.Computer.Level

    -- buffs are represented in decimal (e.g. 0.2 -> 20%)
    local coinsBuff: number = 0
    local codePtsBuff: number = 0
    local soundPtsBuff: number = 0
    local artPtsBuff: number = 0

    for i = 1, plrComputerLevel, 1 do
        local computerUpgradeInfo = plrData.GameDev.Computer.UpgradeProgress[i]
        for upgradeName, upgradeData in computerUpgradeInfo do
            if upgradeData.Progress < upgradeData.Goal then continue end
            
            local upgradeConfig = Computer.Config[i].Upgrades[upgradeName]
            if upgradeConfig.Stat == "coins" then
                coinsBuff += upgradeConfig.StatIncrease
            elseif upgradeConfig.Stat == "code" then
                codePtsBuff += upgradeConfig.StatIncrease
            elseif upgradeConfig.Stat == "sound" then
                soundPtsBuff += upgradeConfig.StatIncrease
            elseif upgradeConfig.Stat == "art" then
                artPtsBuff += upgradeConfig.StatIncrease
            end
        end
    end

    return {
        CoinsBuff = coinsBuff,
        CodePtsBuff = codePtsBuff,
        SoundPtsBuff = soundPtsBuff,
        ArtPtsBuff = artPtsBuff,
    }
end

return Computer