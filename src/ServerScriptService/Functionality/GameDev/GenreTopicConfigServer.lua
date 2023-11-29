local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local GenreConfig = require(ReplicatedStorage.Configs.GameDev:WaitForChild("Genre"))
local TopicConfig = require(ReplicatedStorage.Configs.GameDev:WaitForChild("Topic"))

local GenreTopic = {}

local function getAvailableGenres(plrData): {}
    local availableGenres = {}

    for genreName, _genreInfo in GenreConfig.Genres do
        if not plrData.GameDev.Genres[genreName] then table.insert(availableGenres, genreName) end
    end

    return availableGenres
end

local function getAvailableTopics(plrData): {}
    local availableTopics = {}

    for topicName, _topicInfo in TopicConfig.Topics do
        if not plrData.GameDev.Topics[topicName] then table.insert(availableTopics, topicName) end
    end

    return availableTopics
end

function GenreTopic.UnlockGenre(plr: Player): string
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local availableGenres = getAvailableGenres(profile.Data)

    if #availableGenres == 0 then return string.format("%s has already unlocked all genres!", plr.Name) end

    -- get random genre from table
    local newGenre = availableGenres[math.random(1, #availableGenres)]

    -- add new genre to plr data
    profile.Data.GameDev.Genres[newGenre] = { Level = nil, XP = nil, CompatibleWith = nil, IncompatibleWith = nil }
    
    print(string.format("%s has unlocked genre - %s!", plr.Name, newGenre))
    return newGenre
end

function GenreTopic.UnlockTopic(plr: Player)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local availableTopics = getAvailableTopics(profile.Data)

    if #availableTopics == 0 then return string.format("%s has already unlocked all topics!", plr.Name) end

    -- get random topic from table
    local newTopic = availableTopics[math.random(1, #availableTopics)]

    -- add new topic to plr data
    profile.Data.GameDev.Topics[newTopic] = { Level = nil, XP = nil, CompatibleWith = nil, IncompatibleWith = nil }
    
    print(string.format("%s has unlocked topic - %s!", plr.Name, newTopic))
    return newTopic
end

return GenreTopic