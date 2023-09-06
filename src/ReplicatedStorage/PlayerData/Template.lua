local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GenreConfig = require(ReplicatedStorage.Configs:WaitForChild("Genre"))

-- Template is what empty profiles default to
local Template = {
    Cash = 0,
    Gems = 0,
    Fans = 0,

    GameDev = {
        Sizes = {
            Small = true;
            Medium = false;
            Large = false;
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
            Strategy = GenreConfig.new('Strategy')
        }
    }
}

export type PlayerData = typeof(Template)

return Template
