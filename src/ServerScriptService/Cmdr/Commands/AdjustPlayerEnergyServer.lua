local ServerScriptService = game:GetService("ServerScriptService")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)

return function(context, plr: Player?, amt: number?)
    plr = if plr then plr else context.Executor
    
    amt = if amt then amt else 1

    return PlrDataManager.AdjustPlrEnergy(plr, amt)
end