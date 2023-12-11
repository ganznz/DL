local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)

local Remotes = ReplicatedStorage.Remotes

local function lockItem(plr: Player, itemType: string, itemInfo: {})
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local itemInstance
    if itemType == "furniture" then
        itemInstance = profile.Data.Inventory.StudioFurnishing[itemInfo.ItemCategory][itemInfo.ItemName][itemInfo.ItemUUID]
        if not itemInstance then return end

        itemInstance.Locked = not itemInstance.Locked

        Remotes.Inventory.General.LockItem:FireClient(plr, "furniture", itemInfo, itemInstance.Locked)
    end
end

Remotes.Inventory.General.LockItem.OnServerEvent:Connect(lockItem)