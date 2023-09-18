local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local Zone = require(ReplicatedStorage.Libs.Zone)
local JobConfig = require(ReplicatedStorage.Configs.Jobs.Job)

local Remotes = ReplicatedStorage.Remotes

local IcecreamStoreTeleportHitbox = Workspace.Map.Buildings.IceCreamStore.IceCreamStoreExterior:WaitForChild("HitboxZone")
local zone = Zone.new(IcecreamStoreTeleportHitbox)

zone.playerEntered:Connect(function(plr: Player)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local plrCashierInstance = profile.Data.Jobs.Cashier.CashierInstance

    Remotes.GUI.ChangeGuiStatusRemote:FireClient(plr, "cashierJobInfo", true, {
        -- jobLevel = plrCashierInstance:GetLevel(),
        -- xp = plrCashierInstance:GetXp(),
        -- levelUpXpRequirement = plrCashierInstance:CalcLevelUpXpRequirement(),
        -- traitPointsReward = plrCashierInstance:CalcTraitPoints(),
    })
end)

zone.playerExited:Connect(function(plr: Player)
    Remotes.GUI.ChangeGuiStatusRemote:FireClient(plr, "cashierJobInfo", false, nil)
end)


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
