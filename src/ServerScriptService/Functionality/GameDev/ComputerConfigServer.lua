local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local ComputerConfig = require(ReplicatedStorage.Configs.GameDev.Computer)
local FormatNumber = require(ReplicatedStorage.Libs.FormatNumber.Simple)

local Remotes = ReplicatedStorage.Remotes

-- CONSTANTS --
local upgradeProgNotificationText = "UPGRADE_NAME Progress: PROG"
local upgradeCompletedNotificationText = "UPGRADE_NAME COMPLETE! Choose a new computer upgrade"

-- args        
-- adjustment -> number: The amount of progress to add to the specified computer upgrade
function ComputerConfig.UpdateComputerUpgradeProgress(plr: Player, upgradeName: string, adjustment: number)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end
    
    local plrComputerLevel: number = profile.Data.GameDev.Computer.Level
    local plrUpgradeData = profile.Data.GameDev.Computer.UpgradeProgress[plrComputerLevel][upgradeName]

    -- check if upgrade already complete
    if plrUpgradeData.Progress >= plrUpgradeData.Goal then return end

    -- make changes
    local upgradeComplete = false
    if plrUpgradeData.Progress + adjustment >= plrUpgradeData.Goal then
        plrUpgradeData.Progress = plrUpgradeData.Goal
        upgradeComplete = true
    else
        plrUpgradeData.Progress += adjustment
    end

    -- sent progress notification
    if upgradeComplete then
        -- if upgrade was completed, that upgrade is no longer "active"
        profile.Data.GameDev.Computer.ActiveUpgrade = false

        local notiText: string = upgradeCompletedNotificationText:gsub("UPGRADE_NAME", `<font color="#bce3c3"><stroke color="#56a863" thickness="2">{upgradeName}</stroke></font>`)
        Remotes.GUI.DisplayNotification:FireClient(plr, "good", notiText)
    else
        local notiText: string = upgradeProgNotificationText:gsub("UPGRADE_NAME", `<font color="#bce3c3"><stroke color="#56a863" thickness="2">{upgradeName}</stroke></font>`)
        :gsub("PROG", `<font color="#f0b9b9"><stroke color="#b85656" thickness="2">{FormatNumber.FormatCompact(plrUpgradeData.Progress)}/{plrUpgradeData.Goal}</stroke></font>`)
        Remotes.GUI.DisplayNotification:FireClient(plr, "good", notiText)
    end
end

function ComputerConfig.LevelUpComputer(plr: Player, bypassChecks: boolean)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    bypassChecks = bypassChecks or false

    -- check if plr is already on the last computer level
    if ComputerConfig.HasLastComputer(profile.Data) then return end

    -- check if plr has completed all required computer upgrades
    local allUpgradesComplete: boolean = ComputerConfig.AllAvailableComputerUpgradesCompleted(profile.Data)
    if not allUpgradesComplete and not bypassChecks then return end

    -- check if plr has required materials

    profile.Data.GameDev.Computer.Level += 1

    Remotes.GameDev.Computer.LevelUpComputer:FireClient(plr, profile.Data.GameDev.Computer.Level)
end

return ComputerConfig