local StaffMember = {}
StaffMember.__index = StaffMember

function StaffMember.new(uuid: string,
                        name: string,
                        rarity: "unskilled" | "trainee" | "regular" | "skilled" | "seasoned" | "elite" | "prodigy",
                        specialisation: "code" | "sound" | "modeling",
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