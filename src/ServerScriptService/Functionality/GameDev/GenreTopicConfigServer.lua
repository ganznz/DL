local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local GenreTopicConfig = require(ReplicatedStorage.Configs.GameDev.GenreTopicConfig)
local GenreConfigServer = require(ServerScriptService.Functionality.GameDev.GenreServer)
local TopicConfigServer = require(ServerScriptService.Functionality.GameDev.TopicServer)
local StudioConfigServer = require(ServerScriptService.Functionality.Studio.StudioConfigServer)

local Remotes = ReplicatedStorage.Remotes

local TRENDING_REFRESH_COOLDOWN = 300 -- seconds (5min)

GenreTopicConfig.TrendingGenre = ""
GenreTopicConfig.TrendingTopic = ""

local function getAvailableGenres(plrData): {}
    local availableGenres = {}

    for genreName, _genreInfo in GenreConfigServer.Config do
        if not plrData.GameDev.Genres[genreName] then table.insert(availableGenres, genreName) end
    end

    return availableGenres
end

local function getAvailableTopics(plrData): {}
    local availableTopics = {}

    for topicName, _topicInfo in TopicConfigServer.Config do
        if not plrData.GameDev.Topics[topicName] then table.insert(availableTopics, topicName) end
    end

    return availableTopics
end

function GenreTopicConfig.UnlockGenre(plr: Player): string
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local availableGenres = getAvailableGenres(profile.Data)

    if #availableGenres == 0 then return string.format("%s has already unlocked all genres!", plr.Name) end

    -- get random genre from table
    local newGenre = availableGenres[math.random(1, #availableGenres)]

    -- add new genre to plr data
    profile.Data.GameDev.Genres[newGenre] = { Level = 1, XP = 0, CompatibleWith = "", IncompatibleWith = "" }

    Remotes.GameDev.GenreTopic.UnlockGenre:FireClient(plr, newGenre)

    -- update bookshelf for others also in this players studio
    for plrUserId, studioInfo in StudioConfigServer.PlrsInStudio do
        if studioInfo then
            if plrUserId == plr.UserId then continue end

            if studioInfo.PlrVisitingId == plr.UserId then
                local plrToFireRemote = Players:GetPlayerByUserId(plrUserId)
                Remotes.GameDev.GenreTopic.UnlockGenre:FireClient(plrToFireRemote, newGenre)
            end
        end
    end

    return newGenre
end

function GenreTopicConfig.UnlockTopic(plr: Player)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local availableTopics = getAvailableTopics(profile.Data)

    if #availableTopics == 0 then return string.format("%s has already unlocked all topics!", plr.Name) end

    -- get random topic from table
    local newTopic = availableTopics[math.random(1, #availableTopics)]

    -- add new topic to plr data
    profile.Data.GameDev.Topics[newTopic] = { Level = 1, XP = 0, CompatibleWith = "", IncompatibleWith = "" }

    Remotes.GameDev.GenreTopic.UnlockTopic:FireClient(plr, newTopic)

    -- update bookshelf for others also in this players studio
    local ownerStudioInfo = StudioConfigServer.PlrStudios[plr.UserId]
    if not ownerStudioInfo then return end

    for plrUserId, visitingPlrStudioInfo in StudioConfigServer.PlrsInStudio do
        if visitingPlrStudioInfo then
            if plrUserId == plr.UserId then continue end

            if visitingPlrStudioInfo.PlrVisitingId == plr.UserId and visitingPlrStudioInfo.StudioIndex == ownerStudioInfo.StudioIndex then
                local plrToFireRemote = Players:GetPlayerByUserId(plrUserId)
                Remotes.GameDev.GenreTopic.UnlockTopic:FireClient(plrToFireRemote, newTopic)
            end
        end
    end

    return newTopic
end

function GenreTopicConfig.EstablishGenreTopicRelationship(plr: Player, genre: string, topic: string)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local genreData = profile.Data.GameDev.Genres[genre]
    local topicData = profile.Data.GameDev.Topics[topic]
    if not genreData or not topicData then return end

    local genreInstance: GenreConfigServer.GenreInstance = GenreConfigServer.new(genre, genreData)
    local topicInstance: TopicConfigServer.TopicInstance = TopicConfigServer.new(topic, topicData)
    
    if math.random() > 0.5 then
        genreInstance:AddCompatibleTopic(plr, topicInstance)
    else
        genreInstance:AddIncompatibleTopic(plr, topicInstance)
    end
end

function GenreTopicConfig.ChooseTrendingGenre()
    local allGenres = GenreConfigServer.GetAllGenres()
    local previousGenre = GenreTopicConfig.TrendingGenre
    local newGenre = allGenres[math.random(1, #allGenres)]
    
    while previousGenre == newGenre do newGenre = allGenres[math.random(1, #allGenres)] end

    GenreTopicConfig.TrendingGenre = newGenre

    Remotes.GameDev.GenreTopic.ChangeTrendingGenre:FireAllClients(GenreTopicConfig.TrendingGenre)

end

function GenreTopicConfig.ChooseTrendingTopic()
    local allTopics = TopicConfigServer.GetAllTopics()
    local previousTopic = GenreTopicConfig.TrendingTopic
    local newTopic = allTopics[math.random(1, #allTopics)]

    while previousTopic == newTopic do newTopic = allTopics[math.random(1, #allTopics)] end

    GenreTopicConfig.TrendingTopic = newTopic


    Remotes.GameDev.GenreTopic.ChangeTrendingTopic:FireAllClients(GenreTopicConfig.TrendingTopic)
end


GenreTopicConfig.ChooseTrendingGenre()
GenreTopicConfig.ChooseTrendingTopic()

local cooldown = os.time() + TRENDING_REFRESH_COOLDOWN
task.spawn(function()
    while true do
        if os.time() > cooldown then
            GenreTopicConfig.ChooseTrendingGenre()
            GenreTopicConfig.ChooseTrendingTopic()
            cooldown = os.time() + TRENDING_REFRESH_COOLDOWN
        end
        task.wait(1)
    end
end)

return GenreTopicConfig