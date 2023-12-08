local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local StudioConfig = require(ReplicatedStorage.Configs.Studio.Studio)
local GeneralUtils = require(ReplicatedStorage.Utils.GeneralUtils)
local DatastoreUtils = require(ReplicatedStorage.Utils.DS.DatastoreUtils)
local PlrManagerConfigServer = require(ServerScriptService.Functionality.Player.PlayerManager)

-- furniture item configs
local EnergyFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("EnergyFurniture"))
local HungerFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("HungerFurniture"))
local MoodFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("MoodFurniture"))
local DecorFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("DecorFurniture"))

local StudioPlaceables = {}

-- adminCmdExecutor parameter gets passed in ONLY when function called as a cmd.
function StudioPlaceables.PurchaseFurnitureItem(plr: Player, itemName: string, itemCategory: string, adminCmdExecutor: Player)
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
    if adminCmdExecutor and PlrManagerConfigServer.IsAdminEligible(adminCmdExecutor) then
        itemPrice = 0 -- bypass cost if function called from an admin cmd
    end

    local plrCurrencyAmt
    if itemConfig.Currency == "Cash" then
        plrCurrencyAmt = profile.Data.Cash
    end

    if plrCurrencyAmt - itemPrice < 0 then return "Cannot afford item" end

    local itemUUID = HttpService:GenerateGUID(false)

    -- plr already has instances of this item in inventory
    if profile.Data.Inventory.StudioFurnishing[itemCategory][itemName] then
        table.insert(profile.Data.Inventory.StudioFurnishing[itemCategory][itemName], itemUUID)
    else
        profile.Data.Inventory.StudioFurnishing[itemCategory][itemName] = {
            itemUUID
        }
    end

    return string.format("%s received %s - %s!", plr.Name, itemCategory, itemName)
end

-- function for checking if a player has a furniture item available
-- lookForUUID: boolean - if true, search for instance by UUID instead of item name
--                        if false, search for instance by instance name instead of UUID (e.g. for placing item in Studio)
function StudioPlaceables.HasFurnitureItem(plr: Player, itemInfo: {}, studioIndex: boolean, lookForUUID: boolean): boolean
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local plrData = profile.Data

    local studioConfig = StudioConfig.GetConfig(studioIndex)
    if not studioConfig then return end

    local itemInInventory = plrData.Inventory.StudioFurnishing[itemInfo.ItemCategory][itemInfo.ItemName]
    local itemInstanceInInventory

    if itemInInventory and not lookForUUID then return true end

    if itemInInventory and lookForUUID then
        itemInstanceInInventory = table.find(itemInInventory, itemInfo.ItemUUID)
        if itemInstanceInInventory then return true end
    end

    return false
end

-- remove a furniture item from studio and store back in inventory
function StudioPlaceables.StoreFurnitureItem(plr: Player, itemInfo: {}, studioIndex: string)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local studioConfig = StudioConfig.GetConfig(studioIndex)
    if not studioConfig then return end

    local studioType: "Standard" | "Premium" = studioConfig.StudioType

    local studioPlacedFurnitureData = profile.Data.Studio.Studios[studioType][studioIndex]
    studioPlacedFurnitureData.Furnishings[itemInfo.ItemCategory][itemInfo.ItemName][itemInfo.ItemUUID] = nil
end

function StudioPlaceables.UpdateFurnitureItemData(plr: Player, itemInfo: {}, studioIndex): string
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
function StudioPlaceables.StoreFurnitureItemData(plr: Player, itemInfo: {}, studioIndex): string
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

    for _i, itemUUID in furnitureItemInstancesInInventory do
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

-- function for saving a placed essential items (e.g. computer, shelf) data to plr data
function StudioPlaceables.StoreEssentialItemData(plr: Player, itemInfo: {}, studioIndex)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local plrData = profile.Data

    local studioConfig = StudioConfig.GetConfig(studioIndex)
    if not studioConfig then return end

    local studioType: "Standard" | "Premium" = studioConfig.StudioType

    local itemData = {}
    itemData.CFrame = DatastoreUtils.CFrameToTable(itemInfo.RelativeCFrame)

    plrData.Studio.Studios[studioType][studioIndex].StudioEssentials[itemInfo.ItemName] = itemData
end

-- function for getting the data of already placed furniture items
function StudioPlaceables.AlreadyPlacedFurnitureData(plr: Player, studioIndex)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local plrData = profile.Data

    local studioConfig = StudioConfig.GetConfig(studioIndex)
    if not studioConfig then return end

    local studioType: "Standard" | "Premium" = studioConfig.StudioType

    return plrData.Studio.Studios[studioType][studioIndex].Furnishings
end

function StudioPlaceables.DeleteSingleItem(plr: Player, itemCategory: string, itemName: string, itemUUID: string): string | nil
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local uuidToDelete = nil

    -- if plr is deleting using itemUUID, then that item is placed in one of their studios
    -- loop through studios until item is found
    for studioType: "Standard" | "Premium" in profile.Data.Studio.Studios do
        for _studioIndex, studioData in profile.Data.Studio.Studios[studioType] do
            local instancesOfItemInStudio = studioData.Furnishings[itemCategory][itemName]
            
            if instancesOfItemInStudio then
                local item = instancesOfItemInStudio[itemUUID]
                -- item to delete not placed in this studio, check next studio
                if not item then continue end

                uuidToDelete = itemUUID
                -- delete item
                instancesOfItemInStudio[itemUUID] = nil
            end
        end
    end

    -- check to ensure item WAS in studio for deletion
    if uuidToDelete then
        -- delete from plr furniture inventory also
        local itemIndex = table.find(profile.Data.Inventory.StudioFurnishing[itemCategory][itemName], itemUUID)
        table.remove(profile.Data.Inventory.StudioFurnishing[itemCategory][itemName], itemIndex)
    end
    
    return uuidToDelete
end

function StudioPlaceables.DeleteMultipleItems(plr: Player, itemsToDelete)

end

return StudioPlaceables