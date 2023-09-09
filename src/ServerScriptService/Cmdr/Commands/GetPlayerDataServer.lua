local ServerScriptService = game:GetService("ServerScriptService")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)

return function(context, plr: Player?, dataDirectory: string?)
    plr = if plr then plr else context.Executor
    
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return "No profile found." end

    if not dataDirectory then
        print(profile.Data)
        return "All data printed."
    end

    print(profile.Data[dataDirectory])
    return "Data printed."
end