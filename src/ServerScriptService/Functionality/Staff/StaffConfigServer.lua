local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local StaffMemberConfig = require(ReplicatedStorage.Configs.Staff.StaffMember)

local StaffServer = {}


local SPECIALISATIONS = {"Code", "Sound", "Artist"}

type StaffInstance = {
    Name: string,
    Rarity: number,
    Specialisation: "Code" | "Sound" | "Artist",
    CurrentEnergy: number,
    CodeLevel: number,
    SoundLevel: number,
    ArtistLevel: number,
    Locked: boolean
}

function StaffServer.GiveStaffMember(plr: Player, staffName: string)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local staffMemberItemConfig = StaffMemberConfig.GetConfig(staffName)
    if not staffMemberItemConfig then return end

    local itemUUID = HttpService:GenerateGUID(false)
    local instanceData: StaffInstance = {
        Name = staffName,
        Model = staffName,
        Rarity = staffMemberItemConfig.Rarity,
        Specialisation =  SPECIALISATIONS[math.random(1, #SPECIALISATIONS)],
        CurrentEnergy = 99,
        CodeLevel = 1,
        SoundLevel = 1,
        ArtistLevel = 1,
        Locked = false
    }

    profile.Data.Inventory.StaffMembers[itemUUID] = instanceData
end

return StaffServer