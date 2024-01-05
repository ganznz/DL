local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local StudioConfigServer = require(ServerScriptService.Functionality.Studio.StudioConfigServer)
local StudioConfig = require(ReplicatedStorage.Configs.Studio.Studio)
local DatastoreUtils = require(ReplicatedStorage.Utils.DS.DatastoreUtils)
local PlrManagerConfigServer = require(ServerScriptService.Functionality.Player.PlayerManager)

-- furniture item configs
local EnergyFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("EnergyFurniture"))
local HungerFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("HungerFurniture"))
local MoodFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("MoodFurniture"))
local DecorFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("DecorFurniture"))

local Remotes = ReplicatedStorage.Remotes

local FurnitureConfig = {}

type FurnitureInstance = {
    Locked: boolean
}

-- adminCmdExecutor parameter gets passed in ONLY when function called as a cmd.
function FurnitureConfig.PurchaseFurnitureItem(plr: Player, itemName: string, itemCategory: string, adminCmdExecutor: Player)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local itemConfig
    if itemCategory == "Energy" then
        itemConfig = EnergyFurnitureConfig.GetConfig(itemName)
    elseif itemCategory == "Hunger" then
        itemConfig = HungerFurnitureConfig.GetConfig(itemName)
    elseif itemCategory == "Mood" then
        itemConfig = MoodFurnitureConfig.GetConfig(itemName)
    elseif itemCategory == "Decor" then
        itemConfig = DecorFurnitureConfig.GetConfig(itemName)
    end

    if not itemConfig then return end

    local itemPrice = itemConfig.Price
    if adminCmdExecutor and PlrManagerConfigServer.IsAdminEligible(adminCmdExecutor) and Players:GetPlayerByUserId(adminCmdExecutor.UserId) then
        itemPrice = 0 -- bypass cost if function called from an admin cmd
    end

    local plrCurrencyAmt = profile.Data[itemConfig.Currency]
    if plrCurrencyAmt - itemPrice < 0 then return "Cannot afford item" end

    -- all checks passed, purchase item
    local itemUUID = HttpService:GenerateGUID(false)
    profile.Data[itemConfig.Currency] -= itemPrice

    local instanceData: FurnitureInstance = {
        Locked = false
    }

    -- plr already has instances of this item in inventory
    if profile.Data.Inventory.StudioFurnishing[itemCategory][itemName] then
        profile.Data.Inventory.StudioFurnishing[itemCategory][itemName][itemUUID] = instanceData
    else
        profile.Data.Inventory.StudioFurnishing[itemCategory][itemName] = {
            [itemUUID] = instanceData
        }
    end

    return string.format("%s received %s - %s!", plr.Name, itemCategory, itemName)
end

-- function for checking if a player has a furniture item available
-- lookForUUID: boolean - if true, search for instance by UUID instead of item name
--                        if false, search for instance by instance name instead of UUID (e.g. for placing item in Studio)
function FurnitureConfig.HasFurnitureItem(plr: Player, itemInfo: {}, studioIndex: boolean, lookForUUID: boolean): boolean
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local plrData = profile.Data

    local studioConfig = StudioConfig.GetConfig(studioIndex)
    if not studioConfig then return end

    local itemInInventory = plrData.Inventory.StudioFurnishing[itemInfo.ItemCategory][itemInfo.ItemName]
    local itemInstanceInInventory

    if itemInInventory and not lookForUUID then return true end

    if itemInInventory and lookForUUID then
        itemInstanceInInventory = itemInInventory[itemInfo.ItemUUID]
        if itemInstanceInInventory then return true end
    end

    return false
end

-- remove a furniture item from studio and store back in inventory
function FurnitureConfig.StoreFurnitureItem(plr: Player, itemInfo: {}, studioIndex: string)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local studioConfig = StudioConfig.GetConfig(studioIndex)
    if not studioConfig then return end

    local studioType: "Standard" | "Premium" = studioConfig.StudioType

    local studioPlacedFurnitureData = profile.Data.Studio.Studios[studioType][studioIndex]
    studioPlacedFurnitureData.Furnishings[itemInfo.ItemCategory][itemInfo.ItemName][itemInfo.ItemUUID] = nil
end

