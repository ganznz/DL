local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlacementSystem = require(ReplicatedStorage.Libs:WaitForChild("PlacementSystem"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local localPlr = Players.LocalPlayer
local mouse = localPlr:GetMouse()

local studioFurnitureFolder = ReplicatedStorage.Assets.Models.StudioFurnishing

local placement = PlacementSystem.new(2, studioFurnitureFolder, Enum.KeyCode.R, Enum.KeyCode.X)

task.wait(2)

placement:Activate("sofa", workspace:WaitForChild("PlacementPlot"):WaitForChild("PlacedFurniture"), workspace:WaitForChild("PlacementPlot"), true)

mouse.Button1Down:Connect(function()
    placement:place(Remotes.Studio.PlaceItem)
end)