local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local StudioConfig = require(ReplicatedStorage.Configs.Studio)
local Remotes = ReplicatedStorage.Remotes

local Studio = {}

function Studio.PurchaseNextStudio(plr: Player): boolean
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local plrData = profile.Data

    local currentPlrStudioLevel = StudioConfig.GetPlrStudioLevel(plrData)

    -- check if plr already has every studio unlocked
    -- if StudioConfig.HasLastStudio(plrData) then return "You already own every studio!" end
    if StudioConfig.HasLastStudio(plrData) then return false end

    local nextPlrStudioLevel = currentPlrStudioLevel + 1
    local nextStudioConfig = StudioConfig.GetConfig(nextPlrStudioLevel)

    -- attempt to purchase studio
    local plrCash = plrData.Cash
    local studioUpgradePrice = nextStudioConfig.Price

    local canAfford = StudioConfig.CanPurchaseNextStudio(plrData)
    -- if not canAfford then return "You need " .. tostring(studioUpgradePrice - plrCash) .. " more cash!" end
    if not canAfford then return false end

    -- can afford, purchase studio
    PlrDataManager.AdjustPlrCash(plr, -studioUpgradePrice)
    profile.Data.Studio.ActiveStudio = nextPlrStudioLevel
    PlrDataManager.UnlockArea(plr, 'Studio'..tostring(nextPlrStudioLevel))

    -- insert new studio information into plr data
    table.insert(profile.Data.Studio.Studios, {
        Furnishings = {
            Mood = {},
            Energy = {},
            Hunger = {},
            Decor = {},
        }
    })

    Remotes.Purchase.PurchaseStudio:FireClient(plr, nextPlrStudioLevel)

    -- return "Purchased " .. nextStudioConfig.Name .. "!"
    return true
end

function Studio.ItemAvailableToPlace(plr: Player, itemName: string, itemCategory: string)
    
end

return Studio