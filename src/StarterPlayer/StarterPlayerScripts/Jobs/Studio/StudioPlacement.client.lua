local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlacementSystem = require(ReplicatedStorage.Libs:WaitForChild("PlacementSystem"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local localPlr = Players.LocalPlayer
local mouse = localPlr:GetMouse()

local studioFurnitureFolder = ReplicatedStorage.Assets.Models.StudioFurnishing

local buildModeActivated = false
local placeModeActivated = false

local placement = PlacementSystem.new(2, studioFurnitureFolder, Enum.KeyCode.R, Enum.KeyCode.X)

task.wait(2)

placement:Activate("sofa", workspace:WaitForChild("PlacementPlot"):WaitForChild("PlacedFurniture"), workspace:WaitForChild("PlacementPlot"), true)

-- later on store these inside system
placement.buildModeActivated = true
placement.placeModeActivated = true

mouse.Button1Down:Connect(function()
    if placement.buildModeActivated and placement.placeModeActivated then
        print('activateddd')
        placement:place(Remotes.Studio.PlaceItem)
    end
end)

Remotes.Studio.ExitPlaceMode.OnClientEvent:Connect(function()
    print(placement)
    placement:Deactivate()
end)