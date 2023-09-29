local Player = {}

Player.XpPerLevel = 100

function Player.GetXp(plrData): number
    return plrData.Character.Exp
end

function Player.GetLevel(plrData): number
    return plrData.Character.Level
end

function Player.CalcLevelUpXpRequirement(plrData): number
    local plrLevel = Player.GetLevel(plrData)
    return if plrLevel == 1 then Player.XpPerLevel else Player.XpPerLevel * plrLevel
end

return Player