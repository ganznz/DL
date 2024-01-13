local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local StaffMemberConfig = require(ReplicatedStorage.Configs.Staff.StaffMember)
local StudioConfigServer = require(ServerScriptService.Functionality.Studio.StudioConfigServer)
local StudioConfig = require(ReplicatedStorage.Configs.Studio:WaitForChild("Studio"))
local DatastoreUtils = require(ReplicatedStorage.Utils.DS:WaitForChild("DatastoreUtils"))

local Remotes = ReplicatedStorage.Remotes

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

    local startingEnergy
    if staffMemberItemConfig.Rarity == 1 then
        startingEnergy = StaffMemberConfig.Constants.SkillLevelMultipliers.Rarity1 * 3 * StaffMemberConfig.Constants.EnergyPerSkillPt
    elseif staffMemberItemConfig.Rarity == 2 then
        startingEnergy = StaffMemberConfig.Constants.SkillLevelMultipliers.Rarity2 * 3 * StaffMemberConfig.Constants.EnergyPerSkillPt
    end

    local itemUUID = HttpService:GenerateGUID(false)
    local instanceData: StaffInstance = {
        Name = staffName,
        Model = staffName,
        Rarity = staffMemberItemConfig.Rarity,
        Specialisation =  SPECIALISATIONS[math.random(1, #SPECIALISATIONS)],
        CurrentEnergy = startingEnergy,
        CodeLevel = 1,
        SoundLevel = 1,
        ArtistLevel = 1,
        Locked = false
    }

    profile.Data.Inventory.StaffMembers[itemUUID] = instanceData
end

function StaffServer.OwnsStaffMember(plr: Player, staffMemberUUID: string): boolean
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local staffMemberData = profile.Data.Inventory.StaffMembers[staffMemberUUID]
    return if staffMemberData then true else false 
end

function StaffServer.DeleteStaffMember(plr: Player, itemInfo: {})
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    if not profile.Data.Inventory.StaffMembers[itemInfo.ItemUUID] then return end

    -- check if item is locked first
    local isLocked = profile.Data.Inventory.StaffMembers[itemInfo.ItemUUID].Locked
    if isLocked then return end

    -- remove item from studios
    for studioType: "Standard" | "Premium" in profile.Data.Studio.Studios do
        for studioIndex, studioData in profile.Data.Studio.Studios[studioType] do
            local staffMemberInStudio: boolean = studioData.StaffMembers[itemInfo.ItemUUID]
            
            if staffMemberInStudio then
                -- check if the item to be deleted is in this studio
                profile.Data.Studio.Studios[studioType][studioIndex].StaffMembers[itemInfo.ItemUUID] = nil
            end
        end
    end

    -- delete from plr inventory also
    profile.Data.Inventory.StaffMembers[itemInfo.ItemUUID] = nil

    -- remove item visually for all plrs in studio
    for plrUserId, studioInfo in StudioConfigServer.PlrsInStudio do
        if studioInfo then
            if studioInfo.PlrVisitingId == plr.UserId then
                local plrToUpdate: Player = Players:GetPlayerByUserId(plrUserId)
                Remotes.Studio.BuildMode.RemoveItem:FireClient(plrToUpdate, "staff", itemInfo)
            end
        end
    end
end

-- remove a staff member from studio and store back in inventory
function StaffServer.StoreStaffMember(plr: Player, itemInfo: {}, studioIndex: string)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local studioConfig = StudioConfig.GetConfig(studioIndex)
    if not studioConfig then return end

    local studioType: "Standard" | "Premium" = studioConfig.StudioType

    profile.Data.Studio.Studios[studioType][studioIndex].StaffMembers[itemInfo.ItemUUID] = nil
end

-- function for saving a placed staff members items data to plr data
function StaffServer.StoreStaffItemPlacementData(plr: Player, itemInfo: {}, studioIndex)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local studioConfig = StudioConfig.GetConfig(studioIndex)
    if not studioConfig then return end
    
    local studioType: "Standard" | "Premium" = studioConfig.StudioType

    local itemData = {}
    itemData.CFrame = DatastoreUtils.CFrameToTable(itemInfo.RelativeCFrame)

    profile.Data.Studio.Studios[studioType][studioIndex].StaffMembers[itemInfo.ItemUUID] = itemData
end

function StaffServer.UpdateStaffItemPlacementData(plr: Player, itemInfo: {}, studioIndex)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local studioConfig = StudioConfig.GetConfig(studioIndex)
    if not studioConfig then return end

    local studioType: "Standard" | "Premium" = studioConfig.StudioType

    local staffMemberInstance = profile.Data.Studio.Studios[studioType][studioIndex].StaffMembers[itemInfo.ItemUUID]
    if staffMemberInstance then
        -- update data
        profile.Data.Studio.Studios[studioType][studioIndex].StaffMembers[itemInfo.ItemUUID].CFrame = DatastoreUtils.CFrameToTable(itemInfo.RelativeCFrame)
    end
end

return StaffServer