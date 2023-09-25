local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")

local Remotes = ReplicatedStorage.Remotes

local npcSpawnPart = Workspace.Map.Buildings.IceCreamStore:WaitForChild("IceCreamStoreInterior"):WaitForChild("NpcSpawnPart")
local npcDestinationPart = Workspace.Map.Buildings.IceCreamStore:WaitForChild("IceCreamStoreInterior"):WaitForChild("NpcDestinationPart")

local path = PathfindingService:CreatePath()
local waypoints
local nextWaypointIndex
local reachedConnection
local blockedConnection

local function followPath(npcHumanoid: Humanoid)
    local success, errorMessage = pcall(function()
        path:ComputeAsync(npcSpawnPart.Position, npcDestinationPart.Position)
    end)

    if success and path.status == Enum.PathStatus.Success then
        waypoints = path:GetWaypoints()

        blockedConnection = path.Blocked:Connect(function(blockedWaypointIndex)
            if blockedWaypointIndex >= nextWaypointIndex then
                blockedConnection:Disconnect()

                -- recompute new path
                followPath(npcHumanoid)
            end
        end)

        -- detect when movement to next waypoint is complete
        if not reachedConnection then
            reachedConnection = npcHumanoid.MoveToFinished:Connect(function(reached)
                if reached and nextWaypointIndex < #waypoints then
                    -- move to next waypoint
                    nextWaypointIndex += 1
                    npcHumanoid:MoveTo(waypoints[nextWaypointIndex].Position)
                else
                    reachedConnection:Disconnect()
					blockedConnection:Disconnect()
                end
            end)
        end

        -- start moving NPC
        nextWaypointIndex = 2
        npcHumanoid:MoveTo(waypoints[nextWaypointIndex].Position)
    else
        warn("NPC path not computed.", errorMessage)
    end
end

Remotes.Jobs.Cashier.SendCustomer.OnClientEvent:Connect(function(customerInfo)
    local customerModel = ReplicatedStorage.Assets.Models:FindFirstChild("NPC"):Clone()
    local customerHumanoid = customerModel:FindFirstChild("Humanoid")
    customerModel.Parent = Workspace
    customerModel.PrimaryPart.Position = npcSpawnPart.Position

    followPath(customerHumanoid)
end)