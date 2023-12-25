local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes

-- { [userId]: { Platform: string | nil } }
local PlayersInSession = {}

local function createProfile(plr: Player)
    PlayersInSession[plr.UserId] = {
        Platform = nil
    }

    return PlayersInSession[plr.UserId]
end

local function getProfile(plr: Player)
    local plrProfile = PlayersInSession[plr.UserId]
    if not plrProfile then plrProfile = createProfile(plr) end
    
    return plrProfile
end

local function updateProfile(plr: Player, platform: "pc" | "mobile" | "console")
    local plrProfile = getProfile(plr)

    -- check if the new platform is different from the old platform first
    if plrProfile.Platform == platform then return end

    if platform == "pc" or platform == "mobile" or platform == "console" then
        plrProfile.Platform = platform

        -- fire update to client
        Remotes.Player.PlatformChanged:FireClient(plr, plrProfile)
    end
end

local function deleteProfile(plr: Player)
    PlayersInSession[plr.UserId] = nil
end

Players.PlayerAdded:Connect(function(plr: Player)
    createProfile(plr)
end)

Players.PlayerRemoving:Connect(function(plr: Player)
    deleteProfile(plr)
end)

Remotes.Player.PlatformChanged.OnServerEvent:Connect(updateProfile)

Remotes.Player.GetPlrPlatformData.OnServerInvoke = getProfile