local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GeneralUtils = require(ReplicatedStorage.Utils:WaitForChild("GeneralUtils"))
local StaffConfig = require(ReplicatedStorage.Configs.Staff:WaitForChild("StaffMember"))

local Studio = {}

export type StudioConfig = {
    StudioType: "Standard" | "Premium",
    Name: string,
    Price: number,
    Currency: "Coins" | "Robux",
    FurnishingCapacity: number | nil,
    Previous: "string" | nil,
}

local Config: { [string]: StudioConfig } = {
    ["1"] = {
        StudioType = "Standard",
        Name = "Studio 1",
        Price = 0,
        Currency = "Coins",
        FurnishingCapacity = 5,
    },
    ["2"]  = {
        StudioType = "Standard",
        Name = "Studio 2",
        Price = 50000,
        Currency = "Coins",
        FurnishingCapacity = 10,
        Previous = "Studio 1"
    },
    ["3"]  = {
        StudioType = "Standard",
        Name = "Studio 3",
        Price = 250000,
        Currency = "Coins",
        FurnishingCapacity = 15,
        Previous = "Studio 2"
    },
    ["4"]  = {
        StudioType = "Standard",
        Name = "Studio 4",
        Price = 1000000,
        Currency = "Coins",
        FurnishingCapacity = 20,
        Previous = "Studio 3"
    },

    -- gamepass studios
    ["5"] = {
        StudioType = "Premium",
        Name = "Rocket Ship",
        Price = 299, -- robux
        Currency = "Robux",
    },
    ["6"] = {
        StudioType = "Premium",
        Name = "Penthouse",
        Price = 799, -- robux
        Currency = "Robux",
    },
}

Studio.Config = Config

function Studio.GetConfig(studioIndex: string): StudioConfig
    return Studio.Config[studioIndex]
end

function Studio.GetStudioPrice(studioIndex: string): number
    return Studio.GetConfig(studioIndex).Price
end

function Studio.GetPlrStudioLevel(plrData)
    return GeneralUtils.LengthOfDict(plrData.Studio.Studios.Standard)
end

function Studio.OwnsStudio(plrData, studioIndex: string): boolean
    local numberOfStudiosOwned = GeneralUtils.LengthOfDict(plrData.Studio.Studios.Standard)
    return numberOfStudiosOwned >= tonumber(studioIndex)
end

function Studio.HasLastStudio(plrData): boolean
    local numOfStandardStudios = 0
    for _studioIndex, studioInfo in Studio.Config do
        if studioInfo.StudioType == "Standard" then numOfStandardStudios += 1 end
    end

    return GeneralUtils.LengthOfDict(plrData.Studio.Studios.Standard) == numOfStandardStudios
end

function Studio.CurrentFurnishingAmount(plrData, studioIndex: string): number
    local studioData = plrData.Studio.Studios.Standard[studioIndex]
    if not studioData then
        return 0
    else
        return GeneralUtils.LengthOfDict(studioData.Furnishings)
    end
end

function Studio.FurnishingCapacity(studioIndex: string): number
    local config = Studio.GetConfig(studioIndex)
    return config.FurnishingCapacity
end

function Studio.ReachedFurnishingCapacity(plrData, studioIndex: string): number
    local studioData = plrData.Studio.Studios.Standard[studioIndex]
    if not studioData then
        return false
    else
        return Studio.CurrentFurnishingAmount(plrData, studioIndex) >= Studio.FurnishingCapacity(studioIndex)
    end
end

function Studio.CanPurchaseNextStudio(plrData): boolean
    local currentStudioLevel = GeneralUtils.LengthOfDict(plrData.Studio.Studios.Standard)
    if Studio.HasLastStudio(plrData) then return false end

    local nextStudioConfig = Studio.GetConfig(tostring(currentStudioLevel + 1))

    if nextStudioConfig.Currency == "Coins" then
        local plrCoins = plrData.Coins
        return plrCoins >= nextStudioConfig.Price
    end

    return false
end

function Studio.GetFurnitureAvailableForStudio(plrData)
    local studioIndex = plrData.Studio.ActiveStudio
    local studioType = Studio.GetConfig(studioIndex).StudioType

    -- shallow copy to prevent changes to **actual** data
    local furnitureInInventoryCopy = GeneralUtils.ShallowCopyNested(plrData.Inventory.StudioFurnishing)
    
    local furniturePlacedInStudio = plrData.Studio.Studios[studioType][studioIndex].Furnishings

    -- remove from inventory whats already placed in studio
    for furnitureCategory, furnitureItems in furnitureInInventoryCopy do
        for furnitureItemName, itemInstances in furnitureItems do
            for uuid, _instanceData in itemInstances do
                if not furniturePlacedInStudio[furnitureCategory][furnitureItemName] then continue end

                if furniturePlacedInStudio[furnitureCategory][furnitureItemName][uuid] then
                    furnitureInInventoryCopy[furnitureCategory][furnitureItemName][uuid] = nil
                end
            end
        end
    end

    return furnitureInInventoryCopy
end

function Studio.ItemInStudio(plrData, inventoryCategory: string, studioType: string, studioIndex: string, itemInfo: {}): boolean
    if inventoryCategory == "furniture" then
        local studioFurnishingData = plrData.Studio.Studios[studioType][studioIndex].Furnishings[itemInfo.ItemCategory]

        if studioFurnishingData[itemInfo.ItemName] then
            if studioFurnishingData[itemInfo.ItemName][itemInfo.ItemUUID] then return true end
        end

        return false

    elseif inventoryCategory == "staff" then
        local studioStaffData = plrData.Studio.Studios[studioType][studioIndex].StaffMembers
        if studioStaffData[itemInfo.ItemUUID] then return true end

        return false
    end
end

function Studio.GetFurnitureItemModel(itemName: string, itemCategory: string)
    return ReplicatedStorage.Assets.Models.Studio.StudioFurnishing[itemCategory]:FindFirstChild(itemName):Clone()
end

-- method for placing item on plot
function Studio.PlaceItemOnPlot(itemType: string, itemInfo: {}, parent: Folder)
    local itemModelToPlace: Model

    if itemType == "furniture" then
        itemModelToPlace = Studio.GetFurnitureItemModel(itemInfo.ItemName, itemInfo.ItemCategory)
        itemModelToPlace.Name = itemInfo.ItemUUID
        
    elseif itemType == "essential" then
        itemModelToPlace = parent:FindFirstChild(itemInfo.ItemName):Clone()
        itemModelToPlace.Name = itemInfo.ItemName
    
    elseif itemType == "staff" then
        itemModelToPlace = StaffConfig.GetStaffMemberModel(itemInfo.ItemModel)
        itemModelToPlace.Name = itemInfo.ItemUUID
    end

    itemModelToPlace.PrimaryPart.Transparency = 1
    itemModelToPlace:PivotTo(itemInfo.PlacementCFrame)
    itemModelToPlace.Parent = parent

    for _i, v in itemModelToPlace:GetDescendants() do
        if v:GetAttribute("IgnoreCanCollide") then continue end
        if v:IsA("BasePart") then v.CanCollide = true end
    end
end

-- if special furniture item is placed in a studio, return the index of that studio, else return nil
function Studio.IndexOfSpecialFurnitureItemParent(plrData, itemName: string, itemUUID: string): string
    for _studioType, studios in plrData.Studio.Studios do
        for studioIndex, studioData in studios do
            for uuid, _itemData in studioData.Furnishings.Special[itemName] do

                if uuid == itemUUID then
                    return studioIndex
                end

            end
        end
    end

    return nil
end


return Studio