local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlrPlatformManager = require(ReplicatedStorage:WaitForChild("PlrPlatformManager"))
local PlacementSystem = require(ReplicatedStorage.Libs:WaitForChild("PlacementSystem"))
local MoodFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("MoodFurniture"))
local EnergyFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("EnergyFurniture"))
local HungerFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("HungerFurniture"))
local DecorFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("DecorFurniture"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local localPlr = Players.LocalPlayer
local mouse = localPlr:GetMouse()

local plrPlatformProfile = PlrPlatformManager.GetProfile(localPlr)

local studioFurnitureModelsFolder = ReplicatedStorage.Assets.Models.StudioFurnishing

-- STATE VARIABLES
local char = localPlr.Character or localPlr.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local placement
local studioInteriorFolder
local studioFurnitureFolder
local studioInteriorPlot
local placeItemConnection = nil
local inBuildMode = false
local inPlaceMode = false

local function registerModelClickConnection(model)
    local clickDetector = Instance.new("ClickDetector", model)

    clickDetector.MouseClick:Connect(function(plr: Player)
        print(model.Name)
    end)
end

local function enableAllModelClickConnections()
    for _i, itemModel: Model in studioFurnitureFolder:GetChildren() do
        registerModelClickConnection(itemModel)
    end
end

local function disableAllModelClickConnections()
    for _i, itemModel: Model in studioFurnitureFolder:GetChildren() do
        local clickDetector = itemModel:FindFirstChild("ClickDetector", true)
        if clickDetector then clickDetector:Destroy() end
    end
end

local function exitPlaceMode()
    placement:Deactivate()

    if placeItemConnection then
        placeItemConnection:Disconnect()
        placeItemConnection = nil
    end
end

Remotes.Studio.EnterBuildMode.OnClientEvent:Connect(function(_studioInventoryData)
    inBuildMode = true

    studioInteriorFolder = Workspace.TempAssets.Studios:FindFirstChild(localPlr.UserId)
    studioInteriorPlot = studioInteriorFolder:FindFirstChild("Plot", true)
    studioFurnitureFolder = studioInteriorFolder:FindFirstChild("PlacedObjects", true)

    placement = PlacementSystem.new(2, studioInteriorPlot, studioFurnitureFolder, false)
    placement:RenderGrid()

    enableAllModelClickConnections()
end)

Remotes.Studio.EnterPlaceMode.OnClientEvent:Connect(function(itemName: string, itemCategory: string)
    inPlaceMode = true
    
    local itemModel = studioFurnitureModelsFolder[itemCategory]:FindFirstChild(itemName):Clone()
    placement:Activate(itemModel)
    
    if plrPlatformProfile.Platform == "pc" then
        placeItemConnection = mouse.Button1Down:Connect(function()
            placement:place(Remotes.Studio.PlaceItem, { category = itemCategory })
        end)
    end

    disableAllModelClickConnections()
end)

Remotes.Studio.ExitPlaceMode.OnClientEvent:Connect(function(_studioFurnitureInventory)
    exitPlaceMode()
    inPlaceMode = false

    if inBuildMode then
        enableAllModelClickConnections()
    end
end)


-- place item in studio
Remotes.Studio.PlaceItem.OnClientEvent:Connect(function(itemName, itemCategory, itemCFrame, itemUUID)
    local itemModelToPlace = studioFurnitureModelsFolder[itemCategory]:FindFirstChild(itemName):Clone()
    itemModelToPlace:PivotTo(itemCFrame)
    itemModelToPlace.Name = itemUUID
    itemModelToPlace.Parent = studioFurnitureFolder
end)

-- exit place mode
Remotes.Studio.ExitBuildMode.Event:Connect(function()
    placement:DestroyGrid()
    inBuildMode = false
end)

-- disable furniture model click connections
Remotes.Studio.DisableFurnitureItemClickDetectors.Event:Connect(function() disableAllModelClickConnections() end)

humanoid.Died:Connect(function()
    if inBuildMode then
        placement:DestroyGrid()
        inBuildMode = false
    end

    if inPlaceMode then
        exitPlaceMode()
        inPlaceMode = false
    end
end)

localPlr.CharacterAdded:Connect(function(character: Model)
    char = character
    humanoid = char:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        if inBuildMode then
            placement:DestroyGrid()
            inBuildMode = false
        end
    
        if inPlaceMode then
            exitPlaceMode()
            inPlaceMode = false
        end
    end)
end)