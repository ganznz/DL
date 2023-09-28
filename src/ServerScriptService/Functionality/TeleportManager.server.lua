local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes

Remotes.Player.TeleportPlr.OnServerEvent:Connect(function(plr: Player, teleportToPart)
    local char = plr.Character
    if teleportToPart then
        char:MoveTo(teleportToPart.Position)
        Remotes.GUI.ChangeGuiStatusRemote:FireClient(plr, "loadingBgSplash", false, nil)
    end
end)