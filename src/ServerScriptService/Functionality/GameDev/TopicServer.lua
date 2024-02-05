-- // The functionality in this file are used only for operations on Topic class objects // --

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local TopicConfig = require(ReplicatedStorage.Configs.GameDev.Topic)

local Remotes = ReplicatedStorage.Remotes

function TopicConfig:AddCompatibleTopic(genreObject)
    -- if both genre and topic don't have compatibilities
    if self.CompatibleWith == "" and genreObject.CompatibleWith == "" then
        self.CompatibleWith = genreObject.Name
    end
end

function TopicConfig:AddIncompatibleTopic(genreObject)
    -- if both genre and topic don't have incompatibilities
    if self.IncompatibleWith == "" and genreObject.IncompatibleWith == "" then
        self.IncompatibleWith = genreObject.Name
    end
end