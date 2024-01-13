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

    Remotes.Staff.AdjustEnergy:FireClient(plr, staffMemberUUID, staffMemberData)
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

    local ptsAfterUpgrade
    if skill == "code" then
        ptsAfterUpgrade = self:GetSpecificSkillPoints(skill, { SpecifiedSkillLevel = self.CodeLevel + amtOfLvlUps })
    elseif skill == "sound" then
        ptsAfterUpgrade = self:GetSpecificSkillPoints(skill, { SpecifiedSkillLevel = self.SoundLevel + amtOfLvlUps })
    elseif skill == "art" then
        ptsAfterUpgrade = self:GetSpecificSkillPoints(skill, { SpecifiedSkillLevel = self.ArtistLevel + amtOfLvlUps })
    end

    if plrCurrencyAmt < upgradeCost then return end

    -- check if staff member has enough energy for level up
    -- level up energy formula --> (currEnergy / maxEnergy) * (skillPtsAfterUpgrade / totalPtsAfterUpgrade)
    local maxEnergy = self:CalcMaxEnergy()
    local energyUsedWeighting = if amtOfLvlUps >= 5 then 2 else (amtOfLvlUps / 2.5) -- determines energy usage based on how many level-ups are being done
    local energyUsedProportional = (ptsAfterUpgrade / (self:GetTotalSkillPts() + ptsAfterUpgrade)) * (energyUsedWeighting) -- e.g. 0.4 (40%)
    if energyUsedProportional > 1 then energyUsedProportional = 1 end
    if self.CurrentEnergy / maxEnergy < energyUsedProportional then return end
    
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
            
    local newMaxEnergy = self:CalcMaxEnergy()
    staffMemberData.CurrentEnergy = (staffMemberData.CurrentEnergy / maxEnergy) * newMaxEnergy

    local energyUsedActual = newMaxEnergy * energyUsedProportional
    self:AdjustEnergy(plr, staffMemberUUID, -energyUsedActual)

    -- replicate changes to client
    Remotes.Staff.LevelUpSkill:FireClient(plr, staffMemberUUID, skill, amtOfLvlUps)
end


return StaffMember