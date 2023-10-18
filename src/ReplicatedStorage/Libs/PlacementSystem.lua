-- MODULE ONLY TO BE USED ON CLIENT

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")

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
local lerpLevel = 0.7 -- 0 = instant snapping, 1 = no movement at all

-- other
local gridTexture = "rbxassetid://2415319308"

local Placement = {}

Placement.__index = Placement

-- placement instance data
local PLACEMENT_INSTANCE_DATA = nil

-- Constructor variables
local GRID_SIZE -- size of each tile on plot, in studs
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
local speed = 1
local rotation = 0
local rotationVal = false

-- Other
local collided = nil



local function renderGrid()
    -- destroy previous build-mode session plot texture if it still exists
    if plot:FindFirstChildOfClass("Texture") then
        plot:FindFirstChildOfClass("Texture"):Destroy()
    end

    local texture = Instance.new("Texture")
    texture.Transparency = 1
    texture.StudsPerTileU = GRID_SIZE
    texture.StudsPerTileV = GRID_SIZE
    texture.Texture = gridTexture
    texture.Face = Enum.NormalId.Top
    texture.Parent = plot
    TweenService:Create(texture, TweenInfo.new(1), { Transparency = 0 }):Play()
end

local function changeHitboxColour()
    if object.PrimaryPart then
        if collided then
            TweenService:Create(object.PrimaryPart, TweenInfo.new(0.1), { Color = Color3.fromRGB(255, 83, 83) }):Play()
        else
            TweenService:Create(object.PrimaryPart, TweenInfo.new(0.1), { Color = Color3.fromRGB(88, 225, 90) }):Play()
        end
        object.PrimaryPart.Transparency = 0.5
    end
end

local function handleCollisions()
    if object then
        collided = false -- base case

        local collisionPoint = object.PrimaryPart.Touched:Connect(function() end)
        local collisionPoints = Workspace:GetPartsInPart(object.PrimaryPart)

        for _i, collisionPt in collisionPoints do
            if not collisionPt:IsDescendantOf(object) and not collisionPt:IsDescendantOf(char) then
                collided = true
                break
            end
        end

        collisionPoint:Disconnect()

        return
    end
end

local function bounds(cframe, offsetX, offsetZ)
    local LOWER_X_BOUND
    local LOWER_Z_BOUND
    local UPPER_X_BOUND
    local UPPER_Z_BOUND

    LOWER_X_BOUND = plot.Position.X - (plot.Size.X * 0.5) + offsetX
    UPPER_X_BOUND = plot.Position.X + (plot.Size.X * 0.5) - offsetX
    LOWER_Z_BOUND = plot.Position.Z - (plot.Size.Z * 0.5) + offsetZ
    UPPER_Z_BOUND = plot.Position.Z + (plot.Size.Z * 0.5) - offsetZ

    local newX = math.clamp(cframe.X, LOWER_X_BOUND, UPPER_X_BOUND)
    local newZ = math.clamp(cframe.Z, LOWER_Z_BOUND, UPPER_Z_BOUND)
    
    return CFrame.new(newX, posY, newZ)
end

-- calculate the initial Y position above an object
local function calculateYPosition(toPos, toSize, objSize)
    return (toPos + toSize * 0.5) + objSize * 0.5
end

local function rotate(_actionName, inputState, _inputObj)
    if inputState == Enum.UserInputState.Begin then
        rotation += rotationStep
        rotationVal = not rotationVal
    end
end

local function cancelOnTermination(_actionName, inputState, _inputObj)
    if inputState == Enum.UserInputState.Begin then
        object:Destroy()
        local texture = plot:FindFirstChild("Texture")
        local textureTween = TweenService:Create(texture, TweenInfo.new(0.2), { Transparency = 0 })
        textureTween:Play()
        textureTween.Completed:Connect(function()
            plot:FindFirstChild("Texture"):Destroy()
        end)

        mouse.TargetFilter = nil
        PLACEMENT_INSTANCE_DATA.buildModeActivated = false
        PLACEMENT_INSTANCE_DATA.placeModeActivated = false
    end
end

-- snap selected object to grid tile
local function snap(cframe: CFrame)
    local newX = math.round(cframe.X / GRID_SIZE) * GRID_SIZE
    local newZ = math.round(cframe.Z / GRID_SIZE) * GRID_SIZE

    return CFrame.new(newX, 0, newZ)
end