function FurnitureConfig.UpdateFurnitureItemData(plr: Player, itemInfo: {}, studioIndex): string
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local plrData = profile.Data

    local studioConfig = StudioConfig.GetConfig(studioIndex)
    if not studioConfig then return end

    local studioType: "Standard" | "Premium" = studioConfig.StudioType

    local furnitureItemInstance = plrData.Studio.Studios[studioType][studioIndex].Furnishings[itemInfo.ItemCategory][itemInfo.ItemName][itemInfo.ItemUUID]
    if furnitureItemInstance then
        -- update data
        plrData.Studio.Studios[studioType][studioIndex].Furnishings[itemInfo.ItemCategory][itemInfo.ItemName][itemInfo.ItemUUID].CFrame = DatastoreUtils.CFrameToTable(itemInfo.RelativeCFrame)
    end
end

-- function for saving a placed furniture items data to plr data
function FurnitureConfig.StoreFurnitureItemData(plr: Player, itemInfo: {}, studioIndex): string
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local plrData = profile.Data

    local studioConfig = StudioConfig.GetConfig(studioIndex)
    if not studioConfig then return end

    local studioType: "Standard" | "Premium" = studioConfig.StudioType

    local furnitureItemInstancesInInventory = plrData.Inventory.StudioFurnishing[itemInfo.ItemCategory][itemInfo.ItemName]
    local furnitureItemInstancesInStudio = plrData.Studio.Studios[studioType][studioIndex].Furnishings[itemInfo.ItemCategory][itemInfo.ItemName]

    local itemData = {}
    itemData.CFrame = DatastoreUtils.CFrameToTable(itemInfo.RelativeCFrame)

    for itemUUID, _instanceData in furnitureItemInstancesInInventory do
        -- check if there aren't any instances of this item already placed in studio
        -- if not, use current UUID in iteration to store in data
        if not furnitureItemInstancesInStudio then
            plrData.Studio.Studios[studioType][studioIndex].Furnishings[itemInfo.ItemCategory][itemInfo.ItemName] = {}
            plrData.Studio.Studios[studioType][studioIndex].Furnishings[itemInfo.ItemCategory][itemInfo.ItemName][itemUUID] = itemData
            return itemUUID
        end

        if furnitureItemInstancesInStudio[itemUUID] then continue end

        -- found UUID that is not yet stored inside studio placed furniture data
        -- store this UUID with the item data
        plrData.Studio.Studios[studioType][studioIndex].Furnishings[itemInfo.ItemCategory][itemInfo.ItemName][itemUUID] = itemData
        return itemUUID
    end
end

-- function for getting the data of already placed furniture items
function FurnitureConfig.AlreadyPlacedFurnitureData(plr: Player, studioIndex)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local plrData = profile.Data

    local studioConfig = StudioConfig.GetConfig(studioIndex)
    if not studioConfig then return end

    local studioType: "Standard" | "Premium" = studioConfig.StudioType

    return plrData.Studio.Studios[studioType][studioIndex].Furnishings
end

-- -> boolean : indicates whether item got deleted or not
function FurnitureConfig.DeleteFurnitureItem(plr: Player, itemInfo: {}): boolean
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local isLocked = true
    -- check if item is locked first
    local succ, err = pcall(function()
        local instanceData = profile.Data.Inventory.StudioFurnishing[itemInfo.ItemCategory][itemInfo.ItemName][itemInfo.ItemUUID]
        isLocked = instanceData.Locked
    end)
    if isLocked then return end

    -- remove item from studios
    for studioType: "Standard" | "Premium" in profile.Data.Studio.Studios do
        for _studioIndex, studioData in profile.Data.Studio.Studios[studioType] do
            local instancesOfItemInStudio = studioData.Furnishings[itemInfo.ItemCategory][itemInfo.ItemName]
            
            if instancesOfItemInStudio then
                -- check if the item to be deleted is in this studio
                local itemInStudio = instancesOfItemInStudio[itemInfo.ItemUUID]
                if not itemInStudio then continue end

                instancesOfItemInStudio[itemInfo.ItemUUID] = nil
            end
        end
    end

    -- delete from plr furniture inventory also
    profile.Data.Inventory.StudioFurnishing[itemInfo.ItemCategory][itemInfo.ItemName][itemInfo.ItemUUID] = nil

    -- remove item visually for all plrs in studio
    for plrUserId, studioInfo in StudioConfigServer.PlrsInStudio do
        if studioInfo then
            if studioInfo.PlrVisitingId == plr.UserId then
                local plrToUpdate: Player = Players:GetPlayerByUserId(plrUserId)
                Remotes.Studio.BuildMode.RemoveItem:FireClient(plrToUpdate, "furniture", itemInfo)
            end
        end
    end
end

return FurnitureConfig