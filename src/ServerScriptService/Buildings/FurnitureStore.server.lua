local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Zone = require(ReplicatedStorage.Libs.Zone)

local Remotes = ReplicatedStorage.Remotes

local furnitureStoreFolder = Workspace.Map.Buildings.FurnitureStore
local teleportHitbox: Model = furnitureStoreFolder:FindFirstChild("TeleportHitboxZone", true)
local zone = Zone.new(teleportHitbox)

zone.playerEntered:Connect(function(plr: Player)
    local teleportToPart = furnitureStoreFolder.FurnitureStoreInterior:FindFirstChild("TeleportToPart")
    Remotes.GUI.ChangeGuiStatusRemote:FireClient(plr, "loadingBgSplash", true, { TeleportPart = teleportToPart })
end)