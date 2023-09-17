local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)

-- push plrs who are in an active shift to this table
-- { [Player]: { remainingTime: number, goodOrders: number, badOrders: number } }
local activeShifts = {}

while true do
    for _, plr in Players:GetPlayers() do
        local profile = PlrDataManager.Profiles[plr]
        if not profile then continue end
    end

    task.wait(1)
end
