local ServerScriptService = game:GetService("ServerScriptService")

local StudioServer = require(ServerScriptService.Functionality.Studio.StudioConfigServer)

return function(context)
    return StudioServer.PurchaseNextStudio(context.Executor)
end