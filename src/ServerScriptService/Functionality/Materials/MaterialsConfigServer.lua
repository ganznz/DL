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

return MaterialsServer