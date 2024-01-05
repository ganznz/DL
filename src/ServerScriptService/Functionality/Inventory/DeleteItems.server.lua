local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local FurnitureConfigServer = require(ServerScriptService.Functionality.Furniture.FurnitureConfigServer)
local StaffConfigServer = require(ServerScriptService.Functionality.Staff.StaffConfigServer)
local StaffFoodConfigServer = require(ServerScriptService.Functionality.Staff.StaffFoodConfigServer)
local MaterialsConfigServer = require(ServerScriptService.Functionality.Materials.MaterialsConfigServer)

local Remotes = ReplicatedStorage.Remotes

-- items, staff, furniture
local function deleteStudioItems(plr: Player, itemType: string, itemsToDelete)
    if itemType == "furniture" then
        for category, itemsInCategory in itemsToDelete do
            for itemName, itemInstances in itemsInCategory do
                for _i, itemUUID in itemInstances do
                    local itemInfo = {ItemCategory = category, ItemName = itemName, ItemUUID = itemUUID}
                    FurnitureConfigServer.DeleteFurnitureItem(plr, itemInfo)
                end
            end
        end

    elseif itemType == "staff" then
        for _i, itemUUID in itemsToDelete do
            StaffConfigServer.DeleteStaffMember(plr, { ItemUUID = itemUUID })
        end
    
    elseif itemType == "items" then
        for itemCategory, itemNames in itemsToDelete do
            for itemName, itemInfo in itemNames do
                if itemInfo.Amount <= 0 then continue end
                
                if itemCategory == "Staff Food" then
                    StaffFoodConfigServer.DeleteFood(plr, itemName, itemInfo.Amount)

                elseif itemCategory == "Material" then
                   MaterialsConfigServer.DeleteMaterial(plr, itemName, itemInfo.Amount)
                end
            end
        end
    end
end

Remotes.Inventory.General.DeleteItems.OnServerEvent:Connect(deleteStudioItems)