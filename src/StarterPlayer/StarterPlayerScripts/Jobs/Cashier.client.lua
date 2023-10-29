local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")

local NpcUtils = require(ReplicatedStorage.Utils.Npc:WaitForChild("Npc"))
local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))

local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui
local Remotes = ReplicatedStorage.Remotes

local mouse = localPlr:GetMouse()

local icecreamStoreModel = Workspace.Map.Buildings.IceCreamStore
local icecreamStoreInterior = icecreamStoreModel:WaitForChild("IceCreamStoreInterior")
local npcSpawnPart = icecreamStoreInterior:WaitForChild("NpcSpawnPart")
local npcDestinationPart = icecreamStoreInterior:WaitForChild("NpcDestinationPart")
local icecreamFlavourParts = icecreamStoreInterior.Flavours:GetChildren()

local currentEquippedTool
local currentOrderStatus: 'good' | 'bad'

-- gui
local customerOrderBillboard = PlayerGui:WaitForChild("AllGui").Jobs:WaitForChild("CashierJob"):WaitForChild("CustomerOrderBillboard")

local ICECREAM_FLAVOURS = {"Chocolate", "Vanilla", "Strawberry"}

local function clearIcecreamTools(plr: Player, backpack: Backpack)
    for i, tool in backpack:GetChildren() do
        if table.find(ICECREAM_FLAVOURS, tool.Name) and tool:IsA("Tool") then
            tool:Destroy()
        end
    end
    -- remove equipped flavour also if any
    for i, flavour in ICECREAM_FLAVOURS do
        local equippedTool = plr.Character:FindFirstChild(flavour)
        if equippedTool then
            equippedTool:Destroy()
            break
        end
    end
end

local function clearNpcs()
    local npcFolder = Workspace.TempAssets.Jobs.CashierJob[localPlr.UserId].Npcs
    if npcFolder then
        for _, child in npcFolder:GetChildren() do
            NpcUtils.RemoveNpcStandard(child)
        end
    end
end

local function obtainIcecreamTool(plr: Player, flavour: string)
    local backpack = plr:FindFirstChildOfClass("Backpack")
    clearIcecreamTools(plr, backpack)

    local icecreamTool = ReplicatedFirst.Assets.Tools.Icecreams:FindFirstChild(flavour):Clone()
    icecreamTool.Parent = backpack
    icecreamTool.Equipped:Connect(function(_mouse)
        currentEquippedTool = icecreamTool
    end)
end

for _, icecreamPart in icecreamFlavourParts do
    local proxPrompt = icecreamPart:FindFirstChild("ProximityPrompt", true)
    proxPrompt.Triggered:Connect(function(plr)
        obtainIcecreamTool(plr, icecreamPart.Name)
    end)
end


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

local function displayClickIcon(customerModel: Model)
    local hrp = customerModel:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    GuiServices.DisplayClickIcon(hrp)
end

local function customerInteraction(customerModel: Model, customerInfo)
    mouse.Button1Down:Connect(function()
        local target = mouse.Target

        -- if clicked target is part of customer model AND plr has icecream equipped
        if target and target:IsDescendantOf(customerModel) and not customerModel:GetAttribute("orderFulfilled") then
            if currentEquippedTool and localPlr.Character:FindFirstChild(currentEquippedTool.Name) then
                currentOrderStatus = if currentEquippedTool.Name == customerInfo.icecream then "good" else "bad"
                customerModel:SetAttribute("orderFulfilled", true)
                clearIcecreamTools(localPlr, localPlr.Backpack)
            end
        end
    end)
end

local function cleanUpJob(plr)
    clearIcecreamTools(plr, plr.Backpack)
    clearNpcs()
end

local function followPath(customerModel: Model, customerInfo, startPos, finishPos)
    local humanoid = customerModel:FindFirstChild("Humanoid")
    local path = PathfindingService:CreatePath()
    local waypoints
    local nextWaypointIndex
    local reachedConnection
    local blockedConnection

    local customerLifecycle = coroutine.create(function(customerModel: Model, customerInfo)
        displayCustomerOrder(customerModel, customerInfo)
        displayClickIcon(customerModel)
        customerInteraction(customerModel, customerInfo)
        
        coroutine.yield()
    
        Remotes.Jobs.Cashier.CustomerOrderFulfilled:FireServer(currentOrderStatus)
        local npcColour = currentOrderStatus == 'good' and Color3.fromRGB(71, 217, 54) or Color3.fromRGB(217, 77, 79)
        NpcUtils.RemoveNpcStandard(customerModel, npcColour)
    end)

    local success, errorMessage = pcall(function()
        path:ComputeAsync(startPos, finishPos)
    end)

    if success and path.status == Enum.PathStatus.Success then
        waypoints = path:GetWaypoints()

        blockedConnection = path.Blocked:Connect(function(blockedWaypointIndex)
            if blockedWaypointIndex >= nextWaypointIndex then
                blockedConnection:Disconnect()
                blockedConnection = nil

                -- recompute new path
                followPath(humanoid, customerInfo, startPos, finishPos)
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

                    -- if customer has spawned in
                    coroutine.resume(customerLifecycle, customerModel, customerInfo)

                    -- resume coroutine to remove customer after order has been fulfilled
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
    local plrFolder = Workspace.TempAssets.Jobs.CashierJob:FindFirstChild(localPlr.UserId)
    if not plrFolder then plrFolder = Instance.new("Folder", Workspace.TempAssets.Jobs.CashierJob) end
    plrFolder.Name = localPlr.UserId
    local npcFolder = plrFolder:FindFirstChild("Npcs")
    if not npcFolder then npcFolder = Instance.new("Folder", plrFolder) end
    npcFolder.Name = "Npcs"

    customerModel.Parent = npcFolder
    customerModel.PrimaryPart.Position = npcSpawnPart.Position

    followPath(customerModel, customerInfo, npcSpawnPart.Position, npcDestinationPart.Position)
end)

Remotes.Jobs.EndShift.OnClientEvent:Connect(function(jobType)
    if jobType == "cashierJob" then
        cleanUpJob(localPlr)
    end
end)