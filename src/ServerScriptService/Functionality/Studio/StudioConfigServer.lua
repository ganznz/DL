local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local StudioConfig = require(ReplicatedStorage.Configs.Studio)
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
    PlrDataManager.UnlockArea(plr, 'Studio'..tostring(nextPlrStudioLevel))
    table.insert(profile.Data.Studio.Studios, { Furnishings = {} })

    Remotes.Purchase.PurchaseComputer:FireClient(plr, nextPlrStudioLevel)

    return "Purchased " .. nextStudioConfig.Name .. "!"
end

return Studio