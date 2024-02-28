local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local GlobalVariables = require(ReplicatedStorage.GlobalVariables)
local Zone = require(ReplicatedStorage.Libs.Zone)

local Remotes = ReplicatedStorage.Remotes


-- STATE VARIABLES --
local generalHitboxZone = nil
local doorHitboxZone = nil

local accessibleBuildingExteriorFolders = CollectionService:GetTagged("AccessibleBuildingExterior")
local accessibleBuildingInteriorFolders = CollectionService:GetTagged("AccessibleBuildingInterior")
--[[
    make a copy of all building exteriors, so when player leaves a building and
    needs to make the exterior visible again, copy it from this table
    and put it back into the workspace
]]
local buildingExteriorsCopy = {}
for _i, buildingExteriorFolder in accessibleBuildingExteriorFolders do
    buildingExteriorsCopy[buildingExteriorFolder.Name] = buildingExteriorFolder:Clone()
end

local function calculateYOffset(model: Model): number
    if not model:IsA("Model") then return end

    return model.PrimaryPart.Size.Y / 2
end

local function destroyBuildingExterior(buildingName: string)
    local buildingExteriorFolder: Folder
    for _, exteriorFolder: Folder in accessibleBuildingExteriorFolders do
        if exteriorFolder.Name == buildingName then
            buildingExteriorFolder = exteriorFolder
            break
        end
    end
    if not buildingExteriorFolder then return end

    buildingExteriorFolder:Destroy()
end

local function destroyBuildingInterior(buildingName: string)
    -- destroy interior zones
    if generalHitboxZone then
        generalHitboxZone:destroy()
        generalHitboxZone = nil
    end
    if doorHitboxZone then
        doorHitboxZone:destroy()
        doorHitboxZone = nil
    end

    -- destroy interior
    local buildingInteriorFolder: Folder = Workspace.TempAssets.Buildings[buildingName]
    if buildingInteriorFolder then buildingInteriorFolder:Destroy() end
end

local function regenerateBuildingExterior(buildingName: string)
    local buildingExteriorFolder: Folder = buildingExteriorsCopy[buildingName]:Clone()
    if buildingExteriorFolder then
        buildingExteriorFolder.Parent = Workspace.Map.Buildings
    end
end

local function registerBuildingInteriorHitboxes(buildingInteriorFolder: Folder)
    local interiorModel: Model = buildingInteriorFolder:FindFirstChild("Interior")
    if not interiorModel then return end

    -- register exit door hitbox
    local generalInteriorHitbox: Model = interiorModel:FindFirstChild("HitboxZone")
    local doorHitbox: Model = interiorModel:FindFirstChild("TeleportHitboxZone")
    if not generalInteriorHitbox or not doorHitbox then return end

    -- if old interior zones exist, destroy them
    if generalHitboxZone then
        generalHitboxZone:destroy()
        generalHitboxZone = nil
    end
    if doorHitboxZone then
        doorHitboxZone:destroy()
        doorHitboxZone = nil
    end

    -- re-establish interior zones
    generalHitboxZone = Zone.new(generalInteriorHitbox)
    doorHitboxZone = Zone.new(doorHitbox)

    -- if plr exits the general hitbox's zone, notify the server that the player has left the building
    generalHitboxZone.playerExited:Connect(function()
        Remotes.General.ExitBuilding:FireServer()
    end)

    -- if plr exits building by entering door hitbox, do the same thing
    doorHitboxZone.playerEntered:Connect(function()
        Remotes.General.ExitBuilding:FireServer()
    end)
end

local function enterBuilding(buildingName: string)
    -- refresh accessibleBuildingExteriorFolders to include re-generated building exterior folders
    accessibleBuildingExteriorFolders = CollectionService:GetTagged("AccessibleBuildingExterior")

    local buildingExteriorFolder: Folder
    for _, exteriorFolder: Folder in accessibleBuildingExteriorFolders do
        if exteriorFolder.Name == buildingName then
            buildingExteriorFolder = exteriorFolder
            break
        end
    end
    if not buildingExteriorFolder then return end

    local buildingInteriorFolder: Folder
    for _, interiorFolder: Folder in accessibleBuildingInteriorFolders do
        if interiorFolder.Name == buildingName then
            buildingInteriorFolder = interiorFolder:Clone()
            break
        end
    end
    if not buildingInteriorFolder then return end

    local buildingInteriorModel: Model = buildingInteriorFolder:FindFirstChild("Interior", true)

    -- the part that the interior of the building teleports to
    local interiorTpPart: Part = buildingExteriorFolder:FindFirstChild("InteriorTeleportPart", true)

    local interiorPosYOffset: number = calculateYOffset(buildingInteriorModel)
    buildingInteriorModel:PivotTo(interiorTpPart.CFrame * CFrame.new(0, interiorPosYOffset, 0))

    task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
        destroyBuildingExterior(buildingName)
        buildingInteriorFolder.Parent = Workspace.TempAssets.Buildings

        registerBuildingInteriorHitboxes(buildingInteriorFolder)
    end)
end

Remotes.General.EnterBuilding.OnClientEvent:Connect(enterBuilding)

Remotes.General.ExitBuilding.OnClientEvent:Connect(function(buildingName: string)
    destroyBuildingInterior(buildingName)
    regenerateBuildingExterior(buildingName)
end)