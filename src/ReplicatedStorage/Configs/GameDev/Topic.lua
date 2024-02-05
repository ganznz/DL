local Topic = {}
Topic.__index = Topic

export type TopicConfig = {
    ImageIcon: string,
    ImageSplash: string
}

export type TopicInstance = {
    Name: string,
    Level: number,
    XP: number,
    CompatibleWith: string,
    IncompatibleWith: string
}

local config: { [string]: TopicConfig } = {
    ["Modern"] = { ImageIcon = "", ImageSplash = "" },
    ["Medieval"] = { ImageIcon = "15321891852", ImageSplash = "16019379114" },
    ["Space"] = { ImageIcon = "15322151139", ImageSplash = "16019372896" },
    ["Classical"] = { ImageIcon = "15500603910", ImageSplash = "16018696449" },
    ["War"] = { ImageIcon = "15322175017", ImageSplash = "16019376051" },
    ["Romance"] = { ImageIcon = "15321900358", ImageSplash = "16019372124" },
    ["Fantasy"] = { ImageIcon = "15321873100", ImageSplash = "16019347093" },
    ["Mystery"] = { Image = "15500607232", ImageSplash = "16019370516" },
    ["Horror"] = { ImageIcon = "15321880408", ImageSplash = "16019349187" },
    ["Superhero"] = { ImageIcon = "15500663476", ImageSplash = "16019373783" },
    ["Cyberpunk"] = { ImageIcon = "15500676919", ImageSplash = "16018697363" },
    ["Zombies"] = { ImageIcon = "15322197034", ImageSplash = "16019378257" },
    ["Crime"] = { ImageIcon = "15500821014", ImageSplash = "16018683567" },
    ["Fairy Tale"] = { ImageIcon = "15500831419", ImageSplash = "16018700351" },
    ["Wildlife"] = { ImageIcon = "15322190945", ImageSplash = "16019377005" },
    ["Farming"] = { ImageIcon = "15500840746", ImageSplash = "16019348167" },
    ["Underwater"] = { ImageIcon = "15322164872", ImageSplash = "16019375034" },
    ["Disaster"] = { ImageIcon = "15321826005", ImageSplash = "16018698368" },
}

Topic.Config = config

function Topic.GetAllTopics()
    local allTopics = {}
    for name, _info in Topic.Config do table.insert(allTopics, name) end

    return allTopics
end

function Topic.GetConfig(name: string): TopicConfig | nil
    return Topic.Config[name]
end

function Topic.new(topicName: string, topicData: {}): TopicInstance
    local topicConfig = Topic.GetConfig(topicName)
    if not topicConfig then return nil end

    local newTopic = {}
    setmetatable(newTopic, Topic)

    newTopic.Name = topicName
    newTopic.Level = topicData.Level
    newTopic.XP = topicData.XP
    newTopic.CompatibleWith = topicData.CompatibleWith
    newTopic.IncompatibleWith = topicData.IncompatibleWith

    return newTopic
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