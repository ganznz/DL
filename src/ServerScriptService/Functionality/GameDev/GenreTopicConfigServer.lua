local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local GenreConfig = require(ReplicatedStorage.Configs.GameDev.Genre)
local TopicConfig = require(ReplicatedStorage.Configs.GameDev.Topic)
local StudioConfigServer = require(ServerScriptService.Functionality.Studio.StudioConfigServer)

local Remotes = ReplicatedStorage.Remotes

local GenreTopic = {}

-- values defined at bottom of script as cannot hoist functions
GenreTopic.TrendingGenre = nil
GenreTopic.TrendingTopic = nil

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
    profile.Data.GameDev.Genres[newGenre] = { Level = 1, XP = 0, CompatibleWith = "", IncompatibleWith = "" }
    
    print(string.format("%s has unlocked genre - %s!", plr.Name, newGenre))

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

function GenreTopic.UnlockTopic(plr: Player)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local availableTopics = getAvailableTopics(profile.Data)

    if #availableTopics == 0 then return string.format("%s has already unlocked all topics!", plr.Name) end

    -- get random topic from table
    local newTopic = availableTopics[math.random(1, #availableTopics)]

    -- add new topic to plr data
    profile.Data.GameDev.Topics[newTopic] = { Level = 1, XP = 0, CompatibleWith = "", IncompatibleWith = "" }
    
    print(string.format("%s has unlocked topic - %s!", plr.Name, newTopic))

    Remotes.GameDev.GenreTopic.UnlockTopic:FireClient(plr, newTopic)

    -- update bookshelf for others also in this players studio
    for plrUserId, studioInfo in StudioConfigServer.PlrsInStudio do
        if studioInfo then
            if plrUserId == plr.UserId then continue end

            if studioInfo.PlrVisitingId == plr.UserId then
                local plrToFireRemote = Players:GetPlayerByUserId(plrUserId)
                Remotes.GameDev.GenreTopic.UnlockTopic:FireClient(plrToFireRemote, newTopic)
            end
        end
    end

    return newTopic
end

function GenreTopic.EstablishGenreTopicRelationship(plr: Player, genre: string, topic: string)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local genreData = profile.Data.GameDev.Genres[genre]
    local topicData = profile.Data.GameDev.Topics[topic]
    if not genreData or not topicData then return end

    local genreInstance: GenreConfig.GenreInstance = GenreConfig.new(genre, genreData)
    local topicInstance: TopicConfig.TopicInstance = TopicConfig.new(topic, topicData)
    
    local relationshipType = nil
    
    -- if genre and topic have no compatible AND incompatible relationships, then 50/50 chance to determine relationshipType
    if (genreInstance.CompatibleWith == "" and genreInstance.IncompatibleWith == "") and (topicInstance.CompatibleWith == "" and topicInstance.IncompatibleWith == "") then
        if math.random() > 0.5 then
            genreInstance.CompatibleWith = topic
            topicInstance.CompatibleWith = genre
            profile.Data.GameDev.Genres[genre].CompatibleWith = topic
            profile.Data.GameDev.Topics[topic].CompatibleWith = genre
        else
            genreInstance.IncompatibleWith = topic
            topicInstance.IncompatibleWith = genre
            profile.Data.GameDev.Genres[genre].IncompatibleWith = topic
            profile.Data.GameDev.Topics[topic].IncompatibleWith = genre
        end

    -- if genre and topic both have no compatible relationships, then make them compatible with one another
    elseif genreInstance.CompatibleWith == "" and topicInstance.CompatibleWith == "" then
        genreInstance.CompatibleWith = topic
        topicInstance.CompatibleWith = genre
        profile.Data.GameDev.Genres[genre].CompatibleWith = topic
        profile.Data.GameDev.Topics[topic].CompatibleWith = genre

    -- if genre and topic both have no incompatible relationships, then make them incompatible with one another
    elseif genreInstance.IncompatibleWith == "" and topicInstance.IncompatibleWith == "" then
        genreInstance.IncompatibleWith = topic
        topicInstance.IncompatibleWith = genre
        profile.Data.GameDev.Genres[genre].IncompatibleWith = topic
        profile.Data.GameDev.Topics[topic].IncompatibleWith = genre
    end

    if not relationshipType then return end
end

function GenreTopic.ChooseTrendingGenre()
    local allGenres = GenreConfig.GetAllGenres()
    local chosenGenre = allGenres[math.random(1, #allGenres)]
    while chosenGenre == GenreTopic.TrendingGenre do chosenGenre = allGenres[math.random(1, #allGenres)] end

    GenreTopic.TrendingGenre = chosenGenre
    Remotes.GameDev.GenreTopic.ChangeTrendingGenre:FireAllClients(GenreTopic.TrendingGenre)
end

function GenreTopic.ChooseTrendingTopic()
    local allTopics = TopicConfig.GetAllTopics()
    local chosenTopic = allTopics[math.random(1, #allTopics)]
    while chosenTopic == GenreTopic.TrendingTopic do chosenTopic = allTopics[math.random(1, #allTopics)] end

    GenreTopic.TrendingTopic = chosenTopic

    Remotes.GameDev.GenreTopic.ChangeTrendingTopic:FireAllClients(GenreTopic.TrendingTopic)
end


GenreTopic.TrendingGenre = GenreTopic.ChooseTrendingGenre()
GenreTopic.TrendingTopic = GenreTopic.ChooseTrendingTopic()

local cooldown = os.time() + 300 -- 5min between changing trending genre & topic
task.spawn(function()
    while true do
        if os.time() > cooldown then
            GenreTopic.TrendingGenre = GenreTopic.ChooseTrendingGenre()
            GenreTopic.TrendingTopic = GenreTopic.ChooseTrendingTopic()
            cooldown = os.time() + 2
        end
        task.wait(1)
    end
end)


return GenreTopic