local CollectionService = game:GetService("CollectionService")

local allTeleportParts = CollectionService:GetTagged("TeleportPart")

local TeleportAreas = {}

-- general areas don't need to be unlocked and are accessible to everyone.
TeleportAreas.GeneralAreas = {}

-- unlockable areas get unlocked through game progression
TeleportAreas.UnlockableAreas = {}

-- teleport CFrames
TeleportAreas.TeleportCFrames = {
    ["Exterior"] = {},
    ["Interior"] = {}
}

for _i, tpPart in allTeleportParts do
    local areaName = tpPart:GetAttribute("AreaName")
    local areaAccessibility = tpPart:GetAttribute("AreaAccessibility")
    local areaType: "Exterior" | "Interior" = tpPart:GetAttribute("AreaType")
    
    if areaAccessibility == "General" then
        table.insert(TeleportAreas.GeneralAreas, areaName)
        
    elseif areaAccessibility == "Unlockable" then
        table.insert(TeleportAreas.UnlockableAreas, areaName)
    end

    TeleportAreas.TeleportCFrames[areaType][areaName] = tpPart.CFrame
end

function TeleportAreas.HasAccess(plrData: {}, areaName: string): boolean
    local plrAreasUnlockedData = plrData.Areas

    return plrAreasUnlockedData[areaName]
end

return TeleportAreas