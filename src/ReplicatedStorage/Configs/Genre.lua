local Genre = {}
Genre.__index = Genre

Genre.Genres = {
    ["Action"] = { Image = "" },
    ["Casual"] = { Image = "" },
    ["Strategy"] = { Image = "" },
    ["Rythm"] = { Image = "" },
    ["Simulation"] = { Image = "" },
    ["Adventure"] = { Image = "" },
    ["Platformer"] = { Image = "" },
    ["Sports"] = { Image = "" },
    ["Fighting"] = { Image = "" },
    ["Roleplay"] = { Image = "" },
    ["Racing"] = { Image = "" },
    ["Arcade"] = { Image = "" },
    ["Roguelite"] = { Image = "" },
    ["Puzzle"] = { Image = "" },
    ["Tower Defense"] = { Image = "" },
}

function Genre.new(name: string, level: number | nil, xp: number | nil, compatibleTopic: string | nil, incompatibleTopic: string | nil)
    if not Genre.Genres[name] then return nil end

    local newGenre = {}
    setmetatable(newGenre, Genre)

    newGenre.Name = name
    newGenre.Level = level or 1
    newGenre.XP = xp or 0
    newGenre.CompatibleWith = compatibleTopic or nil
    newGenre.IncompatibleWith = incompatibleTopic or nil

    return newGenre
end

function Genre.GetImage(name: string): string
    local genreInfo = Genre.Genres[name]
    if genreInfo then return genreInfo.Image else return "" end
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