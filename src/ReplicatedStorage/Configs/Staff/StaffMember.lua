local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local GlobalVariables = require(ReplicatedStorage:WaitForChild("GlobalVariables"))

local Remotes = ReplicatedStorage.Remotes

local StaffMember = {}
StaffMember.__index = StaffMember

export type StaffMemberConfig = {
    Rarity: number,
    UpgradeCurrency: string,
    IconOriginal: string,
    IconStroke: string,
}

local config: { [string]: StaffMemberConfig } = {
    ["Max"] = {
        Rarity = 1,
        UpgradeCurrency = "Coins",
        IconOriginal = "15803863472",
        IconStroke = "15803865261",
    },
    ["Cam"] = {
        Rarity = 1,
        UpgradeCurrency = "Coins",
        IconOriginal = "15803860031",
        IconStroke = "15803861381",
    },
    ["Sophie"] = {
        Rarity = 1,
        UpgradeCurrency = "Coins",
        IconOriginal = "15804094588",
        IconStroke = "15804095897",
    },
    ["Logan"] = {
        Rarity = 2,
        UpgradeCurrency = "Coins",
        IconOriginal = "15803866632",
        IconStroke = "15803868605",
    },
}

StaffMember.Config = config

StaffMember.Constants = {
    -- these are the multipliers that are used when calculating how many points of a skill a staff member has
    SkillLevelMultipliers = {
        -- [rarityValue] = multiplier
        ["1"] = 1,
        ["2"] = 2,
        ["3"] = 5,
        ["4"] = 10,
        ["5"] = 20,
        ["6"] = 50,
        ["7"] = 125,
    },
    EnergyEmptyToFull = {
        -- in seconds
        -- [rarityValue] = time
        ["1"] = 150, -- 2.5 min
        ["2"] = 300, -- 5 min
        ["3"] = 540, -- 9 min
        ["4"] = 900, -- 15 min
        ["5"] = 1500, -- 25 min
        ["6"] = 2400, -- 40 min
        ["7"] = 3600, -- 60 min
    },
    EnergyPerSkillPt = 10
}

function StaffMember.GetConfig(staffModel: string): StaffMemberConfig | nil
    return StaffMember.Config[staffModel]
end

function StaffMember.GetRarityName(staffModel: string): string | nil
    local staffMemberConfig = StaffMember.GetConfig(staffModel)
    if not staffMemberConfig then return nil end

    if staffMemberConfig.Rarity == 1 then
        return "Unskilled"
    elseif staffMemberConfig.Rarity == 2 then
        return "Trainee"
    elseif staffMemberConfig.Rarity == 3 then
        return "Regular"
    elseif staffMemberConfig.Rarity == 4 then
        return "Skilled"
    elseif staffMemberConfig.Rarity == 5 then
        return "Seasoned"
    elseif staffMemberConfig.Rarity == 6 then
        return "Elite"
    elseif staffMemberConfig.Rarity == 7 then
        return "Prodigy"
    end
end

function StaffMember.GetStaffMemberModel(staffMemberName: string): Model | nil
    return ReplicatedStorage.Assets.Models.StaffMembers[staffMemberName]:Clone()
end

-- function NOT used for granting a plr new staff member, but instead used for instantiating a StaffMember object
--          using predefined staff member data that the appropriate class methods can be used on
function StaffMember.new(staffMemberUUID: string, staffMemberData: {})

    local staffMember = {}
    setmetatable(staffMember, StaffMember)

    staffMember.UUID = staffMemberUUID
    staffMember.Model = staffMemberData.Model
    staffMember.Name = staffMemberData.Name
    staffMember.Rarity = staffMemberData.Rarity
    staffMember.Specialisation = staffMemberData.Specialisation
    staffMember.CurrentEnergy = staffMemberData.CurrentEnergy
    staffMember.CodeLevel = staffMemberData.CodeLevel
    staffMember.SoundLevel = staffMemberData.SoundLevel
    staffMember.ArtistLevel = staffMemberData.ArtistLevel

    return staffMember
end

function StaffMember:GetSkillLvlMultiplier()
    return StaffMember.Constants.SkillLevelMultipliers[tostring(self.Rarity)]
end

-- returns the LEVEL (not points) of a specific skill
-- opts
-- -- MaxAffordableLevel -> boolean: When specified, calculates the skills max level that the player can currently afford
function StaffMember:GetSpecificSkillLevel(skill: "code" | "sound" | "art", opts: {}): number
    local skillLevel
    if skill == "code" then
        skillLevel = self.CodeLevel
    elseif skill == "sound" then
        skillLevel = self.SoundLevel
    elseif skill == "art" then
        skillLevel = self.ArtistLevel
    end

    -- if MaxAffordableLevel option not specified
    if not opts then return skillLevel end

    local plrData
    if RunService:IsClient() then
        plrData = Remotes.Data.GetAllData:InvokeServer()
    else
        plrData = game:GetService("ServerScriptService").PlayerData.Manager.Profiles[Players.LocalPlayer].Data
    end

    local staffMemberConfig = StaffMember.GetConfig(self.Model)
    local plrCurrencyAmt = plrData[staffMemberConfig.UpgradeCurrency]
    local totalCost = 0

    -- calculate the cost for the maximum amt of upgrades the player can afford


    while totalCost <= plrCurrencyAmt do
        local temp
        if self.Rarity == 1 then
            temp = totalCost + (10 * math.pow(1.2, skillLevel + 1))
            if temp > plrCurrencyAmt then break end
        elseif self.Rarity == 2 then
            temp = totalCost + ( 20 * math.pow(1.5, skillLevel + 1))
            if temp > plrCurrencyAmt then break end
        elseif self.Rarity == 3 then
            temp = totalCost + ( 40 * math.pow(1.7, skillLevel + 1))
            if temp > plrCurrencyAmt then break end
        end
        totalCost = temp
        skillLevel += 1
    end

    return skillLevel
