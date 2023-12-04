local ServerScriptService = game:GetService("ServerScriptService")

local StudioPlaceablesServer = require(ServerScriptService.Functionality.Studio.StudioPlaceablesConfigServer)

return function(context, plr: Player, itemCategory: string, itemName: string)
    return StudioPlaceablesServer.PurchaseFurnitureItem(plr, itemName, itemCategory, context.Executor)
end