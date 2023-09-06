local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Genre = {}
Genre.__index = Genre

function Genre.new(name)
    local newgenre = {}
    setmetatable(newgenre, Genre)

    newgenre.Name = name
    newgenre.compatibleWith = {}
    newgenre.incompatibleWith = {}

    return newgenre
end

-- CLASS METHODS
function Genre.CalculateGenreCost(plrData): number
    local amtOfGenres = #plrData.GameDev.Genres
    -- come up with cost formula
end


-- INSTANCE METHODS
function Genre:AddCompatibleTopic(topicName: string)
    if not table.find(self.compatibleWith, topicName) and not table.find(self.incompatibleWith, topicName) then
        table.insert(self.compatibleWith, topicName)
    end
end

function Genre:AddIncompatibleTopic(topicName: string)
    if not table.find(self.incompatibleWith, topicName) and not table.find(self.compatibleWith, topicName) then
        table.insert(self.incompatibleWith, topicName)
    end
end

return Genre