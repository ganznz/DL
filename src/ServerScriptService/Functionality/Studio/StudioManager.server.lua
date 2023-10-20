local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local StudioConfig = require(ReplicatedStorage.Configs.Studio)
local StudioConfigServer = require(script.Parent.StudioConfigServer)
local Zone = require(ReplicatedStorage.Libs.Zone)

local Remotes = ReplicatedStorage.Remotes

local numOfStudios = #(StudioConfig.Config)
repeat task.wait() until #(CollectionService:GetTagged("Studio")) == numOfStudios
local studioExteriorsFolder = CollectionService:GetTagged("Studio")

-- table keeps track of all players in the server and if they're in a studio or not
-- { [plr.UserId] = { studioOwnerId: number, studioIndex: number }, else false }
local plrsInStudio = {}

Players.PlayerAdded:Connect(function(plr: Player)
    if not plrsInStudio[plr.UserId] then
        plrsInStudio[plr.UserId] = false
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    plrsInStudio[plr.UserId] = nil
end)

-- generate studio interior player tp parts
for _i, exteriorStudioFolder in studioExteriorsFolder do
    -- part that studio interior model pivots to
    -- plr tp part that gets generated will share same x,y coords as this so plr gets tp'd to center of studio
    local interiorTpToPart = exteriorStudioFolder:FindFirstChild("InteriorTeleportPart")

    -- generate part that plr teleports to when visiting studio
    local tpPart = Instance.new("Part")
    tpPart.Name = "PlrTeleportToPartInterior"
    tpPart.Anchored = true
    tpPart.CanCollide = false
    tpPart.Transparency = 1
    tpPart.Parent = exteriorStudioFolder
    tpPart.CFrame = interiorTpToPart.CFrame * CFrame.new(0, 7, 0) -- adjust Y-coord to prevent player clipping into studio interior floor/tp below studio
    tpPart:SetAttribute("AreaAccessibility", "General")  -- this value doesn't matter
    tpPart:SetAttribute("AreaName", "Studio"..exteriorStudioFolder.Name)
end



local function visitStudio(plr: Player, plrToVisit: Player, studioIndex: number)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local studioExteriorFolder = Workspace.Map.Buildings.Studios:FindFirstChild(tostring(studioIndex))
    local interiorPlayerTpPart = studioExteriorFolder:FindFirstChild("PlrTeleportToPartInterior")
    local exteriorPlayerTpPart = studioExteriorFolder:FindFirstChild("TeleportToPart")

    plrsInStudio[plr.UserId] = {
        PlrId = plr.UserId,
        StudioIndex = studioIndex
    }

    if plr == plrToVisit then
        profile.Data.Studio.ActiveStudio = studioIndex
        Remotes.Studio.VisitOwnStudio:FireClient(plr, studioIndex, interiorPlayerTpPart, exteriorPlayerTpPart)
    end
end


-- register studio exterior teleports
for _i, studioFolder in studioExteriorsFolder do
    local studioIndex = tonumber(studioFolder.Name)
    
    local teleportHitbox: Model = studioFolder:FindFirstChild("TeleportHitboxZone", true)
    local zone = Zone.new(teleportHitbox)
    
    zone.playerEntered:Connect(function(plr: Player)
        local profile = PlrDataManager.Profiles[plr]
        if not profile then return end
        local plrData = profile.Data

        -- check if plr owns the studio
        -- if so, teleport player into studio, else show studio purchase prompt
        if StudioConfig.OwnsStudio(plrData, studioIndex) then
            visitStudio(plr, plr, studioIndex)
        else
            -- show studio purchase prompt
        end
    end)
end

Remotes.Studio.PurchaseNextStudio.OnServerEvent:Connect(function(plr: Player)
    StudioConfigServer.PurchaseNextStudio(plr)
end)