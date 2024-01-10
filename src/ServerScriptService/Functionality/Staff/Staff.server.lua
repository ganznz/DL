local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local StaffMemberConfig = require(ReplicatedStorage.Configs.Staff.StaffMember)
local StaffMemberServer = require(ServerScriptService.Functionality.Staff.StaffMemberServer)

local Remotes = ReplicatedStorage.Remotes

-- intermediary function that directs remote call to server-sided instance method
local function levelUpStaffMemberSkill(plr: Player, staffMemberUUID: string, skill: "code" | "sound" | "art", amtOfLvlUps: number)
    StaffMemberServer:LevelUpSkill(plr, staffMemberUUID, skill, amtOfLvlUps)

end

Remotes.Staff.GetStaffMemberData.OnServerInvoke = function(plr: Player, staffMemberUUID: string): {} | nil
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    return profile.Data.Inventory.StaffMembers[staffMemberUUID]
end

Remotes.Staff.LevelUpSkill.OnServerEvent:Connect(levelUpStaffMemberSkill)