-- // The functionality in this file are used only for operations on Genre class objects // --

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local GenreTopicConfig = require(ReplicatedStorage.Configs.GameDev.GenreTopicConfig)
local GenreConfig = require(ReplicatedStorage.Configs.GameDev.Genre)
local TopicConfig = require(ReplicatedStorage.Configs.GameDev.Topic)

local Remotes = ReplicatedStorage.Remotes

-- there are NO methods in TopicConfig for adding compatible/incompatible genres, this is done in this method
function GenreConfig:AddCompatibleTopic(plr: Player, topicObject: TopicConfig.TopicInstance)
    if not PlrDataManager.Profiles[plr] then return end

    -- if either genre or topic already have a defined relationship then do nothing
    if (self.CompatibleWith ~= "" or self.IncompatibleWith ~= "") or (topicObject.CompatibleWith ~= "" or topicObject.IncompatibleWith ~= "") then return end

    self.CompatibleWith = topicObject.Name
    topicObject.CompatibleWith = self.Name

    PlrDataManager.Profiles[plr].Data.GameDev.Genres[self.Name].CompatibleWith = topicObject.Name
    PlrDataManager.Profiles[plr].Data.GameDev.Topics[topicObject.Name].CompatibleWith = self.Name
end

function GenreConfig:AddIncompatibleTopic(plr: Player, topicObject: TopicConfig.TopicInstance)
    if not PlrDataManager.Profiles[plr] then return end

    -- if either genre or topic already have a defined relationship then do nothing
    if (self.CompatibleWith ~= "" or self.IncompatibleWith ~= "") or (topicObject.CompatibleWith ~= "" or topicObject.IncompatibleWith ~= "") then return end

    self.IncompatibleWith = topicObject.Name
    topicObject.IncompatibleWith = self.Name

    PlrDataManager.Profiles[plr].Data.GameDev.Genres[self.Name].IncompatibleWith = topicObject.Name
    PlrDataManager.Profiles[plr].Data.GameDev.Topics[topicObject.Name].IncompatibleWith = self.Name
end

function GenreConfig:AdjustXp(plr: Player, adjustBy: number): number
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local genreData = profile.Data.GameDev.Genres[self.Name]

    local preAdjustmentLevel = self.Level
    local preAdjustmentXp = self.XP
    local xpLvlRequirement: number = GenreTopicConfig.CalcLevelUpXp(profile.Data, "Genre", self.Name)
    local preAdjustmentMaxXp = xpLvlRequirement

    -- adjust xp and/or level
    if preAdjustmentXp + adjustBy >= xpLvlRequirement then

        local leftOverXp = preAdjustmentXp + adjustBy - xpLvlRequirement
        -- while genre can continue to level up more than once
        while leftOverXp >= 0 do
            self.Level += 1
            genreData.Level += 1
            xpLvlRequirement = GenreTopicConfig.CalcLevelUpXp(profile.Data, "Genre", self.Name)
            self.XP = leftOverXp
            genreData.XP = leftOverXp
            leftOverXp -= xpLvlRequirement
        end
    else -- no level up, only xp adjustment
        self.XP += adjustBy
        genreData.XP += adjustBy
    end

    Remotes.GameDev.GenreTopic.AdjustGenreXP:FireClient(plr, genreData, self, {
        PreAdjustmentLevel = preAdjustmentLevel,
        PreAdjustmentXP = preAdjustmentXp,
        PreAdjustmentMaxXP = preAdjustmentMaxXp,
        PostAdjustmentLevel = self.Level,
        PostAdjustmentXP = self.XP,
        PostAdjustmentMaxXP = GenreTopicConfig.CalcLevelUpXp(profile.Data, "Genre", self.Name)
    })
end

return GenreConfig