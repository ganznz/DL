local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local GlobalVariables = require(ReplicatedStorage:WaitForChild("GlobalVariables"))

local Remotes = ReplicatedStorage.Remotes

local StaffMember = {}
StaffMember.__index = StaffMember

export type StaffMemberConfig = {
    Rarity: number,
    IconOriginal: string,
    IconStroke: string,
}

local config: { [string]: StaffMemberConfig } = {
    ["Max"] = {
        Rarity = 1,
        IconOriginal = "15803863472",
        IconStroke = "15803865261",
    },
    ["Cam"] = {
        Rarity = 1,
        IconOriginal = "15803860031",
        IconStroke = "15803861381",
    },
    ["Sophie"] = {
        Rarity = 1,
        IconOriginal = "15804094588",
        IconStroke = "15804095897",
    },
    ["Logan"] = {
        Rarity = 2,
        IconOriginal = "15803866632",
        IconStroke = "15803868605",
    },
}

StaffMember.Config = config

StaffMember.Constants = {
    -- these are the multipliers that are used when calculating how many points of a skill a staff member has
    SkillLevelMultipliers = {
        Rarity1 = 1,
        Rarity2 = 2,
        Rarity3 = 5,
        Rarity4 = 10,
        Rarity5 = 20,
        Rarity6 = 50,
        Rarity7 = 125,
    }
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

-- returns the LEVEL (not points) of a specific skill
-- opts
-- -- MaxAffordableLevel -> boolean: When specified, calculates how the skills max level that the player can currently afford
function StaffMember:GetSpecificSkillLevel(skill: "code" | "sound" | "art", opts: {}): number
    local skillLevel
    if skill == "code" then
        skillLevel = self.CodeLevel
    elseif skill == "sound" then
        skillLevel = self.SoundLevel
    elseif skill == "artist" then
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

    local plrCoins = plrData.Coins
    local totalCost = 0

    -- calculate the cost for the maximum amt of upgrades the player can afford

    while totalCost <= plrCoins do
        if self.Rarity == 1 then
            totalCost += math.round( 10 * math.pow(1.2, skillLevel) )
        elseif self.Rarity == 2 then
            totalCost += math.round( 20 * math.pow(1.3, skillLevel) )
        elseif self.Rarity == 3 then
            totalCost += math.round( 40 * math.pow(1.5, skillLevel) )
        end
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

    if self.Rarity == 1 then
        return skillLevel * StaffMember.Constants.SkillLevelMultipliers.Rarity2
    elseif self.Rarity == 2 then
        return skillLevel * StaffMember.Constants.SkillLevelMultipliers.Rarity2
    elseif self.Rarity == 3 then
        return skillLevel * StaffMember.Constants.SkillLevelMultipliers.Rarity3
    elseif self.Rarity == 4 then
        return skillLevel * StaffMember.Constants.SkillLevelMultipliers.Rarity4
    elseif self.Rarity == 5 then
        return skillLevel * StaffMember.Constants.SkillLevelMultipliers.Rarity5
    elseif self.Rarity == 6 then
        return skillLevel * StaffMember.Constants.SkillLevelMultipliers.Rarity6
    elseif self.Rarity == 7 then
        return skillLevel * StaffMember.Constants.SkillLevelMultipliers.Rarity7
    end

    return 0
end

function StaffMember:GetTotalSkillPts(): number
    return self:GetSpecificSkillPoints("code") + self:GetSpecificSkillPoints("sound") + self:GetSpecificSkillPoints("art")
end

-- opts
-- -- AmountOfUpgrades -> number: Calculates the total cost across the amount of upgrades specified
function StaffMember:CalcSkillLevelUpgradeCost(skill: "code" | "sound" | "artist", opts: {}): number
    local amtOfUpgrades
    if opts and opts["AmountOfUpgrades"] then amtOfUpgrades = opts["AmountOfUpgrades"] else amtOfUpgrades = 1 end
    if amtOfUpgrades < -1 or amtOfUpgrades < 0 then return 0 end

    local plrData
    if RunService:IsClient() then
        plrData = Remotes.Data.GetAllData:InvokeServer()
    else
        plrData = game:GetService("ServerScriptService").PlayerData.Manager.Profiles[Players.LocalPlayer].Data
    end

    local skillLevel
    if skill == "code" then
        skillLevel = self.CodeLevel
    elseif skill == "sound" then
        skillLevel = self.SoundLevel
    elseif skill == "artist" then
        skillLevel = self.ArtistLevel
    end

    local plrCoins = plrData.Coins
    local totalCost = 0

    for _i = 1, amtOfUpgrades, 1 do
        if self.Rarity == 1 then
            totalCost += math.round( 10 * math.pow(1.2, skillLevel) )
        elseif self.Rarity == 2 then
            totalCost += math.round( 20 * math.pow(1.3, skillLevel) )
        elseif self.Rarity == 3 then
            totalCost += math.round( 40 * math.pow(1.5, skillLevel) )
        end
        skillLevel += 1
    end

    -- calculate the cost for the maximum amt of upgrades the player can afford
    -- if amtOfUpgrades == -1 then
    --     while totalCost <= plrCoins do
    --         if self.Rarity == 1 then
    --             totalCost += math.round( 10 * math.pow(1.2, skillLevel) )
    --         elseif self.Rarity == 2 then
    --             totalCost += math.round( 20 * math.pow(1.3, skillLevel) )
    --         elseif self.Rarity == 3 then
    --             totalCost += math.round( 40 * math.pow(1.5, skillLevel) )
    --         end
    --         skillLevel += 1
    --     end

    -- -- calculate the cost for the amount of upgrades specified
    -- else
    --     for _i = 1, amtOfUpgrades, 1 do
    --         if self.Rarity == 1 then
    --             totalCost += math.round( 10 * math.pow(1.2, skillLevel) )
    --         elseif self.Rarity == 2 then
    --             totalCost += math.round( 20 * math.pow(1.3, skillLevel) )
    --         elseif self.Rarity == 3 then
    --             totalCost += math.round( 40 * math.pow(1.5, skillLevel) )
    --         end
    --         skillLevel += 1
    --     end
    -- end

    return totalCost
end

function StaffMember:CalcMaxEnergy(): number
    return 99
end

-- calculates how much of a skill point a staff member will have after training that skill
-- timesUpgraded arg is how many times the skill is being upgraded at once
function StaffMember:CalcSpecificSkillPtsAfterUpgrade(skill: "code" | "sound" | "art", timesUpgraded: number): number
    timesUpgraded = timesUpgraded or 1

    local skillLevelAfterUpgrade = self:GetSpecificSkillLevel(skill) + timesUpgraded
    local skillPtsAfterUpgrade = self:GetSpecificSkillPoints(skill, { SpecifiedSkillLevel = skillLevelAfterUpgrade })
end

-- method returns seconds until staff member energy is full
function StaffMember:CalcTimeUntilFullEnergy(): number
    return 99
end

return StaffMember