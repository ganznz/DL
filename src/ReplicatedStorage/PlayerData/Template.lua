local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TeleportAreas = require(ReplicatedStorage.Configs:WaitForChild("TeleportAreas"))
local GenreConfig = require(ReplicatedStorage.Configs.GameDev:WaitForChild("Genre"))
local TopicConfig = require(ReplicatedStorage.Configs.GameDev:WaitForChild("Topic"))
local StaffFoodConfig = require(ReplicatedStorage.Configs.Staff:WaitForChild("StaffFood"))
local MaterialsConfig = require(ReplicatedStorage.Configs.Materials:WaitForChild("Materials"))

local DEFAULT_UNLOCKABLE_AREAS = {}
for _i, area in TeleportAreas.UnlockableAreas do
    DEFAULT_UNLOCKABLE_AREAS[area] = false
end

local ALL_STAFF_FOOD = {}
for foodName, _foodInfo in StaffFoodConfig.Config do
    ALL_STAFF_FOOD[foodName] = { Amount = 0 }
end

local ALL_MATERIALS = {}
for materialName, _materialInfo in MaterialsConfig.Config do
    ALL_MATERIALS[materialName] = { Amount = 0 }
end

-- Template is what empty profiles default to
local Template = {
    Admin = false, -- for admin cmd access
    Coins = 0,
    Gems = 0,
    Fans = 0,

    Character = {
        Level = 1,
        Exp = 0,
        Needs = {
            Energy = 10,
            MaxEnergy = 10,
            Hunger = 10,
            MaxHunger = 10,
        },
    },

    Skills = {
        Creativity = 10,
        Logic = 10,
        Focus = 10,
    },

    GameDev = {
        Computer = {
            Level = 1
        },
        Sizes = {
            Small = true;
        },
        Genres = {
            -- GenreName = { Level: number | nil, XP: number | nil, CompatibleWith: string | nil, IncompatibleWith: string | nil }
            Action = { Level = nil, XP = nil, CompatibleWith = nil, IncompatibleWith = nil },
            Strategy = { Level = nil, XP = nil, CompatibleWith = nil, IncompatibleWith = nil },
            Casual = { Level = nil, XP = nil, CompatibleWith = nil, IncompatibleWith = nil },
        },
        Topics = {
            -- TopicName = { Level: number | nil, XP: number | nil, CompatibleWith: string | nil, IncompatibleWith: string | nil }
            Medieval = { Level = nil, XP = nil, CompatibleWith = nil, IncompatibleWith = nil },
            Zombies = { Level = nil, XP = nil, CompatibleWith = nil, IncompatibleWith = nil },
            Fantasy = { Level = nil, XP = nil, CompatibleWith = nil, IncompatibleWith = nil },
        }
    },

    Inventory = {
        StudioFurnishing = {
            -- e.g.
            -- Mood = { Basic = { UUID1 = {} } }
            Mood = {},
            Energy = {},
            Hunger = {},
            Decor = {},
            Special = {}
        },
        StaffMembers = {},
        StaffFood = ALL_STAFF_FOOD,
        Materials = ALL_MATERIALS,
    },

    Studio = {
        -- index of studio that the player is currently using
        ActiveStudio = "1", -- by default is "1"
        StudioStatus = "open", -- "open" | "closed"| "friends"
        StaffMemberCapacity = 3,

        Studios = {
            Standard = {},

            -- Gamepass studios
            Premium = {}
        }
    },

    -- all areas which are unlockable through playing the game
    -- boolean in key-pair value indicates whether plr has area unlocked or not
    Areas = DEFAULT_UNLOCKABLE_AREAS
}

export type PlayerData = typeof(Template)

return Template
