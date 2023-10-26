local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local PlrPlatformManager = {}

-- { [userId]: { Platform: string | nil } }
PlrPlatformManager.PlayersInSession = {}

function PlrPlatformManager.GetProfile(plr: Player)
    local plrProfile = PlrPlatformManager.PlayersInSession[plr.UserId]
    if not plrProfile then plrProfile = PlrPlatformManager.CreateProfile(plr) end
    
    return plrProfile
end

function PlrPlatformManager.SetProfile(plr: Player, platform: "pc" | "mobile" | "console")
    local plrProfile = PlrPlatformManager.GetProfile(plr)
    if platform == "pc" or platform == "mobile" or platform == "console" then
        plrProfile.Platform = platform
    end
end

function PlrPlatformManager.CreateProfile(plr: Player)
    PlrPlatformManager.PlayersInSession[plr.UserId] = {
        Platform = nil
    }
    
    return PlrPlatformManager.PlayersInSession[plr.UserId]
end

function PlrPlatformManager.DeleteProfile(plr: Player)
    PlrPlatformManager.PlayersInSession[plr.UserId] = nil
end

return PlrPlatformManager
