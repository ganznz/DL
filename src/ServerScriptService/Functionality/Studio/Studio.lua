local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local StudioConfig = require(ReplicatedStorage.Configs.Studio)
local Zone = require(ReplicatedStorage.Libs.Zone)

local Remotes = ReplicatedStorage.Remotes

local Studio = {}

function Studio.PurchaseNextStudio(plr: Player)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local plrData = profile.Data

    local currentPlrStudioLevel = StudioConfig.GetPlrStudioLevel(plrData)

    -- check if plr already has every studio unlocked
    if StudioConfig.HasLastStudio(plrData) then return "You already own every studio!" end

    local nextPlrStudioLevel = currentPlrStudioLevel + 1
    local nextStudioConfig = StudioConfig.GetConfig(nextPlrStudioLevel)

    -- attempt to purchase studio
    local plrCash = plrData.Cash
    local studioUpgradePrice = nextStudioConfig.Price

    local canAfford = StudioConfig.CanPurchaseNextStudio(plrData)
    if not canAfford then return "You need " .. tostring(studioUpgradePrice - plrCash) .. " more cash!" end

    -- can afford, purchase studio
    PlrDataManager.AdjustPlrCash(plr, -studioUpgradePrice)
    profile.Data.Studio.CurrentActiveStudio = nextPlrStudioLevel
    table.insert(profile.Data.Studio.Studios, { Furnishings = {} })

    Remotes.Purchase.PurchaseComputer:FireClient(plr, nextPlrStudioLevel)

    return "Purchased " .. nextStudioConfig.Name .. "!"
end

local numOfStudios = #(StudioConfig.Config)
repeat task.wait() until #(CollectionService:GetTagged("Studio")) == numOfStudios
local studioExteriorsFolder = CollectionService:GetTagged("Studio")

-- register studio exterior teleports
for _i, studioFolder in studioExteriorsFolder do
    local studioIndex = tonumber(studioFolder.Name)

    local teleportHitbox: Model = studioFolder:FindFirstChild("TeleportHitboxZone", true)
    local zone = Zone.new(teleportHitbox)
    
    zone.playerEntered:Connect(function(plr: Player)
        local profile = PlrDataManager.Profiles[plr]
        if not profile then return end
        local plrData = profile.Data

        local studioInteriorFolder = 

        -- check if plr owns the studio
        -- if so, teleport player into studio, else show studio purchase prompt
        if StudioConfig.OwnsStudio(plrData, studioIndex) then
            Remotes.GUI.ChangeGuiStatusRemote:FireClient(plr, "loadingBgSplash", true, { TeleportPart = teleportToPart })
            -- local teleportToPart = studioFolder

        else
            -- show studio purchase prompt
        end


    end)
end

-- populate game workspace with studio interiors for each player

return Studio