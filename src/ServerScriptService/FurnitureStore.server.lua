local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Zone = require(ReplicatedStorage.Libs.Zone)

local Remotes = ReplicatedStorage.Remotes

local furnitureStoreExterior: Model = Workspace.Map.Buildings.FurnitureStore:WaitForChild("FurnitureStoreExterior")
local hitbox: Model = furnitureStoreExterior:WaitForChild("Hitbox")
local zone = Zone.new(hitbox)

local furnitureStoreInterior = Workspace.Map.Buildings.FurnitureStore:WaitForChild("FurnitureStoreInterior")
local furnitureStoreInteriorTeleport = furnitureStoreInterior:FindFirstChild("Teleport")


zone.playerEntered:Connect(function(plr: Player)
    Remotes.GUI.ChangeGuiStatusRemote:FireClient(plr, "loadingBgSplash", true)
end)

zone.playerExited:Connect(function(plr: Player)
    Remotes.GUI.ChangeGuiStatusRemote:FireClient(plr, "loadingBgSplash", false)
end)

Remotes.Player.TeleportPlr.OnServerEvent:Connect(function(plr, destination)
    if destination == "furnitureStore" then
        local char = plr.Character
        char:MoveTo(furnitureStoreInteriorTeleport.Position)
    end
    
end)