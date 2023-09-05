local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Template = require(ReplicatedStorage.PlayerData.Template)
local Manager = require(ServerScriptService.PlayerData.Manager)
local ProfileService = require(ServerScriptService.Libs.ProfileService)

local ProfileStore = ProfileService.GetProfileStore("Production", Template)

local KICK_MSG = "Data issue, try again."

local function CreateLeaderstats(plr: Player)
    local profile = Manager.Profiles[plr]
    if not profile then return end

    local leaderstats = Instance.new("Folder", plr)
    leaderstats.Name = "leaderstats"

    local cash = Instance.new("NumberValue", leaderstats)
    cash.Name = "💸"
    cash.Value = profile.Data.Cash

    local fans = Instance.new("NumberValue", leaderstats)
    fans.Name = "👨‍👩‍👧"
    fans.Value = profile.Data.Fans

    local gems = Instance.new("NumberValue", leaderstats)
    gems.Name = "💎"
    gems.Value = profile.Data.Gems
end

local function LoadProfile(plr: Player)
    if not plr then
        plr:Kick(KICK_MSG)
        return
    end

    local profile = ProfileStore:LoadProfileAsync("Player_"..plr.UserId)
    profile:AddUserId(plr.UserId)
    profile:Reconcile()
    profile:ListenToRelease(function()
        Manager.Profiles[plr] = nil
        plr:Kick(KICK_MSG)
    end)

    if plr:IsDescendantOf(Players) then
        Manager.Profiles[plr] = profile
        CreateLeaderstats(plr)
    else
        profile:Release()
    end
end

for _, plr in Players:GetPlayers() do
    task.spawn(LoadProfile, plr)
end

Players.PlayerAdded:Connect(LoadProfile)

Players.PlayerRemoving:Connect(function(plr)
    local profile = Manager.Profiles[plr]
    if profile then
        profile:Release()
    end
end)