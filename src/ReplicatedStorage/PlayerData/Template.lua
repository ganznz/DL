local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GenreConfig = require(ReplicatedStorage.Configs:WaitForChild("Genre"))
local TopicConfig = require(ReplicatedStorage.Configs:WaitForChild("Topic"))

-- Template is what empty profiles default to
local Template = {
    Cash = 0,
    Gems = 0,
    Fans = 0,
    Level = 1,
    Exp = 0,
    CharacterNeeds = {
        Energy = 10,
        MaxEnergy = 10,
        Hunger = 10,
        MaxHunger = 10,
    },
    Traits = {
        Creativity = 10,
        Logic = 10,
        Focus = 10,
    },
    GameDev = {
        Sizes = {
            Small = true;
        },
        Platforms = {
            PC = {
                Default = true
            },
            Console = {
                Default = true
            },
            Mobile = {
                Default = true
            }
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
    }
}

export type PlayerData = typeof(Template)

return Template
