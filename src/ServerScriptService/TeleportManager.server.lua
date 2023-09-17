local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Zone = require(ReplicatedStorage.Libs.Zone)

local Remotes = ReplicatedStorage.Remotes

local accessibleAreas = CollectionService:GetTagged("AccessibleAreas")
for _i, areaFolder in accessibleAreas do
    local teleportHitbox: Model = areaFolder:FindFirstChild("TeleportHitboxZone", true)
    if not teleportHitbox then continue end
    local zone = Zone.new(teleportHitbox)

    zone.playerEntered:Connect(function(plr: Player)
        Remotes.GUI.ChangeGuiStatusRemote:FireClient(plr, "loadingBgSplash", true, areaFolder)
    end)

    zone.playerExited:Connect(function(plr: Player)
        Remotes.GUI.ChangeGuiStatusRemote:FireClient(plr, "loadingBgSplash", false, nil)
    end)

end

Remotes.Player.TeleportPlr.OnServerEvent:Connect(function(plr, areaFolder)
    if not table.find(accessibleAreas, areaFolder) then return end -- exploiter might send invalid area folder

    local teleportToPart = areaFolder:FindFirstChild("TeleportToPart", true)
    local char = plr.Character
    char:MoveTo(teleportToPart.Position)
end)