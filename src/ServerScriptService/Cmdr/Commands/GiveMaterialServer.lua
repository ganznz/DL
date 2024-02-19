local ServerScriptService = game:GetService("ServerScriptService")

local MaterialsConfigServer = require(ServerScriptService.Functionality.Materials.MaterialsConfigServer)

return function(context, plr: Player, materialName: string, amount: number)
    amount = amount or 1

    return MaterialsConfigServer.GiveMaterial(plr, materialName, amount)
end