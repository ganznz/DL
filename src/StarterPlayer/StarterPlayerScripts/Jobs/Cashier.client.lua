local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui
local Remotes = ReplicatedStorage.Remotes

local mouse = localPlr:GetMouse()

local npcSpawnPart = Workspace.Map.Buildings.IceCreamStore:WaitForChild("IceCreamStoreInterior"):WaitForChild("NpcSpawnPart")
local npcDestinationPart = Workspace.Map.Buildings.IceCreamStore:WaitForChild("IceCreamStoreInterior"):WaitForChild("NpcDestinationPart")

-- gui
local customerOrderBillboard = PlayerGui:WaitForChild("Jobs").CashierJob.CashierJobCustomerOrder:WaitForChild("CustomerOrderBillboard")

local function displayCustomerOrder(customerModel: Model, customerInfo)
    local npcModelHead = customerModel:FindFirstChild("Head")
    local billboardGui = customerOrderBillboard:Clone()
    billboardGui.Parent = customerModel
    local orderContainerGui = billboardGui.CustomerOrderContainer
    billboardGui.Adornee = npcModelHead

    if customerInfo.icecream == "Chocolate" then
        orderContainerGui.BackgroundColor3 = Color3.fromRGB(141, 96, 66)
    elseif customerInfo.icecream == "Vanilla" then
        orderContainerGui.BackgroundColor3 = Color3.fromRGB(255, 251, 236)
    elseif customerInfo.icecream == "Strawberry" then
        orderContainerGui.BackgroundColor3 = Color3.fromRGB(255, 162, 162)
    end

    billboardGui.Enabled = true
end

local function customerInteraction(customerModel: Model)
    mouse.Button1Down:Connect(function()
        local target = mouse.Target
        if target:IsDescendantOf(customerModel) then
            customerModel:SetAttribute("orderFulfilled", true)
        end
    end)
end

local customerLifecycle = coroutine.create(function(customerModel: Model, customerInfo)
    displayCustomerOrder(customerModel, customerInfo)
    customerInteraction(customerModel)
    print('a')
    coroutine.yield()
    print('b')

end)

local function followPath(customerModel: Model, customerInfo)
    local humanoid = customerModel:FindFirstChild("Humanoid")
    local path = PathfindingService:CreatePath()
    local waypoints
    local nextWaypointIndex
    local reachedConnection
    local blockedConnection

    local success, errorMessage = pcall(function()
        path:ComputeAsync(npcSpawnPart.Position, npcDestinationPart.Position)
    end)

    if success and path.status == Enum.PathStatus.Success then
        waypoints = path:GetWaypoints()

        blockedConnection = path.Blocked:Connect(function(blockedWaypointIndex)
            if blockedWaypointIndex >= nextWaypointIndex then
                blockedConnection:Disconnect()
                blockedConnection = nil

                -- recompute new path
                followPath(humanoid)
            end
        end)

        -- detect when movement to next waypoint is complete
        if not reachedConnection then
            reachedConnection = humanoid.MoveToFinished:Connect(function(reached)
                if reached and nextWaypointIndex < #waypoints then
                    -- move to next waypoint
                    nextWaypointIndex += 1
                    humanoid:MoveTo(waypoints[nextWaypointIndex].Position)
                else
                    reachedConnection:Disconnect()
					blockedConnection:Disconnect()

                    coroutine.resume(customerLifecycle, customerModel, customerInfo)
                    
                    customerModel:GetAttributeChangedSignal("orderFulfilled"):Connect(function()
                        coroutine.resume(customerLifecycle, customerModel, customerInfo)
                    end)
                end
            end)
        end

        -- start moving NPC
        nextWaypointIndex = 2
        humanoid:MoveTo(waypoints[nextWaypointIndex].Position)
    else
        warn("NPC path not computed.", errorMessage)
    end
end

Remotes.Jobs.Cashier.SendCustomer.OnClientEvent:Connect(function(customerInfo)
    local customerModel = ReplicatedStorage.Assets.Models:FindFirstChild("NPC"):Clone()
    customerModel.Parent = Workspace
    customerModel.PrimaryPart.Position = npcSpawnPart.Position

    followPath(customerModel, customerInfo)
end)