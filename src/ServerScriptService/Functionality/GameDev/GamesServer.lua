local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local GeneralUtils = require(ReplicatedStorage.Utils.GeneralUtils)
local TableHandler = require(ReplicatedStorage.Libs.TableHandler.TableHandler)
local GamesConfig = require(ReplicatedStorage.Configs.GameDev.Games)
local GenreConfigServer = require(ServerScriptService.Functionality.GameDev.GenreServer)
local TopicConfigServer = require(ServerScriptService.Functionality.GameDev.TopicServer)
local PlayerManager = require(ServerScriptService.Functionality.Player.PlayerManager)

local Remotes = ReplicatedStorage.Remotes

local tableHandler = TableHandler.new()
tableHandler.Ascending = false


local rng = Random.new()

-- function calculates the points distribution ("Even" | "Uneven") of an unpublished game based on the game points
function GamesConfig.CalculateGamePtDistribution(gameStateInfo: {}): "Even" | "Uneven"
    local totalGamePts = gameStateInfo.GamePoints.Code + gameStateInfo.GamePoints.Sound + gameStateInfo.GamePoints.Art
    local evenPtDistribution = true -- ideal pt distributionion is 0.33% per point type, if this deviates by -+10% for any point type, pt distribution is not even
    if not GeneralUtils.IsInRange(NumberRange.new(0.23, 0.43), gameStateInfo.GamePoints.Code / totalGamePts) then evenPtDistribution = false end
    if not GeneralUtils.IsInRange(NumberRange.new(0.23, 0.43), gameStateInfo.GamePoints.Sound / totalGamePts) then evenPtDistribution = false end
    if not GeneralUtils.IsInRange(NumberRange.new(0.23, 0.43), gameStateInfo.GamePoints.Art / totalGamePts) then evenPtDistribution = false end

    return if evenPtDistribution then "Even" else "Uneven"
end

