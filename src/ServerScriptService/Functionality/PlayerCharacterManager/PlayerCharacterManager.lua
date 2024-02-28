local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local TeleportAreas = require(ReplicatedStorage.Configs.TeleportAreas)
local PlrDataManager = require(ServerScriptService.PlayerData.Manager)

local Remotes = ReplicatedStorage.Remotes

local PlrCharacterManager = {}

function PlrCharacterManager.TeleportPlr(plr: Player, teleportTo: string, areaType: "Exterior" | "Interior", bypassChecks: boolean)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local canTp: boolean = false

    if bypassChecks then canTp = true end

    -- check if teleport destination has general access (accessible to anyone, no unlocking required)
    if not canTp then
        local allGeneralAreas = TeleportAreas.GeneralAreas
        if table.find(allGeneralAreas, teleportTo) then canTp = true end
    end

    -- if the teleport destination hasn't got general access, then it is unlockable. check if plr has unlocked it
    if not canTp then
        if TeleportAreas.HasAccess(plr.Data, teleportTo) then canTp = true end
    end

    if not canTp then return end

    -- tp plr
    local char = plr.Character
    local areaTypeTeleportCFrames = TeleportAreas.TeleportCFrames[areaType]
    if not areaTypeTeleportCFrames then return end
    if not areaTypeTeleportCFrames[teleportTo] then return end

    char:MoveTo(areaTypeTeleportCFrames[teleportTo].Position)
    -- if areaType == "Exterior" then

    -- elseif areaType == "Interior" then
    --     local placementCFrame = studioInteriorPlot.CFrame:ToWorldSpace(itemOffsetCFrame)
    -- end
end

Remotes.Player.ReplicateSeatPlr.OnServerEvent:Connect(function(plrToSit: Player, CFrame: CFrame)
    for _i, v in Players:GetPlayers() do
        if v == plrToSit then continue end
        Remotes.Player.ReplicateSeatPlr:FireClient(v, plrToSit, CFrame)
    end
end)

return PlrCharacterManager