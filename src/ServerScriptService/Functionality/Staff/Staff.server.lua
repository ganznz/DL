local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)

local Remotes = ReplicatedStorage.Remotes

Remotes.Staff.GetStaffMemberData.OnServerInvoke = function(plr: Player, staffMemberUUID: string): {} | nil
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    return profile.Data.Inventory.StaffMembers[staffMemberUUID]
end