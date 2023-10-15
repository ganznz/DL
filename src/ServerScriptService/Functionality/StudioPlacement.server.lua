local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage.Remotes

local function handleCollisions(object, char)
    local collided = false

    if object then

        local collisionPoint = object.PrimaryPart.Touched:Connect(function() end)
        local collisionPoints = Workspace:GetPartsInPart(object.PrimaryPart)

        for _i, collisionPt in collisionPoints do
            if not collisionPt:IsDescendantOf(object) and not collisionPt:IsDescendantOf(char) then
                collided = true
                break
            end
        end

        collisionPoint:Disconnect()
        
        return collided
    end
end

-- security for if exploiter changes plot size
local function checkBoundaries(plot, object): boolean
    local LOWER_X_BOUND
    local LOWER_Z_BOUND
    local UPPER_X_BOUND
    local UPPER_Z_BOUND

    local currentPos = object.PrimaryPart.Position

    LOWER_X_BOUND = plot.Position.X - (plot.Size.X * 0.5)
    UPPER_X_BOUND = plot.Position.X + (plot.Size.X * 0.5)
    LOWER_Z_BOUND = plot.Position.Z - (plot.Size.Z * 0.5)
    UPPER_Z_BOUND = plot.Position.Z + (plot.Size.Z * 0.5)
    
    -- check if out of the plot bounds
    -- returns true IF out of plot bounds
    return currentPos.X > UPPER_X_BOUND or currentPos.X < LOWER_X_BOUND or currentPos.Z > UPPER_Z_BOUND or currentPos.Z < LOWER_Z_BOUND
end

local function place(plr: Player, objectName, objectLocation, cframe, plot): boolean
    local item = ReplicatedStorage.Assets.Models.StudioFurnishing:FindFirstChild(objectName):Clone()
    item.PrimaryPart.CanCollide = false
    item:PivotTo(cframe)
    
    if plot then
        item.Parent = objectLocation

        if checkBoundaries(plot, item) then
            item:Destroy()
            return false
        end

        if handleCollisions(item, plr.Character) then
            item:Destroy()
            return false
        end
    end

    return true
end

remotes.Studio.PlaceItem.OnServerInvoke = place