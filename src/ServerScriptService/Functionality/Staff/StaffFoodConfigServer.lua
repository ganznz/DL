local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local StaffFoodConfig = require(ReplicatedStorage.Configs.Staff.StaffFood)

local StaffFoodServer = {}

function StaffFoodServer.GiveFood(plr: Player, foodName: string)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    if profile.Data.Inventory.StaffFood[foodName] then
        profile.Data.Inventory.StaffFood[foodName].Amount += 1
    end
end

return StaffFoodServer