-- MODULE ONLY TO BE USED ON CLIENT

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Remotes = ReplicatedStorage.Remotes

local plr: Player = Players.LocalPlayer
local char: Model = plr.Character or plr.CharacterAdded:Wait()
local mouse: Mouse = plr:GetMouse()

-- Settings
-- bools
local interpolation = true
local moveByGrid = true

-- integers
local rotationStep = 90 --degrees
local maxHeight = 90 --studs

-- numbers/floats
local lerpLevel = 0.7 -- 0 = instant snapping, 1 = no movement at all

-- other
local gridTexture = "rbxassetid://2415319308"

local Placement = {}

Placement.__index = Placement

-- Constructor variables
local GRID_SIZE -- size of each tile on plot, in studs

-- Activation variables
local object
local objectParent
local plot

-- Variables used in calculations
local posX
local posY
local posZ
local speed = 1
local rotation = 0
local rotationVal = false

-- Other
local collided = nil

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

    posY = calculateYPosition(plot.Position.Y, plot.Size.Y, object.PrimaryPart.Size.Y)

    if moveByGrid then
        local plotCFrame = CFrame.new(plot.CFrame.X, plot.CFrame.Y, plot.CFrame.Z)
        local pos = CFrame.new(x, 0, z)
        pos = snap(pos * plotCFrame:Inverse()) -- ToObjectSpace
        finalCFrame = pos * plotCFrame * CFrame.new(offsetX, 0, offsetZ)
    else
        finalCFrame = CFrame.new(mouse.Hit.X, posY, mouse.Hit.Z)
    end

    finalCFrame = bounds(CFrame.new(finalCFrame.X, posY, finalCFrame.Z), offsetX, offsetZ)

    return finalCFrame * CFrame.Angles(0, math.rad(rotation), 0)
end

-- set object position based on pivot
local function translateObj()
    if objectParent and object.Parent == objectParent then
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

function Placement:place(itemType, itemInfo: {}, additionalParams: {})
    if not collided and object then
        local placementCFrame = getInstantCFrame()

        -- relativeOffset is what gets saved to datastore. This CFrame when loading items onto plot upon joining studio is then converted to worldspace
        -- saved to DS as object-space in case interior plot position gets moved in future updates
        local relativeOffset = plot.CFrame:ToObjectSpace(placementCFrame)

        itemInfo["PlacementCFrame"] = placementCFrame
        itemInfo["RelativeCFrame"] = relativeOffset

        -- additionalParams contain info you want to send to the server that are exclusive to your games functionality (e.g. an items rarity)
        Remotes.Studio.BuildMode.PlaceItem:FireServer(itemType, itemInfo, additionalParams)
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
function Placement.new(gridSize, plt)
    local data = {}
    setmetatable(data, Placement)

    GRID_SIZE = gridSize

    plot = plt

    data.grid = GRID_SIZE

    return data
end

-- activates placement
function Placement:Activate(obj: Model, objParent)
    objectParent = objParent

    -- destroy previous build-mode session object if it still exists
    if object then
        object:Destroy()
    end

    -- assigns values for necessary variables
    object = obj
    rotation = 0
    rotationVal = true

    -- ensures that while in 'place mode', object collisions don't interfere with anything
    for _i, v in object:GetDescendants() do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end

    if not approvePlacement() then return "Placement could not activate" end

    mouse.TargetFilter = object

    -- sets up interpolation speed
    local tempSpeed = 1
    if interpolation then
        tempSpeed = math.clamp((1 - lerpLevel), 0, 0.9)
        speed = 1
    end

    -- prevents visual 'dragging/lerping' of object from it's initial position in ReplicatedStorage to the workspace
    object:PivotTo(calculateItemPosition())

    object.Parent = objectParent

    task.wait()

    speed = tempSpeed

    RunService:BindToRenderStep("Input", Enum.RenderPriority.Input.Value, translateObj)
end

function Placement:RenderGrid()
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
    TweenService:Create(texture, TweenInfo.new(0.5), { Transparency = 0 }):Play()
end

function Placement:Rotate()
    rotation += rotationStep
    rotationVal = not rotationVal
end

function Placement:DestroyGrid()
    local plotTexture = plot:FindFirstChildOfClass("Texture")
    if plotTexture then
        local textureTween = TweenService:Create(plotTexture, TweenInfo.new(0.5), { Transparency = 1 })
        textureTween:Play()
        textureTween.Completed:Connect(function(_playbackState)
            plotTexture:Destroy()
        end)
    end
end

function Placement:Deactivate()
    -- unbindInputs()
    object:Destroy()
    mouse.TargetFilter = nil
end

return Placement