-- // The functionality in this file are used only for operations on StaffMember class objects // --
-- general staff member functionality (e.g. unlocking staff member, deleting staff member) in StaffServer.lua

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local StaffMember = require(ReplicatedStorage.Configs.Staff.StaffMember)

local Remotes = ReplicatedStorage.Remotes

function StaffMember:AdjustEnergy(plr: Player, staffMemberUUID: string, amtToAdjustBy: number): number
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local staffMemberData = profile.Data.Inventory.StaffMembers[staffMemberUUID]
    if not staffMemberData then return end

    local instanceMaxEnergy = self:CalcMaxEnergy()

    if amtToAdjustBy and amtToAdjustBy > 0 and (staffMemberData.CurrentEnergy >= instanceMaxEnergy) then return end

    -- if amtToAdjustBy isn't specified, then this function is being called to regenerate staff member energy automatically
    if not amtToAdjustBy then
        if self.Rarity == 1 then
            amtToAdjustBy = instanceMaxEnergy / 150 -- (from 0 energy, 2.5 min until full)
        elseif self.Rarity == 2 then
            amtToAdjustBy = instanceMaxEnergy / 300 -- (from 0 energy, 5 min until full)
        end
    end

    if staffMemberData.CurrentEnergy + amtToAdjustBy > instanceMaxEnergy then
        staffMemberData.CurrentEnergy = instanceMaxEnergy
    else
        staffMemberData.CurrentEnergy += amtToAdjustBy
    end

    local updatedInstance = StaffMember.new(staffMemberUUID, staffMemberData)
    local secondsUntilFull = updatedInstance:CalcTimeUntilFullEnergy()

    Remotes.Staff.AdjustEnergy:FireClient(plr, staffMemberUUID, staffMemberData)
    Remotes.Staff.UpdateEnergyFullTimer:FireClient(plr, staffMemberUUID, secondsUntilFull)
end

-- function cannot be called directly from client, rather a remote connects a ServerEvent which then calls the function.
function StaffMember:LevelUpSkill(plr: Player, staffMemberUUID: string, skill: "code" | "sound" | "art", amtOfLvlUps: number)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local staffMemberData = profile.Data.Inventory.StaffMembers[staffMemberUUID]
    if not staffMemberData then return end

    local staffMemberConfig = StaffMember.GetConfig(self.Model)

    local plrCurrencyAmt = profile.Data[staffMemberConfig.UpgradeCurrency]
    local upgradeCost = self:CalcSkillLevelUpgradeCost(skill, amtOfLvlUps)

    if plrCurrencyAmt < upgradeCost then return end

    -- check if staff member has enough energy for level up
    local energyUsed, canUpgrade, maxEnergyAfterUpgrade = unpack(self:CalcSkillUpgradeEnergyConsumption(skill, amtOfLvlUps))
    if not canUpgrade then return end

    staffMemberData.CurrentEnergy = (staffMemberData.CurrentEnergy / self:CalcMaxEnergy()) * maxEnergyAfterUpgrade
    
    -- all checks passed, level up skill
    if skill == "code" then
        self.CodeLevel += amtOfLvlUps -- update instance data
        staffMemberData.CodeLevel += amtOfLvlUps -- update database data
        
    elseif skill == "sound" then
        self.SoundLevel += amtOfLvlUps
        staffMemberData.SoundLevel += amtOfLvlUps
            
    elseif skill == "art" then
        self.ArtistLevel += amtOfLvlUps
        staffMemberData.ArtistLevel += amtOfLvlUps
    end
    
    if staffMemberConfig.UpgradeCurrency == "Coins" then
        PlrDataManager.AdjustPlrCoins(plr, -upgradeCost)
    end

    self:AdjustEnergy(plr, staffMemberUUID, -energyUsed)

    -- replicate changes to client
    Remotes.Staff.LevelUpSkill:FireClient(plr, staffMemberUUID, skill, amtOfLvlUps)
end


return StaffMember