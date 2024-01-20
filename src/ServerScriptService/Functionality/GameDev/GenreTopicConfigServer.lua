local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local GenreConfig = require(ReplicatedStorage.Configs.GameDev:WaitForChild("Genre"))
local TopicConfig = require(ReplicatedStorage.Configs.GameDev:WaitForChild("Topic"))

local Remotes = ReplicatedStorage.Remotes

local GenreTopic = {}

local function getAvailableGenres(plrData): {}
    local availableGenres = {}

    for genreName, _genreInfo in GenreConfig.Config do
        if not plrData.GameDev.Genres[genreName] then table.insert(availableGenres, genreName) end
    end

    return availableGenres
end

local function getAvailableTopics(plrData): {}
    local availableTopics = {}

    for topicName, _topicInfo in TopicConfig.Config do
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
    profile.Data.GameDev.Genres[newGenre] = { Level = 1, XP = 0, CompatibleWith = nil, IncompatibleWith = nil }
    
    print(string.format("%s has unlocked genre - %s!", plr.Name, newGenre))

    Remotes.GameDev.UnlockGenre:FireClient(plr, newGenre)

    -- let other scripts know plr unlocked genre (for other plr's in studio)
    Remotes.GameDev.UnlockGenreBindable:Fire(plr, newGenre)

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
    profile.Data.GameDev.Topics[newTopic] = { Level = 1, XP = 0, CompatibleWith = nil, IncompatibleWith = nil }
    
    print(string.format("%s has unlocked topic - %s!", plr.Name, newTopic))

    Remotes.GameDev.UnlockTopic:FireClient(plr, newTopic)

    -- let other scripts know plr unlocked genre (for other plr's in studio)
    Remotes.GameDev.UnlockTopicBindable:Fire(plr, newTopic)

    return newTopic
end

return GenreTopic