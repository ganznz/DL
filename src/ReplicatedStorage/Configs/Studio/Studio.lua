local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GeneralUtils = require(ReplicatedStorage.Utils:WaitForChild("GeneralUtils"))

local Studio = {}

export type StudioConfig = {
    StudioType: "Standard" | "Premium",
    Name: string,
    Price: number,
    Currency: "Cash" | "Robux",
    FurnishingCapacity: number | nil,
    Previous: "string" | nil,
}

local Config: { [string]: StudioConfig } = {
    ["1"] = {
        StudioType = "Standard",
        Name = "Studio 1",
        Price = 0,
        Currency = "Cash",
        FurnishingCapacity = 5,
    },
    ["2"]  = {
        StudioType = "Standard",
        Name = "Studio 2",
        Price = 50000,
        Currency = "Cash",
        FurnishingCapacity = 10,
        Previous = "Studio 1"
    },
    ["3"]  = {
        StudioType = "Standard",
        Name = "Studio 3",
        Price = 250000,
        Currency = "Cash",
        FurnishingCapacity = 15,
        Previous = "Studio 2"
    },
    ["4"]  = {
        StudioType = "Standard",
        Name = "Studio 4",
        Price = 1000000,
        Currency = "Cash",
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

    if nextStudioConfig.Currency == "Cash" then
        local plrCash = plrData.Cash
        return plrCash >= nextStudioConfig.Price
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

            for i=#itemInstances, 1, -1 do
                if not furniturePlacedInStudio[furnitureCategory][furnitureItemName] then continue end
                
                local itemUUID = itemInstances[i]
                if furniturePlacedInStudio[furnitureCategory][furnitureItemName][itemUUID] then
                    table.remove(furnitureInInventoryCopy[furnitureCategory][furnitureItemName], i)
                end
            end
        end
    end

    return furnitureInInventoryCopy
end

-- StudioConfig.ItemInStudio(plrData, options.ItemName, options.ItemCategory, options.ItemUUID ,studioPlrInfo.StudioIndex, studioType)
function Studio.ItemInStudio(plrData, itemName: string, itemCategory: string, itemUUID: string, studioIndex: string, studioType: string): boolean
    local studioFurnishingData = plrData.Studio.Studios[studioType][studioIndex].Furnishings[itemCategory]

    if studioFurnishingData[itemName] then
        if studioFurnishingData[itemName][itemUUID] then
            return true
        end
    end
    
    return false
end

function Studio.GetFurnitureItemModel(itemName: string, itemCategory: string)
    return ReplicatedStorage.Assets.Models.Studio.StudioFurnishing[itemCategory]:FindFirstChild(itemName):Clone()
end

-- method for placing item on plot
function Studio.PlaceItemOnPlot(itemType: string, itemInfo: {}, parent: Folder)
    local itemModelToPlace

    if itemType == "furniture" then
        itemModelToPlace = Studio.GetFurnitureItemModel(itemInfo.ItemName, itemInfo.ItemCategory)
        itemModelToPlace.Name = itemInfo.ItemUUID
        
    elseif itemType == "essential" then
        itemModelToPlace = parent:FindFirstChild(itemInfo.ItemName):Clone()
        itemModelToPlace.Name = itemInfo.ItemName
    end

    itemModelToPlace.PrimaryPart.Transparency = 1
    itemModelToPlace:PivotTo(itemInfo.PlacementCFrame)
    itemModelToPlace.Parent = parent

    for _i, v in itemModelToPlace:GetDescendants() do
        if v:IsA("BasePart") then v.CanCollide = true end
    end
end


return Studio