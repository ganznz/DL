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

local placement
local studioInteriorFolder
local studioFurnitureFolder
local studioInteriorPlot
local placeItemConnection = nil

local function exitPlaceMode()
    placement:Deactivate()

    if placeItemConnection then
        placeItemConnection:Disconnect()
        placeItemConnection = nil
    end
end

Remotes.Studio.EnterBuildMode.OnClientEvent:Connect(function(_studioInventoryData)
    studioInteriorFolder = Workspace.TempAssets.Studios:FindFirstChild(localPlr.UserId)
    studioInteriorPlot = studioInteriorFolder:FindFirstChild("Plot", true)
    studioFurnitureFolder = studioInteriorFolder:FindFirstChild("PlacedObjects", true)

    placement = PlacementSystem.new(2, studioInteriorPlot, studioFurnitureFolder, false)
    placement:RenderGrid()
end)

Remotes.Studio.EnterPlaceMode.OnClientEvent:Connect(function(itemName: string, itemCategory: string)
    local itemModel = studioFurnitureModelsFolder[itemCategory]:FindFirstChild(itemName):Clone()
    placement:Activate(itemModel)

    if plrPlatformProfile.Platform == "pc" then
        placeItemConnection = mouse.Button1Down:Connect(function()
            placement:place(Remotes.Studio.PlaceItem, { category = itemCategory })
        end)
    end
end)

Remotes.Studio.ExitPlaceMode.OnClientEvent:Connect(function(_studioFurnitureInventory)
    exitPlaceMode()
end)


-- place item in studio
Remotes.Studio.PlaceItem.OnClientEvent:Connect(function(itemName, itemCategory, itemCFrame, itemUUID)
    local itemModelToPlace = studioFurnitureModelsFolder[itemCategory]:FindFirstChild(itemName):Clone()
    itemModelToPlace:PivotTo(itemCFrame)
    itemModelToPlace.Name = itemUUID
    itemModelToPlace.Parent = studioFurnitureFolder
end)