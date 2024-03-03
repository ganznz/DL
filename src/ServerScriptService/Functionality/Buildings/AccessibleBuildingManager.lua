local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local accessibleBuildingExteriorFolders = CollectionService:GetTagged("AccessibleBuildingExterior")
local accessibleBuildingInteriorFolders = CollectionService:GetTagged("AccessibleBuildingInterior")

local GlobalVariables = require(ReplicatedStorage.GlobalVariables)
local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local PlayerCharacterManager = require(ServerScriptService.Functionality.PlayerCharacterManager.PlayerCharacterManager)
local TeleportAreas = require(ReplicatedStorage.Configs.TeleportAreas)
local Zone = require(ReplicatedStorage.Libs.Zone)

local Remotes = ReplicatedStorage.Remotes

-- STATE VARIABLES --
-- dictionary keeps track of all players in the server and if they're in a building or not
-- { [plr.UserId] = { InBuilding = "buildingName" | false }
local plrsInBuildings = {}

local AccessibleBuildingManager = {}

AccessibleBuildingManager.PlrsInBuildings = plrsInBuildings

function AccessibleBuildingManager.ExitBuilding(plr: Player)
    -- check if plr is in a building
    local buildingPlrIsIn: string | false = plrsInBuildings[plr.UserId].InBuilding

    if not buildingPlrIsIn then return end

    -- plr is in a building, remove them from it
    Remotes.GUI.ChangeGuiStatusRemote:FireClient(plr, "loadingBgSplash")
    task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
        PlayerCharacterManager.TeleportPlr(plr, buildingPlrIsIn, "Exterior")
        Remotes.General.ExitBuilding:FireClient(plr, buildingPlrIsIn)
    end)
    plrsInBuildings[plr.UserId].InBuilding = false
end

function AccessibleBuildingManager.CanAccessBuilding(plr: Player, buildingName: string): boolean
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return false end

    local canAccess: boolean = false

    -- check if building has general access (accessible to anyone, no unlocking required)
    local allGeneralAreas = TeleportAreas.GeneralAreas
    if table.find(allGeneralAreas, buildingName) then canAccess = true end

    -- if the building being accessed hasn't got general access, then it is unlockable. check if plr has unlocked it
    if not canAccess then
        if TeleportAreas.HasAccess(plr.Data, buildingName) then canAccess = true end
    end

    return canAccess
end

function AccessibleBuildingManager.EnterBuilding(plr: Player, buildingName: string)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    plrsInBuildings[plr.UserId] = { InBuilding = buildingName }

    Remotes.GUI.ChangeGuiStatusRemote:FireClient(plr, "loadingBgSplash")
    Remotes.General.EnterBuilding:FireClient(plr, buildingName)
end

-- register building exterior teleports
for _i, buildingExteriorFolder in accessibleBuildingExteriorFolders do
    local buildingName = buildingExteriorFolder.Name
    
    local teleportHitbox: Model = buildingExteriorFolder:FindFirstChild("TeleportHitboxZone", true)
    local zone = Zone.new(teleportHitbox)
    
    zone.playerEntered:Connect(function(plr: Player)
        local profile = PlrDataManager.Profiles[plr]
        if not profile then return end

        local plrData = profile.Data

        -- check if plr can access this building
        if AccessibleBuildingManager.CanAccessBuilding(plr, buildingName) then
            AccessibleBuildingManager.EnterBuilding(plr, buildingName)

            -- tp plr
            task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
                PlayerCharacterManager.TeleportPlr(plr, buildingName, "Interior")
            end)
        else
            -- show unlockable information
        end
    end)
end

-- REMOTES --
Remotes.General.ExitBuilding.OnServerEvent:Connect(AccessibleBuildingManager.ExitBuilding)

Players.PlayerAdded:Connect(function(plr: Player)
    repeat task.wait() until PlrDataManager.Profiles[plr]

    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    plrsInBuildings[plr.UserId] = { InBuilding = false }
end)

Players.PlayerRemoving:Connect(function(plr)
    plrsInBuildings[plr.UserId] = nil
end)

return AccessibleBuildingManager