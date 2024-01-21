local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)

local GROUP_ID = 33054213
local GROUP_ADMIN_RANK_IDS = {255, 254} -- 255: Owner, 254: Devs
local EXTRA_ADMINS = {} -- any player you want to give admin access to that isn't a dev, put their user ID in here

local PlrManager = {}

-- table holds UserId of plrs in-game
local PlrsInGame = {}

function PlrManager.HasAdminAccess(plr: Player)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    return profile.Data.Admin
end

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


-- attributes that are commonly used globally in scripts are declared here
local function characterAdded(char: Model, plr: Player)
    plr:SetAttribute("IsAlive", true)
    plr:SetAttribute("InStudio", false)
    plr:SetAttribute("InBuildMode", false)
    plr:SetAttribute("InPlaceMode", false)
    plr:SetAttribute("CurrentlyDevelopingGame", false)

    local humanoid = char:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        plr:SetAttribute("IsAlive", false)
    end)
end

Players.PlayerAdded:Connect(function(plr: Player)
    if not table.find(PlrsInGame, plr.UserId) then table.insert(PlrsInGame, plr.UserId) end

    local char = plr.Character or plr.CharacterAdded:Wait()
    characterAdded(char, plr)

    plr.CharacterAdded:Connect(function(newChar: Model)
        characterAdded(newChar, plr)
    end)
end)

for _i, plr: Player in Players:GetPlayers() do
    -- check for admin-privilege updates every sec
    if not PlrManager.HasAdminAccess(plr) and PlrManager.IsAdminEligible(plr) then
        PlrManager.GiveAdminAccess(plr)
    end
end

return PlrManager