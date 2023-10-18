local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GenreConfig = require(ReplicatedStorage.Configs:WaitForChild("Genre"))
local TopicConfig = require(ReplicatedStorage.Configs:WaitForChild("Topic"))
local CashierConfig = require(ReplicatedStorage.Configs.Jobs:WaitForChild("Cashier"))
local ComputerConfig = require(ReplicatedStorage.Configs.Jobs:WaitForChild("Cashier"))


-- Template is what empty profiles default to
local Template = {
    Cash = 0,
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
        Computer = 1, -- computer level
        Router = 1, -- router level
        Sizes = {
            Small = true;
        },
        Genres = {
            Action = GenreConfig.new('Action'),
            Casual = GenreConfig.new('Casual'),
            Strategy = GenreConfig.new('Strategy'),
        },
        Topics = {
            Modern = TopicConfig.new("Modern"),
            Medieval = TopicConfig.new("Medieval"),
            SciFi = TopicConfig.new("SciFi"),
        }
    },
    Jobs = {
        Cashier = {
            CashierInstance = CashierConfig.new(),
            ShiftCooldown = os.time()
        }
        -- add other jobs
    },
    Inventory = {
        StudioFurnishing = {
            -- character need name = { items that fulfill the need }
            Happiness = {},
            Energy = {},
            Hunger = {},
            Decor = {}
        }
    },
    Studio = {
        -- the studio that the player is currently using
        ActiveStudio = 1,

        -- the tables in this Studios table holds info for the players unlocked studio, in order of unlockable studios in-game
        Studios = {
            {
                Furnishings = {
                    -- contain information for placed items in this studio
                },
            },
        }
    }
}

export type PlayerData = typeof(Template)

return Template
