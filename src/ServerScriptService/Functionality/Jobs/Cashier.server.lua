local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local Zone = require(ReplicatedStorage.Libs.Zone)
local JobConfig = require(ReplicatedStorage.Configs.Jobs.Cashier)
local plrDataTemplate = require(ReplicatedStorage.PlayerData.Template)

local Remotes = ReplicatedStorage.Remotes

local IcecreamStoreTeleportHitbox = Workspace.Map.Buildings.IceCreamStore.IceCreamStoreExterior:WaitForChild("HitboxZone")
local zone = Zone.new(IcecreamStoreTeleportHitbox)

zone.playerEntered:Connect(function(plr: Player)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end
    local plrData: plrDataTemplate.PlayerData = profile.Data

    local plrCashierInstance = plrData.Jobs.Cashier.CashierInstance

    Remotes.GUI.ChangeGuiStatusRemote:FireClient(plr, "cashierJobInfo", true, {
        jobLevel = JobConfig.GetLevel(plrCashierInstance),
        xp = JobConfig.GetXp(plrCashierInstance),
        levelUpXpRequirement = JobConfig.CalcLevelUpXpRequirement(plrCashierInstance),
        traitPointsReward = JobConfig.CalcTraitPoints(plrCashierInstance),
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
        local plrData: plrDataTemplate.PlayerData = profile.Data

        Remotes.GUI.Jobs.UpdateJobTimerBtn:FireClient(plr, "cashierJob", plrData.Jobs.Cashier.ShiftCooldown)
    end

    task.wait(1)
end
