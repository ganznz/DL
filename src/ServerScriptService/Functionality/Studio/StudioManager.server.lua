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

-- table keeps track of all players in the server and their respective studio information
-- { [plr.UserId] = { studioIndex: number, studioStatus: "open" | "closed" | "friends" } }
local plrStudios = {}

-- table keeps track of players who are in a studio
-- { [plr.UserId] = { studioOwnerId: number, studioIndex: number } | false }
local plrsInStudio = {}

Players.PlayerAdded:Connect(function(plr: Player)
    repeat task.wait() until PlrDataManager.Profiles[plr]

    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    plrStudios[plr.UserId] = {
        StudioIndex = profile.Data.Studio.ActiveStudio,
        StudioStatus = profile.Data.Studio.StudioStatus,
    }

    plrsInStudio[plr.UserId] = false

    Remotes.GUI.Studio.UpdateStudioList:FireAllClients(plr.UserId, "add", plrStudios[plr.UserId])
end)

Players.PlayerRemoving:Connect(function(plr)
    plrStudios[plr.UserId] = nil
    plrsInStudio[plr.UserId] = nil

    Remotes.GUI.Studio.UpdateStudioList:FireAllClients(plr.UserId, "remove", nil)
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
    else
        Remotes.Studio.VisitOtherStudio:FireClient(plr, studioIndex, interiorPlayerTpPart, exteriorPlayerTpPart)
    end
end

local function updateStudioWhitelist(plr: Player): string
    local plrStudioInfo = plrStudios[plr.UserId]
    if not plrStudioInfo then return end

    local currentWhitelistSetting = plrStudioInfo.StudioStatus
    if currentWhitelistSetting ==  "open" then
        plrStudios[plr.UserId].StudioStatus = "friends"
    elseif currentWhitelistSetting == "friends" then
        plrStudios[plr.UserId].StudioStatus = "closed"
    elseif currentWhitelistSetting == "closed" then
        plrStudios[plr.UserId].StudioStatus = "open"
    end

    return plrStudios[plr.UserId].StudioStatus
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

Remotes.Studio.VisitOwnStudio.OnServerEvent:Connect(function(plr: Player)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local studioIndex = profile.Data.Studio.ActiveStudio

    visitStudio(plr, plr, studioIndex)
end)

Remotes.Studio.VisitOtherStudio.OnServerEvent:Connect(function(plr: Player, userIdOfPlrToVisit: number)
    if not plrStudios[plr.UserId] then return end

    local plrToVisit: Player = Players:GetPlayerByUserId(userIdOfPlrToVisit)
    if not plrToVisit then return end

    local profile = PlrDataManager.Profiles[plrToVisit]
    if not profile then return end

    local studioIndex = profile.Data.Studio.ActiveStudio

    visitStudio(plr, plrToVisit, studioIndex)
end)

Remotes.Studio.LeaveStudio.OnServerEvent:Connect(function(plr: Player)
    plrsInStudio[plr.UserId] = false

    -- switch left-side gui btn from build-mode to tp btn
    Remotes.Studio.LeaveStudio:FireClient(plr)
end)

Remotes.Studio.PurchaseNextStudio.OnServerEvent:Connect(function(plr: Player)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local purchased = StudioConfigServer.PurchaseNextStudio(plr)
    if purchased then
        plrStudios[plr.UserId]["StudioIndex"] = profile.Data.Studio.ActiveStudio
        Remotes.GUI.Studio.UpdateStudioList:FireAllClients(plr.UserId, "update", plrStudios[plr.UserId])
    end
end)

Remotes.Studio.GetStudioPlrInfo.OnServerInvoke = function()
    return plrStudios
end

Remotes.Studio.UpdateWhitelist.OnServerEvent:Connect(function(plr: Player)
    local newWhitelistSetting = updateStudioWhitelist(plr)

    -- update new whitelist setting visually for plr
    Remotes.Studio.UpdateWhitelist:FireClient(plr, newWhitelistSetting)

    -- update new whitelist setting on all client Studio Lists
    Remotes.GUI.Studio.UpdateStudioList:FireAllClients(plr.UserId, "update", plrStudios[plr.UserId])
end)