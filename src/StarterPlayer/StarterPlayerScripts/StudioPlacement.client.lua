local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlacementHandler = require(ReplicatedStorage.Libs:WaitForChild("PlacementHandler"))

local studioFurnitureFolder = ReplicatedStorage.Assets.Models.StudioFurnishing

local placement = PlacementHandler.new(2, studioFurnitureFolder, Enum.KeyCode.R, Enum.KeyCode.X)

task.wait(2)

placement:Activate("crate", workspace:WaitForChild("PlacedFurniture"), workspace:WaitForChild("PlacementPlot"), false)