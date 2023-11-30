local Topic = {}
Topic.__index = Topic

Topic.Topics = {
    ["Modern"] = { Image = "" },
    ["Medieval"] = { Image = "rbxassetid://15321891852" },
    ["Space"] = { Image = "rbxassetid://15322151139" },
    ["Classical"] = { Image = "rbxassetid://15500603910" },
    ["War"] = { Image = "rbxassetid://15322175017" },
    ["Romance"] = { Image = "rbxassetid://15321900358" },
    ["Fantasy"] = { Image = "rbxassetid://15321873100" },
    ["Mystery"] = { Image = "rbxassetid://15500607232" },
    ["Horror"] = { Image = "rbxassetid://15321880408" },
    ["Superhero"] = { Image = "rbxassetid://15500663476" },
    ["Cyberpunk"] = { Image = "rbxassetid://15500676919" },
    ["Zombies"] = { Image = "rbxassetid://15322197034" },
    ["Crime"] = { Image = "rbxassetid://15500821014" },
    ["Fairy Tale"] = { Image = "rbxassetid://15500831419" },
    ["Wildlife"] = { Image = "rbxassetid://15322190945" },
    ["Farming"] = { Image = "rbxassetid://15500840746" },
    ["Underwater"] = { Image = "rbxassetid://15322164872" },
    ["Disaster"] = { Image = "rbxassetid://15321826005" },
}

function Topic.new(name: string, level: number | nil, xp: number | nil, compatibleGenre: string | nil, incompatibleGenre: string | nil)
    if not Topic.Topics[name] then return nil end

    local newTopic = {}
    setmetatable(newTopic, Topic)

    newTopic.Name = name
    newTopic.Level = level or 1
    newTopic.XP = xp or 0
    newTopic.compatibleWith = compatibleGenre or nil
    newTopic.incompatibleWith = incompatibleGenre or nil

    return newTopic
end

function Topic.GetImage(name: string): string
    local topicInfo = Topic.Topics[name]
    if topicInfo then return topicInfo.Image else return "" end
end

-- CLASS METHODS
function Topic.CalculateTopicCost(plrData): number
    local amtOfTopics = #plrData.GameDev.Topics
    -- come up with cost formula
end


-- INSTANCE METHODS
function Topic:AddCompatibleGenre(genreObject)
    -- if both genre and topic don't have compatibilities
    if not self.compatibleWith and not genreObject.compatibleWith then
        self.compatibleWith = genreObject.Name
    end
end

function Topic:AddIncompatibleGenre(genreObject)
    -- if both genre and topic don't have incompatibilities
    if not self.incompatibleWith and not genreObject.incompatibleWith then
        self.incompatibleWith = genreObject.Name
    end
end

return Topic