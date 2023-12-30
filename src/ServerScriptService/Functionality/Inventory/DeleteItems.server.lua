local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local FurnitureConfigServer = require(ServerScriptService.Functionality.Furniture.FurnitureConfigServer)
local StudioConfigServer = require(ServerScriptService.Functionality.Studio.StudioConfigServer)

local Remotes = ReplicatedStorage.Remotes

local function deleteStudioItems(plr: Player, itemType: string, itemsToDelete)
    if itemType == "furniture" then
        for category, itemsInCategory in itemsToDelete do
            for itemName, itemInstances in itemsInCategory do
                for _i, itemUUID in itemInstances do
                    local itemInfo = {ItemCategory = category, ItemName = itemName, ItemUUID = itemUUID}
                    local gotDeleted = FurnitureConfigServer.DeleteFurnitureItem(plr, itemInfo)
 
                    -- remove item for all plrs in studio
                    if gotDeleted then
                        for plrUserId, studioInfo in StudioConfigServer.PlrsInStudio do
                            if studioInfo then
                                if studioInfo.PlrVisitingId == plr.UserId then
                                    local plrToUpdate: Player = Players:GetPlayerByUserId(plrUserId)
                                    Remotes.Studio.BuildMode.RemoveItem:FireClient(plrToUpdate, "furniture", itemInfo)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

Remotes.Inventory.General.DeleteItems.OnServerEvent:Connect(deleteStudioItems)