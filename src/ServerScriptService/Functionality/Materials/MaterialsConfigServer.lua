local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local MaterialsConfig = require(ReplicatedStorage.Configs.Materials.Materials)

local MaterialsServer = {}

function MaterialsServer.GiveMaterial(plr: Player, materialName: string, amount: number)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    amount = amount or 1

    if profile.Data.Inventory.Materials[materialName] then
        profile.Data.Inventory.Materials[materialName].Amount += amount
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