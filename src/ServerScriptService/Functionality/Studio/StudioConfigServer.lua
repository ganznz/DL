local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local PlayerManagerConfig = require(ServerScriptService.Functionality.Player.PlayerManager)
local StudioConfig = require(ReplicatedStorage.Configs.Studio.Studio)
local DatastoreUtils = require(ReplicatedStorage.Utils.DS.DatastoreUtils)

local Remotes = ReplicatedStorage.Remotes

local Studio = {}

-- table keeps track of all players in the server and their respective studio information
-- { [plr.UserId] = { StudioIndex: string, StudioStatus: "open" | "closed" | "friends" } }
Studio.PlrStudios = {}

-- table keeps track of players who are in a studio
-- { [plr.UserId] = { PlrVisitingId: number, StudioIndex: string } | false }
Studio.PlrsInStudio = {}

function Studio.InitializeStudioData(plr: Player, studioType: "Standard" | "Premium", studioIndex: string)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    -- computer & shelf cframe data
    local studioInteriorModel = ReplicatedStorage.Assets.Models.Studio.Studios:FindFirstChild(studioIndex):FindFirstChild("Interior")
    local studioInteriorPlot = studioInteriorModel:FindFirstChild("Plot")
    local plotCFrame = studioInteriorPlot.CFrame
    local computerCFrame = studioInteriorModel:FindFirstChild("Computer").PrimaryPart.CFrame
    local shelfCFrame = studioInteriorModel:FindFirstChild("Shelf").PrimaryPart.CFrame


    profile.Data.Studio.Studios[studioType][studioIndex] = {
        Furnishings = {
            Mood = {},
            Energy = {},
            Hunger = {},
            Decor = {},
            Special = {},
        },

        -- initialize computer & shelf cframe data relative to plot in datastore
        StudioEssentials = {
            Computer = { CFrame = DatastoreUtils.CFrameToTable(plotCFrame:ToObjectSpace(computerCFrame)) },
            Shelf = { CFrame = DatastoreUtils.CFrameToTable(plotCFrame:ToObjectSpace(shelfCFrame)) }
        },

        StaffMembers = {},
    }
end

-- function only for purchasing Standard studios, not Premium (gamepass) studios
function Studio.PurchaseNextStudio(plr: Player): boolean
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local plrData = profile.Data

    local currentPlrStudioLevel = StudioConfig.GetPlrStudioLevel(plrData)
    -- check if plr already has every studio unlocked
    if StudioConfig.HasLastStudio(plrData) then return false end

    local newStudioIndex = tostring(currentPlrStudioLevel + 1)
    local nextStudioConfig = StudioConfig.GetConfig(newStudioIndex)

    -- attempt to purchase studio
    local studioUpgradePrice = nextStudioConfig.Price
    local canAfford = StudioConfig.CanPurchaseNextStudio(plrData)
    if not canAfford then return false end

    -- can afford, purchase studio
    PlayerManagerConfig.AdjustPlrCoins(plr, -studioUpgradePrice)
    profile.Data.Studio.ActiveStudio = newStudioIndex
    PlayerManagerConfig.UnlockArea(plr, 'Studio'..tostring(newStudioIndex))

    -- insert new studio information into plr data
    Studio.InitializeStudioData(plr, "Standard", newStudioIndex)

    Remotes.Purchase.PurchaseStudio:FireClient(plr, newStudioIndex)

    -- update studio list GUI for all plrs
    Studio.PlrStudios[plr.UserId]["StudioIndex"] = profile.Data.Studio.ActiveStudio
    Remotes.GUI.Studio.UpdateStudioList:FireAllClients(plr.UserId, "update", Studio.PlrStudios[plr.UserId])

    -- teleport player into their new studio
    Remotes.Studio.General.VisitOwnStudioBindable:Fire(plr)

    -- teleport all visitors that were in the old studio, into the new purchased studio
    local plrsInStudio = Studio.PlrsInStudio
    for plrUserId: number, studioVisitingInfo: {} | false in plrsInStudio do
        if plrUserId == plr.UserId then continue end
        if not studioVisitingInfo then continue end

        if studioVisitingInfo.PlrVisitingId == plr.UserId then
            Remotes.Studio.General.VisitOtherStudioBindable:Fire(Players:GetPlayerByUserId(plrUserId), plr.UserId)
        end
    end

    return true
end

Remotes.Studio.General.GetStudioPlrInfo.OnServerInvoke = function()
    return Studio.PlrStudios
end

Remotes.Studio.General.GetPlrsInStudioInfo.OnServerInvoke = function()
    return Studio.PlrsInStudio
end

return Studio