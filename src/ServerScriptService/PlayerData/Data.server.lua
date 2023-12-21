local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Template = require(ReplicatedStorage.PlayerData.Template)
local Manager = require(ServerScriptService.PlayerData.Manager)
local ProfileService = require(ServerScriptService.Libs.ProfileService)

-- datastores that I've used: Production, Development
local ProfileStore = ProfileService.GetProfileStore("Development", Template)

local KICK_MSG = "Data issue, try again."

local function CreateLeaderstats(plr: Player)
    local profile = Manager.Profiles[plr]
    if not profile then return end

    local leaderstats = Instance.new("Folder", plr)
    leaderstats.Name = "leaderstats"

    local coins = Instance.new("NumberValue", leaderstats)
    coins.Name = "Coins"
    coins.Value = profile.Data.Coins

    local fans = Instance.new("NumberValue", leaderstats)
    fans.Name = "Fans"
    fans.Value = profile.Data.Fans

    local gems = Instance.new("NumberValue", leaderstats)
    gems.Name = "Gems"
    gems.Value = profile.Data.Gems
end

local function LoadProfile(plr: Player)
    if not plr then
        plr:Kick(KICK_MSG)
        return
    end

    -- local profile = ProfileStore:LoadProfileAsync("Player_"..plr.UserId)

    local MockProfile = ProfileStore.Mock:LoadProfileAsync("Player_"..plr.UserId)

    MockProfile:AddUserId(plr.UserId)
    MockProfile:Reconcile()
    MockProfile:ListenToRelease(function()
        Manager.Profiles[plr] = nil
        plr:Kick(KICK_MSG)
    end)

    if plr:IsDescendantOf(Players) then
        Manager.Profiles[plr] = MockProfile
        CreateLeaderstats(plr)
    else
        MockProfile:Release()
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
        -- ProfileStore:WipeProfileAsync("Player_"..plr.UserId)
        ProfileStore.Mock:WipeProfileAsync("Player_"..plr.UserId)
    end
end)