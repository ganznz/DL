local export genreTypes = {
    "Action", "Casual", "Strategy", "Rythm", "Simulation", "Adventure", "Platformer", "Shooter", "Sports", "Fighting", "Roleplay",
    "Racing", "Arcade", "Roguelite", "Puzzle", "Tower Defense",
}

local Genre = {}
Genre.__index = Genre

function Genre.new(name: string)
    if not table.find(genreTypes, name) then return nil end

    local newGenre = {}
    setmetatable(newGenre, Genre)

    newGenre.Name = name
    newGenre.compatibleWith = {}
    newGenre.incompatibleWith = {}

    return newGenre
end

-- CLASS METHODS
function Genre.CalculateGenreCost(plrData): number
    local amtOfGenres = #plrData.GameDev.Genres
    -- come up with cost formula
end


-- INSTANCE METHODS
function Genre:AddCompatibleTopic(topicObject)
    if not table.find(self.compatibleWith, topicObject) and not table.find(self.incompatibleWith, topicObject) then
        table.insert(self.compatibleWith, topicObject)
        topicObject:AddCompatibleGenre(self)
    end
end

function Genre:AddIncompatibleTopic(topicObject)
    if not table.find(self.incompatibleWith, topicObject) and not table.find(self.compatibleWith, topicObject) then
        table.insert(self.incompatibleWith, topicObject)
        topicObject:AddIncompatibleGenre(self)
    end
end


return Genre