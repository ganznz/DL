local Phones = {}

export type PhoneConfig = {
    Price: number,
    Currency: string,
    Unlockables: {
        Materials: {
            [string]: { -- consumable name
                Chance: number
            }
        }?,
        Consumables: {
            [string]: { -- consumable name
                Chance: number
            }
        }?,
        Staff: {
            [string]: { -- staff name
                Chance: number -- e.g. 50 (50% hatch rate)
            }
        }?
    }
}

local config: { [string]: PhoneConfig } = {
    ["Basic"] = {
        Price = 1000,
        Currency = "Coins",
        Unlockables = {
            Materials = {
                -- 20% total
                ["Metal Scrap"] = { Chance = 10 },
                ["Wire"] = { Chance = 10 },
            },
            Consumables = {
                -- 30% total
                ["Coffee"] = { Chance = 15 },
                ["Pizza"] = { Chance = 15 },
            },
            Staff = {
                -- 50% total
                ["Max"] = { Chance = 15 },
                ["Cam"] = { Chance = 15 },
                ["Sophie"] = { Chance = 15 },
                ["Logan"] = { Chance = 5 }
            }
        }
    },
}

Phones.Config = config

function Phones.GetConfig(phoneName: string): PhoneConfig | nil
    return Phones.Config[phoneName]
end

function Phones.GetTotalItemChance(phoneName: string, unlockableType: "Staff" | "Consumables" | "Materials"): number
    local totalChance = 0

    local phoneConfig = Phones.GetConfig(phoneName)
    if not phoneConfig then return totalChance end

    for _unlockableItemName, unlockableItemInfo in phoneConfig.Unlockables[unlockableType] do
        totalChance += unlockableItemInfo.Chance
    end
    
    return totalChance
end

return Phones