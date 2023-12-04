local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)

local GROUP_ID = 33054213
local GROUP_ADMIN_RANK_IDS = {255, 254} -- 255: Owner, 254: Devs
local EXTRA_ADMINS = {} -- any player you want to give admin access to that isn't a dev, put their user ID in here

local PlrManager = {}

function PlrManager.GiveAdminAccess(plr: Player)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    profile.Data.Admin = true
end

function PlrManager.IsAdminEligible(plr: Player): boolean
    -- plr has role in group w/ admin powers
    if table.find(GROUP_ADMIN_RANK_IDS, plr:GetRankInGroup(GROUP_ID)) then return true end

    -- plr is an extra admin that isn't a dev/admin in group
    if table.find(EXTRA_ADMINS, plr.UserId) then return true end

    return false
end

Players.PlayerAdded:Connect(function(plr: Player)
    if PlrManager.IsAdminEligible(plr) then
        PlrManager.GiveAdminAccess(plr)
    end
end)


task.spawn(function()
    for _i, plr: Player in Players:GetPlayers() do
        -- check for admin-privilege updates every sec
        if PlrManager.IsAdminEligible(plr) then
            PlrManager.GiveAdminAccess(plr)
        end
    end
    task.wait(1)
end)

return PlrManager