-- // MODULES STORES GENERAL FUNCTIONALITY COMMON TO BOTH GENRES & TOPICS // --

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes

local PlrDataTemplate = require(ReplicatedStorage.PlayerData.Template)

local GenreTopic = {}

function GenreTopic.CalcLevelUpXp(plrData: PlrDataTemplate.PlayerData, type: "Genre" | "Topic", name: string): number
    if type ~= "Genre" and type ~= "Topic" then return end

    local data = type == "Genre" and plrData.GameDev.Genres[name] or plrData.GameDev.Topics[name]
    
    return 10 * math.pow(1.35, data.Level + 1)
end

return GenreTopic