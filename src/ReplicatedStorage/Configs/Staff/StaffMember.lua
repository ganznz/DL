local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlobalVariables = require(ReplicatedStorage:WaitForChild("GlobalVariables"))

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

-- function NOT used for granting a plr new staff member, but instead used for instantiating a StaffMember object
--          using predefined staff member data that the appropriate class methods can be used on
function StaffMember.new(uuid: string,
                        name: string,
                        rarity: number,
                        specialisation: "Code" | "Sound" | "Modeling",
                        currentEnergy: number,
                        codeLevel: number,
                        soundLevel: number,
                        modelingLevel: number)

    local staffMember = {}
    setmetatable(staffMember, StaffMember)

    staffMember.UUID = uuid
    staffMember.Name = name
    staffMember.Rarity = rarity
    staffMember.Specialisation = specialisation
    staffMember.CurrentEnergy = currentEnergy
    staffMember.CodeLevel = codeLevel
    staffMember.SoundLevel = soundLevel
    staffMember.ModelingLevel = modelingLevel

    return staffMember

end

function StaffMember:CalcSkillLevelCost(skill: "code" | "sound" | "modeling"): number
    local skillLevel
    if skill == "code" then
        skillLevel = self.CodeLevel
    elseif skill == "sound" then
        skillLevel = self.SoundLevel
    elseif skill == "modeling" then
        skillLevel = self.ModelingLevel
    end

    if self.Rarity == 1 then
        return math.round( 10 * math.pow(1.2, skillLevel) )
    elseif self.Rarity == 2 then
        return math.round( 20 * math.pow(1.3, skillLevel) )
    elseif self.Rarity == 3 then
        return math.round( 40 * math.pow(1.5, skillLevel) )
    end
end

return StaffMember