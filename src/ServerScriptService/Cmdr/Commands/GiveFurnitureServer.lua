local ServerScriptService = game:GetService("ServerScriptService")

local FurnitureConfigServer = require(ServerScriptService.Functionality.Furniture.FurnitureConfigServer)

return function(context, plr: Player, itemCategory: string, itemName: string)
    return FurnitureConfigServer.PurchaseFurnitureItem(plr, itemName, itemCategory, context.Executor)
end