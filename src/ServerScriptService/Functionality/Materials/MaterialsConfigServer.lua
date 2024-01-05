local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local MaterialsConfig = require(ReplicatedStorage.Configs.Materials.Materials)

local MaterialsServer = {}

function MaterialsServer.GiveMaterial(plr: Player, materialName: string)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    if profile.Data.Inventory.Materials[materialName] then
        profile.Data.Inventory.Materials[materialName].Amount += 1
    end
end

function MaterialsServer.DeleteMaterial(plr: Player, materialName: string, amtToDelete: number)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    -- safety check in case amtToDelete value is greater than actual inventory amount value.
    if amtToDelete > profile.Data.Inventory.Materials[materialName].Amount then
        profile.Data.Inventory.Materials[materialName].Amount = 0
        return
    end

    profile.Data.Inventory.Materials[materialName].Amount -= amtToDelete
end

return MaterialsServer