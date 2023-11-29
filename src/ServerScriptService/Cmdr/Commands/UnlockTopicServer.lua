local ServerScriptService = game:GetService("ServerScriptService")

local GenreTopicConfigServer = require(ServerScriptService.Functionality.GameDev.GenreTopicConfigServer)

return function(context, plr: Player?)
    plr = if plr then plr else context.Executor

    return GenreTopicConfigServer.UnlockTopic(plr)
end