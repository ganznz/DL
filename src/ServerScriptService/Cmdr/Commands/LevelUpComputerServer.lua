local ServerScriptService = game:GetService("ServerScriptService")

local StudioConfigServer = require(ServerScriptService.Functionality.Studio.StudioConfigServer)
local ComputerConfigServer = require(ServerScriptService.Functionality.GameDev.ComputerConfigServer)

return function(context, plr: Player?)
    plr = if plr then plr else context.Executor
    
    -- check if plr is in their studio
    local plrsInStudio = StudioConfigServer.PlrsInStudio
    if not plrsInStudio[plr.UserId] then return "You must be in your studio to execute this cmd" end

    -- plr is in a studio, check if it is their own
    if plrsInStudio[plr.UserId].PlrVisitingId ~= plr.UserId then return "You must be in your studio to execute this cmd" end

    return ComputerConfigServer.LevelUpComputer(plr, true)
end