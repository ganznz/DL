local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes
local StudioExteriorsFolder = Workspace:WaitForChild("Map").Buildings.Studios
local StudioInteriorsFolder = ReplicatedStorage:WaitForChild("Assets").Models.Studios
local Zone = require(ReplicatedStorage.Libs.Zone)

local plr = Players.LocalPlayer


-- make a copy of all studio exteriors, so when player leaves a studio and
-- needs to make the studio exterior visible again, copy it from this table
-- and put it back into the workspace 'StudioExteriorsFolder'
local studioExteriorsCopy = {}
for _i, studioExteriorFolder in StudioExteriorsFolder:GetChildren() do
    studioExteriorsCopy[tonumber(studioExteriorFolder.Name)] = studioExteriorFolder:Clone()
end

Remotes.Studio.VisitOwnStudio.OnClientEvent:Connect(function(plrData, interiorPlrTpPart, exteriorPlrTpPart)
    local plrStudioIndex = plrData.Studio.ActiveStudio

    local studioExteriorFolder = StudioExteriorsFolder:FindFirstChild(plrStudioIndex)
    local interiorTpPart = studioExteriorFolder:FindFirstChild("InteriorTeleportPart")

    local studioInteriorFolder = StudioInteriorsFolder:FindFirstChild(plrStudioIndex):Clone()
    studioInteriorFolder.Name = plr.UserId

    local teleportHitbox = studioInteriorFolder:FindFirstChild("TeleportHitboxZone", true)
    local zone = Zone.new(teleportHitbox)
    
    zone.playerEntered:Connect(function(plr: Player)
        Remotes.GUI.ChangeGuiStatusBindable:Fire("loadingBgSplash", true, { TeleportPart = exteriorPlrTpPart })
        zone:destroy()
        studioInteriorFolder:Destroy()
        local replacedStudioExterior = studioExteriorsCopy[plrStudioIndex]:Clone()
        replacedStudioExterior.Parent = Workspace.Map.Buildings.Studios
    end)

    local studioInteriorModel = studioInteriorFolder:FindFirstChild("Interior")

    studioInteriorModel:PivotTo(interiorTpPart.CFrame)
    studioExteriorFolder:Destroy() -- hide studio exterior from players view
    studioInteriorFolder.Parent = Workspace.TempAssets.Studios
    
    Remotes.GUI.ChangeGuiStatusBindable:Fire("loadingBgSplash", true, { TeleportPart = interiorPlrTpPart })

end)

local PlayerGui = plr.PlayerGui

local aaaa = PlayerGui:WaitForChild("BuildMode"):WaitForChild("TextButton")
aaaa.Activated:Connect(function()
    Remotes.Studio.PurchaseNextStudio:FireServer()
end)