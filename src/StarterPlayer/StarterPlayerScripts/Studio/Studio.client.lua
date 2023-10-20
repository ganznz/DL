local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlobalVariables = require(ReplicatedStorage:WaitForChild("GlobalVariables"))
local Zone = require(ReplicatedStorage.Libs.Zone)

local Remotes = ReplicatedStorage.Remotes
local plr = Players.LocalPlayer

local StudioExteriorsFolder = Workspace:WaitForChild("Map").Buildings.Studios
local StudioInteriorsFolder = ReplicatedStorage:WaitForChild("Assets").Models.Studios


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

local function showStudioInterior(studioIndex, studioInteriorFolder, interiorPlrTpPart)
    -- tp plr into studio interior
    Remotes.GUI.ChangeGuiStatusBindable:Fire("loadingBgSplash", true, { TeleportPart = interiorPlrTpPart })

    local studioExteriorFolder = StudioExteriorsFolder:FindFirstChild(studioIndex)
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

-- when plr leaves studio, remove studio interior and replace with exterior
local function showStudioExterior(studioIndex, studioInteriorFolder, exteriorPlrTpPart)
    local studioInteriorExitHitbox = studioInteriorFolder:FindFirstChild("TeleportHitboxZone", true)

    local zone = Zone.new(studioInteriorExitHitbox)

    zone.playerEntered:Connect(function(_plr: Player)
        Remotes.GUI.ChangeGuiStatusBindable:Fire("loadingBgSplash", true, { TeleportPart = exteriorPlrTpPart })

        task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
            zone:destroy()
            studioInteriorFolder:Destroy()
            local replacedStudioExterior = studioExteriorsCopy[studioIndex]:Clone()
            replacedStudioExterior.Parent = Workspace.Map.Buildings.Studios
        end)
    end)
end

Remotes.Studio.VisitOwnStudio.OnClientEvent:Connect(function(studioIndex, interiorPlrTpPart, exteriorPlrTpPart)
    local studioInteriorFolder = StudioInteriorsFolder:FindFirstChild(studioIndex):Clone()

    showStudioInterior(studioIndex, studioInteriorFolder, interiorPlrTpPart)

    -- listener for when player exists studio
    showStudioExterior(studioIndex, studioInteriorFolder, exteriorPlrTpPart)

end)

local PlayerGui = plr.PlayerGui

local aaaa = PlayerGui:WaitForChild("BuildMode"):WaitForChild("TextButton")
aaaa.Activated:Connect(function()
    Remotes.Studio.PurchaseNextStudio:FireServer()
end)