local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlobalVariables = require(ReplicatedStorage:WaitForChild("GlobalVariables"))
local Zone = require(ReplicatedStorage.Libs.Zone)

local Remotes = ReplicatedStorage.Remotes
local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

local StudioExteriorsFolder = Workspace:WaitForChild("Map").Buildings.Studios
local StudioInteriorsFolder = ReplicatedStorage:WaitForChild("Assets").Models.Studios

local currentStudioIndex = nil
local studioInteriorFolder = nil
local studioInteriorExitZone = nil

-- make a copy of all studio exteriors, so when player leaves a studio and
-- needs to make the studio exterior visible again, copy it from this table
-- and put it back into the workspace 'StudioExteriorsFolder'
local studioExteriorsCopy = {}
for _i, studioExteriorFolder in StudioExteriorsFolder:GetChildren() do
    studioExteriorsCopy[tonumber(studioExteriorFolder.Name)] = studioExteriorFolder:Clone()
end

local function calculateYOffset(model: Model): number
    if not model:IsA("Model") then return end

    return model.PrimaryPart.Size.Y / 2
end

local function enterStudio(interiorPlrTpPart)
    -- tp plr into studio interior
    Remotes.GUI.ChangeGuiStatusBindable:Fire("loadingBgSplash", true, { TeleportPart = interiorPlrTpPart })

    local studioExteriorFolder = StudioExteriorsFolder:FindFirstChild(currentStudioIndex)
    local interiorTpPart = studioExteriorFolder:FindFirstChild("InteriorTeleportPart")

    studioInteriorFolder.Name = plr.UserId
    local studioInteriorModel = studioInteriorFolder:FindFirstChild("Interior")
    
    local yOffset = calculateYOffset(studioInteriorModel)

    task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
        studioInteriorModel:PivotTo(interiorTpPart.CFrame * CFrame.new(0, yOffset, 0))
        studioExteriorFolder:Destroy() -- hide studio exterior from players view
        studioInteriorFolder.Parent = Workspace.TempAssets.Studios
    end)
end

-- when plr exists studio, destroy all traces of the studio interior
local function destroyInterior()
    studioInteriorExitZone:destroy()
    studioInteriorFolder:Destroy()
end

local function regenerateExterior()
    local replacedStudioExterior = studioExteriorsCopy[currentStudioIndex]:Clone()
    replacedStudioExterior.Parent = Workspace.Map.Buildings.Studios
end

local function studioInteriorExitListener(exteriorPlrTpPart)
    local studioInteriorExitHitbox = studioInteriorFolder:FindFirstChild("TeleportHitboxZone", true)

    studioInteriorExitZone = Zone.new(studioInteriorExitHitbox)
    studioInteriorExitZone.localPlayerEntered:Connect(function(_plr: Player)
        Remotes.GUI.ChangeGuiStatusBindable:Fire("loadingBgSplash", true, { TeleportPart = exteriorPlrTpPart })
        Remotes.Studio.LeaveStudio:FireServer()

        task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
            destroyInterior()
            regenerateExterior()
        end)
    end)
end

Remotes.Studio.VisitOwnStudio.OnClientEvent:Connect(function(studioIndex, interiorPlrTpPart, exteriorPlrTpPart)
    currentStudioIndex = studioIndex
    studioInteriorFolder = StudioInteriorsFolder:FindFirstChild(currentStudioIndex):Clone()

    enterStudio(interiorPlrTpPart)

    -- listener for when player exits studio
    studioInteriorExitListener(exteriorPlrTpPart)

end)

Remotes.Studio.VisitOtherStudio.OnClientEvent:Connect(function(studioIndex, interiorPlrTpPart, exteriorPlrTpPart)
    currentStudioIndex = studioIndex
    studioInteriorFolder = StudioInteriorsFolder:FindFirstChild(currentStudioIndex):Clone()

    enterStudio(interiorPlrTpPart)

    -- listener for when player exits studio
    studioInteriorExitListener(exteriorPlrTpPart)
end)

-- Remotes.Studio.LeaveStudio.OnClientEvent:Connect(function(studioIndex)
--     destroyInterior()
--     regenerateExterior(studioIndex)
--     Remotes.Studio.LeaveStudio:FireServer()
-- end)

humanoid.Died:Connect(function()
    destroyInterior()
    regenerateExterior(currentStudioIndex)
    Remotes.Studio.LeaveStudio:FireServer()
end)

plr.CharacterAdded:Connect(function(character: Model)
    char = character
    humanoid = char:WaitForChild("Humanoid")
end)

local PlayerGui = plr.PlayerGui

local aaaa = PlayerGui:WaitForChild("BuildMode"):WaitForChild("TextButton")
aaaa.Activated:Connect(function()
    Remotes.Studio.PurchaseNextStudio:FireServer()
end)