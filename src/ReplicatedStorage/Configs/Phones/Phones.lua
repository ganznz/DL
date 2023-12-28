local Phones = {}

export type PhoneConfig = {
    Price: number,
    Currency: string,
    ImageFront: string,
    ImagePerspective: string,
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
        ImageFront = "15775845654",
        ImagePerspective = "15776089669",
        Unlockables = {
            -- Chance has to add to 100 across all items
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

function Phones.GetChanceTable(phoneName: string): {}
    local currentRangeMax = 0

    -- { itemName = { UnlockableType: string, Bounds: {} } }
    local percentages = {}

    local phoneConfig = Phones.GetConfig(phoneName)
    if not phoneConfig then return nil end

    for unlockableType, unlockables in phoneConfig.Unlockables do
        for itemName, itemInfo in unlockables do
            local minBound = currentRangeMax
            currentRangeMax += itemInfo.Chance
            local maxBound = currentRangeMax

            percentages[itemName] = {
                UnlockableType = unlockableType,
                Bounds = {minBound, maxBound}
            }
        end
    end

    return percentages
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