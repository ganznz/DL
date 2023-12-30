local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local StudioConfig = require(ReplicatedStorage.Configs.Studio.Studio)
local DatastoreUtils = require(ReplicatedStorage.Utils.DS.DatastoreUtils)

local StudioPlaceables = {}

-- function for saving a placed essential items (e.g. computer, shelf) data to plr data
function StudioPlaceables.StoreEssentialItemData(plr: Player, itemInfo: {}, studioIndex)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local plrData = profile.Data

    local studioConfig = StudioConfig.GetConfig(studioIndex)
    if not studioConfig then return end

    local studioType: "Standard" | "Premium" = studioConfig.StudioType

    local itemData = {}
    itemData.CFrame = DatastoreUtils.CFrameToTable(itemInfo.RelativeCFrame)

    plrData.Studio.Studios[studioType][studioIndex].StudioEssentials[itemInfo.ItemName] = itemData
end

return StudioPlaceables