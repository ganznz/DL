local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local StudioConfig = require(ReplicatedStorage.Configs.Studio)
local Zone = require(ReplicatedStorage.Libs.Zone)

local Remotes = ReplicatedStorage.Remotes

local numOfStudios = #(StudioConfig.Config)
repeat task.wait() until #(CollectionService:GetTagged("Studio")) == numOfStudios
local studioExteriorsFolder = CollectionService:GetTagged("Studio")

-- table keeps track of all players in the server and if they're in a studio or not
-- { [plr.UserId] = { studioOwnerId: number, studioIndex: number }, else false }
local plrsInStudio = {}

-- make changes to 'plrsInStudio' table
Players.PlayerAdded:Connect(function(plr: Player)
    if not plrsInStudio[plr.UserId] then
        plrsInStudio[plr.UserId] = false
    end
end)

-- generate studio interior player tp parts
for _i, studioFolder in studioExteriorsFolder do
    -- part that studio interior model pivots to
    local interiorTpToPart = studioFolder:FindFirstChild("InteriorTeleportPart")

    -- generate part that plr teleports to when visiting studio
    local tpPart = Instance.new("Part")
    tpPart.Name = "PlrTeleportToPartInterior"
    tpPart.Anchored = true
    tpPart.CanCollide = false
    tpPart.Transparency = 1
    tpPart.Parent = studioFolder
    tpPart.CFrame = interiorTpToPart.CFrame
    tpPart:SetAttribute("AreaAccessibility", "General")  -- this value doesn't matter
    tpPart:SetAttribute("AreaName", "Studio"..studioFolder.Name)
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
            -- set plr current active studio to the studio they interacted with
            profile.Data.Studio.ActiveStudio = studioIndex

            local interiorPlayerTpPart = studioFolder:FindFirstChild("PlrTeleportToPartInterior")
            local exteriorPlayerTpPart = studioFolder:FindFirstChild("TeleportToPart")

            plrsInStudio[plr.UserId] = {
                PlrId = plr.UserId,
                StudioIndex = studioIndex
            }

            Remotes.Studio.VisitOwnStudio:FireClient(plr, plrData, interiorPlayerTpPart, exteriorPlayerTpPart)
        else
            -- show studio purchase prompt
        end
    end)
end