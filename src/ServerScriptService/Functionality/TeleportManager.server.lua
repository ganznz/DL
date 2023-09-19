local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes

Remotes.Player.TeleportPlr.OnServerEvent:Connect(function(plr: Player, destination: string)
    print(destination)
    local char = plr.Character
    local destinationFolder = Workspace.Map:FindFirstChild(destination, true)
    local teleportToPart = destinationFolder:FindFirstChild("TeleportToPart", true)
    char:MoveTo(teleportToPart.Position)
    Remotes.GUI.ChangeGuiStatusRemote:FireClient(plr, "loadingBgSplash", false, nil)
end)