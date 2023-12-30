-- // this file contains methods that are dependant on gameplay code, that don't fit into a specific category // --

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlobalVariables = require(ReplicatedStorage:WaitForChild("GlobalVariables"))

local GeneralConfig = {}

function GeneralConfig.GetRarityColour(itemRarity: number): Color3 | nil
    if itemRarity == 1 then
        return GlobalVariables.Gui.Rarity1Colour
    elseif itemRarity == 2 then
        return GlobalVariables.Gui.Rarity2Colour
    elseif itemRarity == 3 then
        return GlobalVariables.Gui.Rarity3Colour
    elseif itemRarity == 4 then
        return GlobalVariables.Gui.Rarity4Colour
    elseif itemRarity == 5 then
        return GlobalVariables.Gui.Rarity5Colour
    elseif itemRarity == 6 then
        return GlobalVariables.Gui.Rarity6Colour
    elseif itemRarity == 7 then
        return GlobalVariables.Gui.Rarity7Colour
    end
end

return GeneralConfig