local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local StudioConfig = require(ReplicatedStorage.Configs.Studio.Studio)
local StudioConfigServer = require(ServerScriptService.Functionality.Staff.StaffMemberServer)

local Remotes = ReplicatedStorage.Remotes

local function adjustAllStaffMemberEnergy(plr: Player)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local staffMembersToIgnore = {}
    if plr:GetAttribute("InStudio") and plr:GetAttribute("CurrentlyDevelopingGame") then
        staffMembersToIgnore = StudioConfig.GetStaffInActiveStudio(profile.Data)
    end

    for staffMemberUUID: string, staffMemberData in profile.Data.Inventory.StaffMembers do
        if staffMembersToIgnore[staffMemberUUID] then continue end

        local staffInstance = StudioConfigServer.new(staffMemberUUID, staffMemberData)

        staffInstance:AdjustEnergy(plr, staffMemberUUID)
    end
end

-- intermediary function that directs remote call to server-sided instance method
local function levelUpStaffMemberSkill(plr: Player, staffMemberUUID: string, skill: "code" | "sound" | "art", amtOfLvlUps: number)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local instanceData = profile.Data.Inventory.StaffMembers[staffMemberUUID]
    local instance = StudioConfigServer.new(staffMemberUUID, instanceData)

    instance:LevelUpSkill(plr, staffMemberUUID, skill, amtOfLvlUps)
end

Remotes.Staff.GetStaffMemberData.OnServerInvoke = function(plr: Player, staffMemberUUID: string): {} | nil
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    return profile.Data.Inventory.StaffMembers[staffMemberUUID]
end

Remotes.Staff.LevelUpSkill.OnServerEvent:Connect(levelUpStaffMemberSkill)

while true do
    for _i, plr: Player in Players:GetPlayers() do
        adjustAllStaffMemberEnergy(plr)
    end
    task.wait(1)
end