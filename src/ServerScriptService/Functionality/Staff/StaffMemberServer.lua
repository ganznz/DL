-- // The functionality in this file are used only for operations on StaffMember class objects // --
-- general staff member functionality (e.g. unlocking staff member, deleting staff member) in StaffServer.lua

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local StaffMember = require(ReplicatedStorage.Configs.Staff.StaffMember)

local Remotes = ReplicatedStorage.Remotes

-- function cannot be called directly from client, rather a remote connects a ServerEvent which then calls the function.
function StaffMember:LevelUpSkill(plr: Player, staffMemberUUID: string, skill: "code" | "sound" | "art", amtOfLvlUps: number)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local staffMemberData = profile.Data.Inventory.StaffMembers[staffMemberUUID]
    if not staffMemberData then return end

    local staffMemberInstance = StaffMember.new(staffMemberUUID, staffMemberData)
    local staffMemberConfig = StaffMember.GetConfig(profile.Data.Inventory.StaffMembers[staffMemberUUID].Model)

    local plrCurrencyAmt = profile.Data[staffMemberConfig.UpgradeCurrency]
    local upgradeCost = staffMemberInstance:CalcSkillLevelUpgradeCost(skill, amtOfLvlUps)
    if plrCurrencyAmt < upgradeCost then return end

    -- all checks passed, level up skill accordingly
    if skill == "code" then
        staffMemberInstance.CodeLevel += amtOfLvlUps -- update instance data
        profile.Data.Inventory.StaffMembers[staffMemberUUID].CodeLevel += amtOfLvlUps -- update database data
    
    elseif skill == "sound" then
        staffMemberInstance.SoundLevel += amtOfLvlUps
        profile.Data.Inventory.StaffMembers[staffMemberUUID].SoundLevel += amtOfLvlUps

    elseif skill == "art" then
        staffMemberInstance.ArtistLevel += amtOfLvlUps
        profile.Data.Inventory.StaffMembers[staffMemberUUID].ArtistLevel += amtOfLvlUps
    end

    if staffMemberConfig.UpgradeCurrency == "Coins" then
        PlrDataManager.AdjustPlrCoins(plr, -upgradeCost)
    end

    -- replicate changes to client
    Remotes.Staff.LevelUpSkill:FireClient(plr, staffMemberUUID, skill)
end

function StaffMember:AdjustEnergy(amt: number)
    local newAmt = self.CurrentEnergy + amt
    return newAmt
end

return StaffMember