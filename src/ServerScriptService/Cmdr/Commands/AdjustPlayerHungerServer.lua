local ServerScriptService = game:GetService("ServerScriptService")

local PlayerManagerConfig = require(ServerScriptService.Functionality.Player.PlayerManager)

return function(context, plr: Player?, amt: number?)
    plr = if plr then plr else context.Executor
    
    amt = if amt then amt else 1

    return PlayerManagerConfig.AdjustPlrHunger(plr, amt)
end