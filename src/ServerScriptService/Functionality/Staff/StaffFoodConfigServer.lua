local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local StaffFoodConfig = require(ReplicatedStorage.Configs.Staff.StaffFood)

local StaffFoodServer = {}

function StaffFoodServer.GiveFood(plr: Player, foodName: string, amt: number)
    amt = amt or 1

    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    if profile.Data.Inventory.StaffFood[foodName] then
        profile.Data.Inventory.StaffFood[foodName].Amount += amt
    end
end

function StaffFoodServer.DeleteFood(plr: Player, foodName: string, amtToDelete: number)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    -- safety check in case amtToDelete value is greater than actual inventory amount value.
    if amtToDelete > profile.Data.Inventory.StaffFood[foodName].Amount then
        profile.Data.Inventory.StaffFood[foodName].Amount = 0
        return
    end

    profile.Data.Inventory.StaffFood[foodName].Amount -= amtToDelete
end

return StaffFoodServer