local Genre = {}
Genre.__index = Genre

export type GenreConfig = {
    ImageIcon: string,
    ImageSplash: string
}

local config: { [string]: GenreConfig } = {
    ["Action"] = { ImageIcon = "", ImageSplash = "" },
    ["Casual"] = { ImageIcon = "", ImageSplash = "" },
    ["Strategy"] = { ImageIcon = "", ImageSplash = "" },
    ["Rythm"] = { ImageIcon = "", ImageSplash = "" },
    ["Simulation"] = { ImageIcon = "", ImageSplash = "" },
    ["Adventure"] = { ImageIcon = "", ImageSplash = "" },
    ["Platformer"] = { ImageIcon = "", ImageSplash = "" },
    ["Sports"] = { ImageIcon = "", ImageSplash = "" },
    ["Fighting"] = { ImageIcon = "", ImageSplash = "" },
    ["Roleplay"] = { ImageIcon = "", ImageSplash = "" },
    ["Racing"] = { ImageIcon = "", ImageSplash = "" },
    ["Arcade"] = { ImageIcon = "", ImageSplash = "" },
    ["Roguelite"] = { ImageIcon = "", ImageSplash = "" },
    ["Puzzle"] = { ImageIcon = "", ImageSplash = "" },
    ["Tower Defense"] = { ImageIcon = "", ImageSplash = "" },
}

Genre.Config = config

function Genre.GetConfig(name: string): GenreConfig | nil
    return Genre.Config[name]
end

function Genre.new(name: string, level: number | nil, xp: number | nil, compatibleTopic: string | nil, incompatibleTopic: string | nil)
    local genreConfig = Genre.GetConfig(name)
    if not genreConfig then return nil end

    local newGenre = {}
    setmetatable(newGenre, Genre)

    newGenre.Name = name
    newGenre.Level = level or 1
    newGenre.XP = xp or 0
    newGenre.CompatibleWith = compatibleTopic or nil
    newGenre.IncompatibleWith = incompatibleTopic or nil

    return newGenre
end

-- CLASS METHODS
function Genre.CalculateGenreCost(plrData): number
    local amtOfGenres = #plrData.GameDev.Genres
    -- come up with cost formula
end


-- INSTANCE METHODS
function Genre:AddCompatibleTopic(topicObject)
    -- if both genre and topic don't have compatibilities
    if not self.CompatibleWith and not topicObject.CompatibleWith then
        self.CompatibleWith = topicObject.Name
    end
end

function Genre:AddIncompatibleTopic(topicObject)
    -- if both genre and topic don't have incompatibilities
    if not self.IncompatibleWith and not topicObject.IncompatibleWith then
        self.IncompatibleWith = topicObject.Name
    end
end


return Genre