-- // The functionality in this file are used only for operations on Genre class objects // --

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local GenreConfig = require(ReplicatedStorage.Configs.GameDev.Genre)

local Remotes = ReplicatedStorage.Remotes

function GenreConfig:AddCompatibleTopic(topicObject)
    -- if both genre and topic don't have compatibilities
    if self.CompatibleWith == "" and topicObject.CompatibleWith == "" then
        self.CompatibleWith = topicObject.Name
    end
end

function GenreConfig:AddIncompatibleTopic(topicObject)
    -- if both genre and topic don't have incompatibilities
    if self.IncompatibleWith == "" and topicObject.IncompatibleWith == "" then
        self.IncompatibleWith = topicObject.Name
    end
end