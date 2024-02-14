local Player = {}

Player.XpPerLevel = 100

function Player.CalcMaxNeed(plrData): number
    return 10 * math.pow(2, plrData.Character.Level - 1)
end

function Player.CalcLevelUpXpRequirement(plrData): number
    local plrLevel = plrData.Character.Level

    return 10 * math.pow(1.35, plrLevel + 1)
end


return Player