-- calculate the object position based on grid
local function calculateItemPosition()
    local finalCFrame = CFrame.new(0, 0, 0)
    local x, z
    local offsetX, offsetZ

    if rotationVal then
        offsetX = object.PrimaryPart.Size.X * 0.5
        offsetZ = object.PrimaryPart.Size.Z * 0.5
        x =  mouse.Hit.X - offsetX
        z = mouse.Hit.Z - offsetZ
    else
        offsetX = object.PrimaryPart.Size.Z * 0.5
        offsetZ = object.PrimaryPart.Size.X * 0.5
        x =  mouse.Hit.X - offsetX
        z = mouse.Hit.Z - offsetZ
    end

    if isStackable and mouse.Target and mouse.Target:IsDescendantOf(plot) then
        posY = calculateYPosition(mouse.Target.Position.Y, mouse.Target.Size.Y, object.PrimaryPart.Size.Y)
    else
        posY = calculateYPosition(plot.Position.Y, plot.Size.Y, object.PrimaryPart.Size.Y)
    end

    if moveByGrid then
        local plotCFrame = CFrame.new(plot.CFrame.X, plot.CFrame.Y, plot.CFrame.Z)
        local pos = CFrame.new(x, 0, z)
        pos = snap(pos * plotCFrame:Inverse())
        finalCFrame = pos * plotCFrame * CFrame.new(offsetX, 0, offsetZ)
    else
        finalCFrame = CFrame.new(mouse.Hit.X, posY, mouse.Hit.Z)
    end

    finalCFrame = bounds(
        CFrame.new(finalCFrame.X, posY, finalCFrame.Z), offsetX, offsetZ)

    return finalCFrame * CFrame.Angles(0, math.rad(rotation), 0)
end

local function bindInputs()
    ContextActionService:BindAction("Rotate", rotate, false, ROTATE_KEY)
    ContextActionService:BindAction("Cancel", cancelOnTermination, false, TERMINATE_KEY)
end

local function unbindInputs()
    ContextActionService:UnbindAction("Rotate")
    ContextActionService:UnbindAction("Cancel")
end

-- set object position based on pivot
local function translateObj()
    if placedObjects and object.Parent == placedObjects then
        calculateItemPosition()
        handleCollisions()
        changeHitboxColour()

        object:PivotTo(object.PrimaryPart.CFrame:Lerp(calculateItemPosition(), speed))
    end
end

local function getInstantCFrame()
    -- returns the exact CFrame where item should be placed and ENSURES it gets placed w/ snapping
    -- for when player clicks during object interpolation (and non-snapped CFrame value gets returned)
    return calculateItemPosition()
end

function Placement:place(remote: RemoteFunction)
    print('aaa')
    if not collided and object then
        local placementCFrame = getInstantCFrame()

        remote:InvokeServer(object.Name, placedObjects, placementCFrame, plot)
    end
end

-- check if the object will snap evenly on the plot
local function verifyPlane()
    -- verifies that the plot contains only full-sized grids/tiles
    return plot.Size.X % GRID_SIZE == 0 and plot.Size.Z % GRID_SIZE == 0
end

-- confirms that the settings are valid for placement
local function approvePlacement()
    -- if grid/tile is larger than whole plot on either X or Z then throw error
    if GRID_SIZE >= math.min(plot.Size.X, plot.Size.Z) then
        error("Grid size is too close to the size of the plot on either X or Y axis.")
        return false
    end

    if not verifyPlane() then
        warn("The object cannot snap on the plot. Change the plot size.")
        return false
    end

    return true
end

-- Constructor function
function Placement.new(gridSize, objects, rotateKey, terminateKey)
    local data = {}
    local metadata = setmetatable(data, Placement)
    GRID_SIZE = gridSize
    ITEM_LOCATION = objects
    ROTATE_KEY = rotateKey
    TERMINATE_KEY = terminateKey

    data.grid = GRID_SIZE
    data.itemLocation = ITEM_LOCATION
    data.rotateKey = ROTATE_KEY or Enum.KeyCode.R
    data.terminateKey = TERMINATE_KEY or Enum.KeyCode.X

    PLACEMENT_INSTANCE_DATA = data

    return data
end

-- activates placement
function Placement:Activate(objectName: string, placedObjs: {}, plt, stackable: boolean)
    -- destroy previous build-mode session object if it still exists
    if object then
        object:Destroy()
    end

    -- assigns values for necessary variables
    object = ITEM_LOCATION:FindFirstChild(objectName):Clone()
    placedObjects = placedObjs
    plot = plt
    isStackable = stackable
    rotation = 0
    rotationVal = true
    self.buildModeActivated = true
    self.placeModeActivated = true

    -- ensures that while in 'place mode', object collisions don't interfere with anything
    for _i, v in object:GetDescendants() do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end

    if not approvePlacement() then return "Placement could not activate" end

    if not isStackable then
        mouse.TargetFilter = placedObjects
    else
        mouse.TargetFilter = object
    end

    -- sets up interpolation speed
    local tempSpeed = 1
    if interpolation then
        tempSpeed = math.clamp((1 - lerpLevel), 0, 0.9)
        speed = 1
    end

    renderGrid()

    object.Parent = placedObjects
    
    task.wait()

    bindInputs()
    speed = tempSpeed
end

function Placement:Deactivate()
    -- print(plot:FindFirstChild("Texture"))
    -- unbindInputs()
    -- object:Destroy()
    -- plot:FindFirstChild("Texture"):Destroy()
    -- mouse.TargetFilter = nil
    -- self.buildModeActivated = false
    -- self.placeModeActivated = false
end

RunService:BindToRenderStep("Input", Enum.RenderPriority.Input.Value, translateObj)

return Placement