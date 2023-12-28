local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlobalVariables = require(ReplicatedStorage:WaitForChild("GlobalVariables"))

local StaffMember = {}
StaffMember.__index = StaffMember

export type StaffMemberConfig = {
    Rarity: string,
    Icon: string,
}

local config: { [string]: StaffMemberConfig } = {
    ["Max"] = {
        Rarity = "Unskilled",
        Icon = "",
    },
    ["Cam"] = {
        Rarity = "Unskilled",
        Icon = "",
    },
    ["Sophie"] = {
        Rarity = "Unskilled",
        Icon = "",
    },
    ["Logan"] = {
        Rarity = "Trainee",
        Icon = "",
    },
}

StaffMember.Config = config

function StaffMember.GetRarityColour(staffModel: string): StaffMemberConfig | nil
    local staffMemberConfig = StaffMember.Config[staffModel]
    if not staffMemberConfig then return end

    if staffMemberConfig.Rarity == "Unskilled" then
        return GlobalVariables.Gui.CommonRarityColour
    elseif staffMemberConfig.Rarity == "Trainee" then
        return GlobalVariables.Gui.UncommonRarityColour
    elseif staffMemberConfig.Rarity == "Regular" then
        return GlobalVariables.Gui.RareRarityColour
    elseif staffMemberConfig.Rarity == "Skilled" then
        return GlobalVariables.Gui.VeryRareRarityColour
    elseif staffMemberConfig.Rarity == "Seasoned" then
        return GlobalVariables.Gui.LegendaryRarityColour
    elseif staffMemberConfig.Rarity == "Elite" then
        return GlobalVariables.Gui.UltraRarityColour
    elseif staffMemberConfig.Rarity == "Prodigy" then
        return GlobalVariables.Gui.MythicalRarityColour
    end
end

-- function NOT used for granting a plr new staff member, but instead used for instantiating a StaffMember object
--          using predefined staff member data that the appropriate class methods can be used on
function StaffMember.new(uuid: string,
                        name: string,
                        rarity: "Unskilled" | "Trainee" | "Regular" | "Skilled" | "Seasoned" | "Elite" | "Prodigy",
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

    if self.Rarity == "unskilled" then
        return math.round( 10 * math.pow(1.2, skillLevel) )
    elseif self.Rarity == "trainee" then
        return math.round( 20 * math.pow(1.3, skillLevel) )
    elseif self.Rarity == "regular" then
        return math.round( 40 * math.pow(1.5, skillLevel) )
    end
end

return StaffMember