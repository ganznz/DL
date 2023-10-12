-- MODULE ONLY TO BE USED ON CLIENT

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local plr: Player = Players.LocalPlayer
local char: Model = plr.Character or plr.CharacterAdded:Wait()
local mouse: Mouse = plr:GetMouse()

-- Settings
-- bools
local interpolation = true
local moveByGrid = true
local buildModePlacement = true

-- integers
local rotationStep = 90 --degrees
local maxHeight = 90 --studs

-- numbers/floats
local lerpSpeed = 0.7 -- seconds

-- other
local gridTexture = ""

local Placement = {}

Placement.__index = Placement

-- Constructor variables
local GRID_SIZE
local ITEM_LOCATION
local ROTATE_KEY
local TERMINATE_KEY

-- Activation variables
local object
local placedObjects
local plot
local isStackable

-- Variables used in calculations
local posX
local posY
local posZ

-- calculate the initial Y position above an object
local function calculateYPosition()
end

local function snap(x)
    return math.round(x / GRID_SIZE) * GRID_SIZE
end

-- calculate the model position based on grid
local function calculateItemPosition()
    if moveByGrid then
        posX = snap(mouse.Hit.X)
        posY = mouse.Hit.Y
        posZ = snap(mouse.Hit.Z)
    else
        posX = mouse.Hit.X
        posY = mouse.Hit.Y
        posZ = mouse.Hit.Z
    end
end

-- set model position based on pivot
local function translateObj()
    if placedObjects and object.Parent == placedObjects then
        calculateItemPosition()
        object:PivotTo(CFrame.new(posX, posY, posZ))
    end
end

local function approvePlacement()
    return true
end

-- Constructor function
function Placement.new(gridSize, objects, rotateKey, terminateKey)
    local data = {}
    local metaData = setmetatable(data, Placement)
    GRID_SIZE = gridSize
    ITEM_LOCATION = objects
    ROTATE_KEY = rotateKey
    TERMINATE_KEY = terminateKey

    data.grid = GRID_SIZE
    data.itemLocation = ITEM_LOCATION
    data.rotateKey = ROTATE_KEY
    data.terminateKey = TERMINATE_KEY

    return data
end

-- activates placement
function Placement:Activate(id: string, placedObjs: {}, plt, stackable: boolean)
    -- assigns values for necessary variables
    object = ITEM_LOCATION:FindFirstChild(id):Clone()
    placedObjects = placedObjs
    plot = plt
    isStackable = stackable

    if not approvePlacement() then return "Placement could not activate" end

    if not isStackable then
        mouse.TargetFilter = placedObjects
    else
        mouse.TargetFilter = object
    end

    object.Parent = placedObjects
end

RunService:BindToRenderStep("Input", Enum.RenderPriority.Input.Value, translateObj)

return Placement