-- function calculates game reviews for an unpublished game
function GamesConfig.CreateGameReviews(plr: Player, gameStateInfo: {})
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    
    local bugFixStageInfo = gameStateInfo.PhaseInfo["-1"]
    local bugsMissedPercentage: number = (bugFixStageInfo.Misses / bugFixStageInfo.TotalBugs) * 100
    local buggyGame: boolean = bugsMissedPercentage > 40

    local availableReviewOptions = {"Incompatible", "Compatible", "RecentlyUsed", "Buggy", "Funny", "NonInformational"}
    
    -- remove review options that don't apply
    if gameStateInfo.GameResults.GenreTopicRelationship ~= "Incompatible" then table.remove(availableReviewOptions, table.find(availableReviewOptions, "Incompatible")) end
    if gameStateInfo.GameResults.GenreTopicRelationship ~= "Compatible" then table.remove(availableReviewOptions, table.find(availableReviewOptions, "Compatible")) end
    if not (gameStateInfo.GameResults.RecentlyUsedGenre or gameStateInfo.GameResults.RecentlyUsedTopic) then table.remove(availableReviewOptions, table.find(availableReviewOptions, "RecentlyUsed")) end
    if not buggyGame then table.remove(availableReviewOptions, table.find(availableReviewOptions, "Buggy")) end

    -- determine maximum star rating
    local starsToDeduct = 0
    if gameStateInfo.GameResults.GenreTopicRelationship == "Incompatible" then starsToDeduct += 1 end
    if gameStateInfo.GameResults.RecentlyUsedGenre or gameStateInfo.GameResults.RecentlyUsedTopic then starsToDeduct += 1 end
    if buggyGame then starsToDeduct += 1 end
    local maxStars = 5 - starsToDeduct
    local minStars = math.clamp(1, maxStars <= 3 and maxStars - 2 or maxStars - 1, 5)

    local reviews = {}
    local availableAuthorImageIDs = GamesConfig.Reviews.AuthorImageIDs
    for i = 1, 3, 1 do
        local starRating: number
        local reviewText: string

        starRating = rng:NextInteger(minStars, maxStars)
        
        local reviewOption = availableReviewOptions[math.random(1, #availableReviewOptions)]

        if reviewOption == "Incompatible" then
            local reviewTableSize = #GamesConfig.Reviews.IncompatibleGenreTopic
            reviewText = GamesConfig.Reviews.IncompatibleGenreTopic[math.random(1, reviewTableSize)]
            reviewText = reviewText:gsub("GENRE", gameStateInfo.Genre):gsub("TOPIC", gameStateInfo.Topic)
        end
            
        if reviewOption == "Compatible" then
            local reviewTableSize = #GamesConfig.Reviews.CompatibleGenreTopic
            reviewText = GamesConfig.Reviews.CompatibleGenreTopic[math.random(1, reviewTableSize)]
            reviewText = reviewText:gsub("GENRE", gameStateInfo.Genre):gsub("TOPIC", gameStateInfo.Topic)
        end

        if reviewOption == "RecentlyUsed" then
            local reviewTableSize = #GamesConfig.Reviews.RecentlyUsedGenreTopic
            reviewText = GamesConfig.Reviews.RecentlyUsedGenreTopic[math.random(1, reviewTableSize)]
            
            if gameStateInfo.GameResults.RecentlyUsedGenre and gameStateInfo.GameResults.RecentlyUsedTopic then
                reviewText = reviewText:gsub("GENRETOPIC", math.random() > 0.5 and gameStateInfo.Genre  or gameStateInfo.Topic)

            elseif gameStateInfo.GameResults.RecentlyUsedGenre then
                reviewText = reviewText:gsub("GENRETOPIC", gameStateInfo.Genre)
            else
                reviewText = reviewText:gsub("GENRETOPIC", gameStateInfo.Topic)
            end
        end

        if reviewOption == "Buggy" then
            local reviewTableSize = #GamesConfig.Reviews[tostring(starRating)].Informational.Bugs
            reviewText = GamesConfig.Reviews[tostring(starRating)].Informational.Bugs[math.random(1, reviewTableSize)]
        end

        if reviewOption == "Funny" then
            local reviewTableSize = #GamesConfig.Reviews[tostring(starRating)].Funny
            reviewText = GamesConfig.Reviews[tostring(starRating)].Funny[math.random(1, reviewTableSize)]
        end

        if reviewOption == "NonInformational" then
            local reviewTableSize = #GamesConfig.Reviews[tostring(starRating)].NonInformational
            reviewText = GamesConfig.Reviews[tostring(starRating)].NonInformational[math.random(1, reviewTableSize)]
        end

        if #availableReviewOptions > 1 then
            table.remove(availableReviewOptions, table.find(availableReviewOptions, reviewOption))
        end

        local reviewObject = {
            ["Stars"] = starRating,
            ["Review"] = reviewText,
            ["AuthorImageID"] = availableAuthorImageIDs[math.random(1, #availableAuthorImageIDs)]
        }

        -- remove the chance that the next review created will feature the same author image
        table.remove(availableAuthorImageIDs, table.find(availableAuthorImageIDs, reviewObject.AuthorImageID))

        table.insert(reviews, reviewObject)
    end

    return reviews
end

function GamesConfig.CalculateGameEarnings(plr: Player, gameStateInfo: {}): number
    local totalGamePts = gameStateInfo.GamePoints.Code + gameStateInfo.GamePoints.Sound + gameStateInfo.GamePoints.Art

    local baseEarnings = totalGamePts -- baseEarnings is used to calculate bonuses & penalties without an increase or decrease in the calculations
    local earnings = baseEarnings

    if gameStateInfo.GameResults.PointDistribution == "Uneven" then earnings -= (baseEarnings * 0.1) end

    if gameStateInfo.GameResults.GenreTopicRelationship == "Compatible" then
        earnings += (baseEarnings * 0.1)
    elseif gameStateInfo.GameResults.GenreTopicRelationship == "Incompatible" then
        earnings -= (baseEarnings * 0.1)
    end

    if gameStateInfo.GameResults["GenreTrending"] then
        earnings += (baseEarnings * 0.15)
    end
    if gameStateInfo.GameResults["TopicTrending"] then
        earnings += (baseEarnings * 0.15)
    end

    -- determine gamepass/marketing devproduct benefits

    return earnings
end

function GamesConfig.CalculateGameSales(plr: Player, gameStateInfo: {}): {}
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local totalSales = math.floor(gameStateInfo.GameResults.Earnings / 5)

    local week1Sales = math.floor(totalSales * math.clamp(rng:NextNumber(0.35, 0.75), 0.35, 0.5))
    local week2Sales = math.floor((totalSales - week1Sales) * math.clamp(rng:NextNumber(0.35, 0.75), 0.35, 0.5))
    local week3Sales = math.floor((totalSales - (week1Sales + week2Sales)) * math.clamp(rng:NextNumber(0.35, 0.75), 0.35, 0.5))
    local week4Sales = math.floor((totalSales - (week1Sales + week2Sales + week3Sales)))
    
    local weeklySales = {week1Sales, week2Sales, week3Sales, week4Sales}
    weeklySales = tableHandler:Sort(weeklySales) -- sort from highest sale week to lower sale week

    local sales = { Total = totalSales, Weekly = weeklySales }

    local xpToAdjustBy = sales.Total
    if gameStateInfo.GameResults.GenreTopicRelationship == "Compatible" then
        xpToAdjustBy *= 1.1 -- +10% genre/topic xp
    elseif gameStateInfo.GameResults.GenreTopicRelationship == "Incompatible" then
        xpToAdjustBy *= 0.9 -- -10% genre/topic xp
    end
    xpToAdjustBy = math.round(xpToAdjustBy)

    local genreInstance: GenreConfigServer.GenreInstance = GenreConfigServer.new(gameStateInfo.Genre, profile.Data.GameDev.Genres[gameStateInfo.Genre])
    local topicInstance: TopicConfigServer.TopicInstance = TopicConfigServer.new(gameStateInfo.Topic, profile.Data.GameDev.Topics[gameStateInfo.Topic])
    genreInstance:AdjustXp(plr, xpToAdjustBy)
    topicInstance:AdjustXp(plr, xpToAdjustBy)
    PlayerManager.AdjustXP(plr, xpToAdjustBy)

    return sales
end

function GamesConfig.SaveDevelopedGameData(plr: Player, gameStateInfo: {}): GamesConfig.GameData | nil
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    -- export type GameData = {
    --     Name: string,
    --     Genre: string,
    --     Topic: string,
    --     Points: { Code: number, Sound: number, Art: number },
    --     PointDistribution: "Even" | "Uneven",
    --     GenreTopicRelationship: "Compatible" | "Incompatible" | "Neutral",
    --     GenreTrending: boolean,
    --     TopicTrending: boolean,
    --     Sales: { Week1: number, Week2: number, Week3: number, Week4: number },
    --     Earnings: number,
    --     Reviews: {},
    --     Marketing: string | nil
    -- }
    
    local gameData: GamesConfig.GameData = {}

    local succ, err = pcall(function()
        gameData["Name"] = gameStateInfo.Name
        gameData["Genre"] = gameStateInfo.Genre
        gameData["Topic"] = gameStateInfo.Topic
        gameData["Points"] = gameStateInfo.GamePoints
        gameData["PointDistribution"] = gameStateInfo.GameResults.PointsDistribution
        gameData["GenreTopicRelationship"] = gameStateInfo.GameResults.GenreTopicRelationship
        gameData["GenreTrending"] = gameStateInfo.GameResults.GenreTrending
        gameData["TopicTrending"] = gameStateInfo.GameResults.TopicTrending
        gameData["Sales"] = gameStateInfo.GameResults.GameSales
        gameData["Earnings"] = gameStateInfo.GameResults.Earnings
        gameData["Reviews"] = gameStateInfo.GameResults.Reviews
        gameData["Marketing"] = gameStateInfo.Marketing
    end)
    if not succ then
        warn(`{plr.Name}'s newly developed game data did not save. Likely due to missing GameData parameters.`)
        return nil
    end

    -- save to datastore
    table.insert(profile.Data.GameDev.DevelopedGames, gameData)
    return gameData
end

return GamesConfig