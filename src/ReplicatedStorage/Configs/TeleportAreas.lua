local CollectionService = game:GetService("CollectionService")

local TeleportAreas = {}

-- general areas don't need to be unlocked and are accessible to everyone.
TeleportAreas.GeneralAreas = {}

-- unlockable areas get unlocked through game progression
TeleportAreas.UnlockableAreas = {}

local allTeleportParts = CollectionService:GetTagged("TeleportPart")

for _i, tpPart in allTeleportParts do
    local areaName = tpPart:GetAttribute("AreaName")
    local areaAccessibility = tpPart:GetAttribute("AreaAccessibility")
    
    if areaAccessibility == "General" then
        table.insert(TeleportAreas.GeneralAreas, areaName)
        
    elseif areaAccessibility == "Unlockable" then
        table.insert(TeleportAreas.UnlockableAreas, areaName)
    end
end

return TeleportAreas