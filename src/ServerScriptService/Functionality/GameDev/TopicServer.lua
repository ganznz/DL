-- // The functionality in this file are used only for operations on Topic class objects // --

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local GenreTopicConfig = require(ReplicatedStorage.Configs.GameDev.GenreTopicConfig)
local TopicConfig = require(ReplicatedStorage.Configs.GameDev.Topic)

local Remotes = ReplicatedStorage.Remotes

function TopicConfig:AdjustXp(plr: Player, adjustBy: number): number
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local topicData = profile.Data.GameDev.Topics[self.Name]

    local preAdjustmentLevel = self.Level
    local preAdjustmentXp = self.XP
    local xpLvlRequirement: number = GenreTopicConfig.CalcLevelUpXp(profile.Data, "Topic", self.Name)
    local preAdjustmentMaxXp = xpLvlRequirement

    -- adjust xp and/or level
    if preAdjustmentXp + adjustBy >= xpLvlRequirement then

        local leftOverXp = preAdjustmentXp + adjustBy - xpLvlRequirement
        -- while topic can continue to level up more than once
        while leftOverXp >= 0 do
            self.Level += 1
            topicData.Level += 1
            xpLvlRequirement = GenreTopicConfig.CalcLevelUpXp(profile.Data, "Topic", self.Name)
            self.XP = leftOverXp
            topicData.XP = leftOverXp
            leftOverXp -= xpLvlRequirement
        end
    else -- no level up, only xp adjustment
        self.XP += adjustBy
        topicData.XP += adjustBy
    end

    Remotes.GameDev.GenreTopic.AdjustTopicXP:FireClient(plr, topicData, self, {
        PreAdjustmentLevel = preAdjustmentLevel,
        PreAdjustmentXP = preAdjustmentXp,
        PostAdjustmentLevel = self.Level,
        PreAdjustmentMaxXP = preAdjustmentMaxXp,
        PostAdjustmentXP = self.XP,
        PostAdjustmentMaxXP = GenreTopicConfig.CalcLevelUpXp(profile.Data, "Topic", self.Name)
    })
end

return TopicConfig