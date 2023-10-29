local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local StudioConfig = require(ReplicatedStorage.Configs.Studio)
local GeneralUtils = require(ReplicatedStorage.Utils:WaitForChild("GeneralUtils"))

local Remotes = ReplicatedStorage.Remotes

local Studio = {}

function Studio.PurchaseNextStudio(plr: Player): boolean
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local plrData = profile.Data

    local currentPlrStudioLevel = StudioConfig.GetPlrStudioLevel(plrData)

    -- check if plr already has every studio unlocked
    -- if StudioConfig.HasLastStudio(plrData) then return "You already own every studio!" end
    if StudioConfig.HasLastStudio(plrData) then return false end

    local nextPlrStudioLevel = currentPlrStudioLevel + 1
    local nextStudioConfig = StudioConfig.GetConfig(nextPlrStudioLevel)

    -- attempt to purchase studio
    local plrCash = plrData.Cash
    local studioUpgradePrice = nextStudioConfig.Price

    local canAfford = StudioConfig.CanPurchaseNextStudio(plrData)
    -- if not canAfford then return "You need " .. tostring(studioUpgradePrice - plrCash) .. " more cash!" end
    if not canAfford then return false end

    -- can afford, purchase studio
    PlrDataManager.AdjustPlrCash(plr, -studioUpgradePrice)
    profile.Data.Studio.ActiveStudio = nextPlrStudioLevel
    PlrDataManager.UnlockArea(plr, 'Studio'..tostring(nextPlrStudioLevel))

    -- insert new studio information into plr data
    table.insert(profile.Data.Studio.Studios, {
        Furnishings = {
            Mood = {},
            Energy = {},
            Hunger = {},
            Decor = {},
        }
    })

    Remotes.Purchase.PurchaseStudio:FireClient(plr, nextPlrStudioLevel)

    -- return "Purchased " .. nextStudioConfig.Name .. "!"
    return true
end

function Studio.HasItem(plr: Player, itemName: string, itemCategory: string, studioIndex): boolean
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local plrData = profile.Data

    local itemInInventory = plrData.Inventory.StudioFurnishing[itemCategory][itemName]
    if itemInInventory then
        if not plrData.Studio.Studios[studioIndex] then return false end

        local itemPlacedInStudio = plrData.Studio.Studios[studioIndex].Furnishings[itemCategory][itemName]
        if not itemPlacedInStudio then
            return true
        else
            local difference = GeneralUtils.LengthOfDict(itemInInventory) - GeneralUtils.LengthOfDict(itemPlacedInStudio)
            if difference > 0 then return true else return false end
        end
    end
    return false
end

function Studio.UpdateFurnitureItemData(plr: Player, itemName: string, itemUUID: string, itemCFrame: CFrame, itemCategory: string, studioIndex): string
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local plrData = profile.Data

    local furnitureItemInstance = plrData.Studio.Studios[studioIndex].Furnishings[itemCategory][itemName][itemUUID]
    if furnitureItemInstance then
        -- update data
        plrData.Studio.Studios[studioIndex].Furnishings[itemCategory][itemName][itemUUID].CFrame = itemCFrame
    end
end

-- function for saving a placed furniture items data to plr data
function Studio.StoreFurnitureItemData(plr: Player, itemName: string, itemCFrame: CFrame, itemCategory: string, studioIndex): string
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local plrData = profile.Data

    local furnitureItemInstancesInInventory = plrData.Inventory.StudioFurnishing[itemCategory][itemName]
    local furnitureItemInstancesInStudio = plrData.Studio.Studios[studioIndex].Furnishings[itemCategory][itemName]

    local itemData = {}
    itemData.CFrame = itemCFrame

    for _i, itemUUID in furnitureItemInstancesInInventory do
        -- check if there aren't any instances of this item already placed in studio
        -- if not, use current UUID in iteration to store in data
        if not furnitureItemInstancesInStudio then
            plrData.Studio.Studios[studioIndex].Furnishings[itemCategory][itemName] = {}
            plrData.Studio.Studios[studioIndex].Furnishings[itemCategory][itemName][itemUUID] = itemData
            return itemUUID
        end

        if furnitureItemInstancesInStudio[itemUUID] then continue end

        -- found UUID that is not yet stored inside studio placed furniture data
        -- store this UUID with the item data
        plrData.Studio.Studios[studioIndex].Furnishings[itemCategory][itemName][itemUUID] = itemData
        return itemUUID
    end
end

-- function for getting the data of already placed furniture items
function Studio.AlreadyPlacedFurnitureData(plr: Player, studioIndex)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local plrData = profile.Data

    return plrData.Studio.Studios[studioIndex].Furnishings
end

return Studio