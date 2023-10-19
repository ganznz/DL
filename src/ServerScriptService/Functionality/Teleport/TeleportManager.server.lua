local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TeleportAreas = require(ReplicatedStorage.Configs.TeleportAreas)
local PlrDataManager = require(ServerScriptService.PlayerData.Manager)

local Remotes = ReplicatedStorage.Remotes

local function canTp(plr: Player, tpPart: BasePart): boolean
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local plrData = profile.Data

    if tpPart then
        local areaName = tpPart:GetAttribute("AreaName")
        local areaAccessibility = tpPart:GetAttribute("AreaAccessibility")

        if areaAccessibility and areaAccessibility == "General" then
            return true
        
        elseif areaAccessibility and areaAccessibility == "Unlockable" then
            -- check if plr has area unlocked
            if plrData.Areas[areaName] then
                return true
            else
                return false
            end
        end
    end
    return false
end

Remotes.Player.TeleportPlr.OnServerEvent:Connect(function(plr, tpPart)
    local char = plr.Character

    if canTp(plr, tpPart) then
        char:MoveTo(tpPart.Position)
        Remotes.GUI.ChangeGuiStatusRemote:FireClient(plr, "loadingBgSplash", false, nil)
    end
end)