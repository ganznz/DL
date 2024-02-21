local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local GeneralUtils = require(ReplicatedStorage.Utils.GeneralUtils)
local ComputerConfigServer = require(ServerScriptService.Functionality.GameDev.ComputerConfigServer)

local Remotes = ReplicatedStorage.Remotes

Remotes.GameDev.Computer.ChangeActiveComputerUpgrade.OnServerEvent:Connect(function(plr: Player, upgradeName: string)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    -- check if passed upgrade name is invalid/doesn't exist
    local plrComputerLvl: number = profile.Data.GameDev.Computer.Level
    local computerConfig: ComputerConfigServer.ComputerConfig = ComputerConfigServer.GetConfig(plrComputerLvl)
    if not computerConfig.Upgrades[upgradeName] then return end

    -- check if upgrade is already active
    if profile.Data.GameDev.Computer.ActiveUpgrade == upgradeName then return end

    -- check if upgrade is already completed
    local upgradeData = profile.Data.GameDev.Computer.UpgradeProgress[plrComputerLvl][upgradeName]
    local upgradeProg = upgradeData.Progress
    local upgradeGoal = upgradeData.Goal
    if upgradeProg >= upgradeGoal then return end

    -- all checks passed, change
    profile.Data.GameDev.Computer.ActiveUpgrade = upgradeName
    
    Remotes.GameDev.Computer.ChangeActiveComputerUpgrade:FireClient(plr, upgradeName)
end)

Remotes.GameDev.Computer.LevelUpComputer.OnServerEvent:Connect(function(plr: Player)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    ComputerConfigServer.LevelUpComputer(plr)
end)