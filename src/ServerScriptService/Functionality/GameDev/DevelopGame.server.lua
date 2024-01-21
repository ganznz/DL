local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlrPlatformManager = require(ServerScriptService.PlayerData.PlrPlatformManager)

local Remotes = ReplicatedStorage.Remotes

-- keeps track of all plrs in the server and information on games they're developing
-- { [plr.UserId] = { studioIndex: string, studioStatus: "open" | "closed" | "friends" } | false }
local plrsDeveloping = {

}

Remotes.GameDev.DevelopGame.OnServerEvent:Connect(function(plr: Player, selectedGenre: string, selectedTopic: string)
    Remotes.GameDev.DevelopGame:FireClient(plr, 1)
    plr:SetAttribute("CurrentlyDevelopingGame", true)
    plrsDeveloping[plr.UserId] = {

    }
end)

for _i, plr: Player in Players:GetPlayers() do
    plrsDeveloping[plr.UserId] = false
end

Players.PlayerAdded:Connect(function(plr: Player)
    plrsDeveloping[plr.UserId] = false
end)

Players.PlayerRemoving:Connect(function(plr: Player)
    plrsDeveloping[plr.UserId] = nil
end)