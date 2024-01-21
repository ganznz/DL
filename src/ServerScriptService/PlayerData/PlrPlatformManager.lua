local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes

local PlrPlatformManager = {}

-- { [userId]: { Platform: string | nil } }
PlrPlatformManager.PlayersInSession = {}

function PlrPlatformManager.CreateProfile(plr: Player)
    PlrPlatformManager.PlayersInSession[plr.UserId] = {
        Platform = nil
    }

    return PlrPlatformManager.PlayersInSession[plr.UserId]
end

function PlrPlatformManager.GetProfile(plr: Player)
    local plrProfile = PlrPlatformManager.PlayersInSession[plr.UserId]
    if not plrProfile then plrProfile = PlrPlatformManager.CreateProfile(plr) end
    
    return plrProfile
end

function PlrPlatformManager.UpdateProfile(plr: Player, platform: "pc" | "mobile" | "console")
    local plrProfile = PlrPlatformManager.GetProfile(plr)

    -- check if the new platform is different from the old platform first
    if plrProfile.Platform == platform then return end

    if platform == "pc" or platform == "mobile" or platform == "console" then
        plrProfile.Platform = platform

        -- fire update to client
        Remotes.Player.PlatformChanged:FireClient(plr, plrProfile)
    end
end

function PlrPlatformManager.DeleteProfile(plr: Player)
    PlrPlatformManager.PlayersInSession[plr.UserId] = nil
end

Players.PlayerAdded:Connect(function(plr: Player)
    PlrPlatformManager.CreateProfile(plr)
end)

Players.PlayerRemoving:Connect(function(plr: Player)
    PlrPlatformManager.DeleteProfile(plr)
end)

Remotes.Player.PlatformChanged.OnServerEvent:Connect(PlrPlatformManager.UpdateProfile)

Remotes.Player.GetPlrPlatformData.OnServerInvoke = PlrPlatformManager.GetProfile

return PlrPlatformManager