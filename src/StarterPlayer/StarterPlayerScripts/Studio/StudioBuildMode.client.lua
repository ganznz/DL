local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlacementSystem = require(ReplicatedStorage.Libs:WaitForChild("PlacementSystem"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local localPlr = Players.LocalPlayer
local mouse = localPlr:GetMouse()

local studioFurnitureFolder = ReplicatedStorage.Assets.Models.StudioFurnishing

local placement
local studioInteriorFolder
local studioInteriorPlot

-- placement:Activate("sofa", workspace:WaitForChild("PlacementPlot"):WaitForChild("PlacedFurniture"), workspace:WaitForChild("PlacementPlot"), true)

-- later on store these inside system
-- placement.buildModeActivated = true
-- placement.placeModeActivated = true

-- mouse.Button1Down:Connect(function()
--     if placement.buildModeActivated and placement.placeModeActivated then
--         placement:place(Remotes.Studio.PlaceItem)
--     end
-- end)

-- Remotes.Studio.ExitPlaceMode.OnClientEvent:Connect(function()
--     placement:Deactivate()
-- end)

Remotes.Studio.EnterBuildMode.OnClientEvent:Connect(function(_studioInventoryData)
    studioInteriorFolder = Workspace.TempAssets.Studios:FindFirstChild(localPlr.UserId)
    print(studioInteriorFolder)
    studioInteriorPlot = studioInteriorFolder:FindFirstChild("Plot", true)
    studioFurnitureFolder = studioInteriorFolder:FindFirstChild("PlacedObjects", true)

    placement = PlacementSystem.new(2, studioInteriorPlot, studioFurnitureFolder, false)
    placement:RenderGrid()
end)