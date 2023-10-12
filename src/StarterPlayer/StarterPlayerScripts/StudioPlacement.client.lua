local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlacementSystem = require(ReplicatedStorage.Libs:WaitForChild("PlacementSystem"))

local studioFurnitureFolder = ReplicatedStorage.Assets.Models.StudioFurnishing

local placement = PlacementSystem.new(2, studioFurnitureFolder, Enum.KeyCode.R, Enum.KeyCode.X)

task.wait(2)

placement:Activate("crate", workspace:WaitForChild("PlacedFurniture"), workspace:WaitForChild("PlacementPlot"), false)