end

-- opts
-- -- SpecifiedSkillLevel -> number: When specified, calculates how many skill points there'll be for that specific skill level
function StaffMember:GetSpecificSkillPoints(skill: "code" | "sound" | "art", opts: {}): number
    local skillLevel
    if opts and opts["SpecifiedSkillLevel"] then
        skillLevel = opts["SpecifiedSkillLevel"]
    else
        if skill == "code" then
            skillLevel = self.CodeLevel
        elseif skill == "sound" then
            skillLevel = self.SoundLevel
        elseif skill == "art" then
            skillLevel = self.ArtistLevel
        end
    end

    return skillLevel * StaffMember.Constants.SkillLevelMultipliers[tostring(self.Rarity)]
end

function StaffMember:GetTotalSkillPts(): number
    return self:GetSpecificSkillPoints("code") + self:GetSpecificSkillPoints("sound") + self:GetSpecificSkillPoints("art")
end


-- -- amtOfLvlUps -> number: The number of skill level-ups to perform on the staff member
function StaffMember:CalcSkillLevelUpgradeCost(skill: "code" | "sound" | "art", amtOfLvlUps: number): number
    if amtOfLvlUps and amtOfLvlUps < 1 then return end

    amtOfLvlUps = amtOfLvlUps or 1

    local skillLevel
    if skill == "code" then
        skillLevel = self.CodeLevel
    elseif skill == "sound" then
        skillLevel = self.SoundLevel
    elseif skill == "art" then
        skillLevel = self.ArtistLevel
    end

    local totalCost = 0

    for _i = 1, amtOfLvlUps, 1 do
        if self.Rarity == 1 then
            totalCost += math.round( 10 * math.pow(1.2, skillLevel + 1) )
        elseif self.Rarity == 2 then
            totalCost += math.round( 20 * math.pow(1.5, skillLevel + 1) )
        elseif self.Rarity == 3 then
            totalCost += math.round( 40 * math.pow(1.7, skillLevel + 1) )
        end
        skillLevel += 1
    end

    return totalCost
end

function StaffMember:CalcSkillUpgradeEnergyConsumption(skill: "code" | "sound" | "art", amtOfLvlUps: number): {}
    local ptsAfterUpgrade
    if skill == "code" then
        ptsAfterUpgrade = self:GetSpecificSkillPoints(skill, { SpecifiedSkillLevel = self.CodeLevel + amtOfLvlUps })
    elseif skill == "sound" then
        ptsAfterUpgrade = self:GetSpecificSkillPoints(skill, { SpecifiedSkillLevel = self.SoundLevel + amtOfLvlUps })
    elseif skill == "art" then
        ptsAfterUpgrade = self:GetSpecificSkillPoints(skill, { SpecifiedSkillLevel = self.ArtistLevel + amtOfLvlUps })
    end

    local maxEnergy = self:CalcMaxEnergy()
    local totalSkillPtsAfterUpgrade = self:GetTotalSkillPts() + (amtOfLvlUps  * StaffMember.Constants.SkillLevelMultipliers[tostring(self.Rarity)])
    local maxEnergyAfterUpgrade = self:CalcMaxEnergy({ SpecifiedSkillPts = totalSkillPtsAfterUpgrade })
    
    local energyUsedWeighting = if amtOfLvlUps >= 5 then 1 else (amtOfLvlUps / 5) -- determines energy usage based on how many level-ups are being done
    local energyUsedProportional = (ptsAfterUpgrade / totalSkillPtsAfterUpgrade) * (energyUsedWeighting) -- e.g. 0.4 (40%)
    if energyUsedProportional > 1 then energyUsedProportional = 1 end

    local canUpgrade = true
    if self.CurrentEnergy / maxEnergy < energyUsedProportional then canUpgrade = false end

    local energyUsedActual = maxEnergy * energyUsedProportional

    -- { [1]=energyUsedActual:number | nil, [2]=canUpgrade:boolean, [3]=maxEnergyAfterUpgrade:number}
    return { energyUsedActual, canUpgrade, maxEnergyAfterUpgrade}
end

-- opts
-- SpecifiedSkillPts -> number: Calculates max energy based on the amount of skill pts provided instead of instances total skill pts
function StaffMember:CalcMaxEnergy(opts: {}): number
    if opts and opts["SpecifiedSkillPts"] then
        return opts["SpecifiedSkillPts"] * StaffMember.Constants.EnergyPerSkillPt
    end

    return self:GetTotalSkillPts() * StaffMember.Constants.EnergyPerSkillPt
end

-- calculates how much of a skill point a staff member will have after training that skill
-- timesUpgraded arg is how many times the skill is being upgraded at once
function StaffMember:CalcSpecificSkillPtsAfterUpgrade(skill: "code" | "sound" | "art", timesUpgraded: number): number
    timesUpgraded = timesUpgraded or 1

    local skillLevelAfterUpgrade = self:GetSpecificSkillLevel(skill) + timesUpgraded
    local skillPtsAfterUpgrade = self:GetSpecificSkillPoints(skill, { SpecifiedSkillLevel = skillLevelAfterUpgrade })

    return skillPtsAfterUpgrade
end

-- method returns seconds until staff member energy is full
function StaffMember:CalcTimeUntilFullEnergy(): number
    local emptyToFullEnergyTime = StaffMember.Constants.EnergyEmptyToFull[tostring(self.Rarity)] -- in seconds
    return math.floor(emptyToFullEnergyTime - ((emptyToFullEnergyTime * self.CurrentEnergy) / self:CalcMaxEnergy()))
end

return StaffMember