local export topicTypes = {
    "Modern", "Medieval", "SciFi", "Space", "Dance", "Classical", "War", "Romance",
    "Fantasy", "Mystery", "Horror", "Superheroes", "Cyberpunk", "Post Apocalyptic", "Zombies",
    "Crime", "Fairy Tale", "Wildlife", "Farming", "Underwater", "Disaster",
}

local Topic = {}
Topic.__index = Topic

function Topic.new(name: string)
    local newTopic = {}
    setmetatable(newTopic, Topic)

    newTopic.Name = name
    newTopic.compatibleWith = {}
    newTopic.incompatibleWith = {}

    return newTopic
end

-- CLASS METHODS
function Topic.CalculateTopicCost(plrData): number
    local amtOfTopics = #plrData.GameDev.Topics
    -- come up with cost formula
end


-- INSTANCE METHODS
function Topic:AddCompatibleGenre(genreObject)
    if not table.find(self.compatibleWith, genreObject) and not table.find(self.incompatibleWith, genreObject) then
        table.insert(self.compatibleWith, genreObject)
    end
end

function Topic:AddIncompatibleGenre(genreObject)
    if not table.find(self.incompatibleWith, genreObject) and not table.find(self.compatibleWith, genreObject) then
        table.insert(self.incompatibleWith, genreObject)
    end
end

return Topic