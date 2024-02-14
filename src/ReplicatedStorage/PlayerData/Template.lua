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
            CurrentEnergy = 10,
            CurrentHunger = 10,
            CurrentMood = 10
        },
    },

    Skills = {
        Creativity = 10,
        Logic = 10,
        Focus = 10,
    },

    GameDev = {
        HighestGameDevPhase = 1,
        Computer = {
            Level = 1
        },
        -- table that holds data of developed games (e.g. game name, ratings, topic & genre, was marketed or not, etc)
        -- e.g. { [1]={gameData}, [2]={gameData}, [3]={gameData}, ... }
        DevelopedGames = {},
        Genres = {
            -- GenreName = { Level: number, XP: number, CompatibleWith: string, IncompatibleWith: string }
            Action = { Level = 1, XP = 0, CompatibleWith = "", IncompatibleWith = "" },
            Strategy = { Level = 1, XP = 0, CompatibleWith = "", IncompatibleWith = "" },
            Casual = { Level = 1, XP = 0, CompatibleWith = "", IncompatibleWith = "" },
        },
        Topics = {
            -- TopicName = { Level: number, XP: number, CompatibleWith: string, IncompatibleWith: string }
            Medieval = { Level = 1, XP = 0, CompatibleWith = "", IncompatibleWith = "" },
            Zombies = { Level = 1, XP = 0, CompatibleWith = "", IncompatibleWith = "" },
            Fantasy = { Level = 1, XP = 0, CompatibleWith = "", IncompatibleWith = "" },
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

    -- holds 'statistical' game data (e.g. total staff upgrades, currency spent, total playtime, etc)
    Statistics = {
        RobuxSpent = 0,
        CoinsSpent = 0,
        GemsSpent = 0,
        TotalPlaytime = 0,
        StaffUpgradesDone = 0,
    },

    -- all areas which are unlockable through playing the game
    -- boolean in key-pair value indicates whether plr has area unlocked or not
    Areas = DEFAULT_UNLOCKABLE_AREAS
}

export type PlayerData = typeof(Template)

return Template
