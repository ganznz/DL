local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local ComputerConfigServer = require(ServerScriptService.Functionality.GameDev.ComputerConfigServer)
local StudioConfigServer = require(ServerScriptService.Functionality.Studio.StudioConfigServer)

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
    ComputerConfigServer.LevelUpComputer(plr)

    -- replicate changes to others players who are in this players studio
    local plrsInStudio = StudioConfigServer.PlrsInStudio
end)