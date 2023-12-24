local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local StudioConfig = require(ReplicatedStorage.Configs.Studio.Studio)
local StudioPlaceablesServer = require(ServerScriptService.Functionality.Studio.StudioPlaceablesConfigServer)
local StudioConfigServer = require(script.Parent.StudioConfigServer)
local Zone = require(ReplicatedStorage.Libs.Zone)

local Remotes = ReplicatedStorage.Remotes
local studioExteriorsFolder = CollectionService:GetTagged("Studio")

Players.PlayerAdded:Connect(function(plr: Player)
    repeat task.wait() until PlrDataManager.Profiles[plr]

    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    -- if it's players first time joining the game, establish first studio data
    StudioConfigServer.InitializeStudioData(plr, "Standard", "1")

    StudioConfigServer.PlrStudios[plr.UserId] = {
        StudioIndex = profile.Data.Studio.ActiveStudio,
        StudioStatus = profile.Data.Studio.StudioStatus,
    }

    StudioConfigServer.PlrsInStudio[plr.UserId] = false
    Remotes.GUI.Studio.UpdateStudioList:FireAllClients(plr.UserId, "add", StudioConfigServer.PlrStudios[plr.UserId])
end)

Players.PlayerRemoving:Connect(function(plr)
    StudioConfigServer.PlrStudios[plr.UserId] = nil
    StudioConfigServer.PlrsInStudio[plr.UserId] = nil

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
    tpPart:SetAttribute("AreaAccessibility", "General")  -- set to "General" so plrs can tp into other plrs studios.
    tpPart:SetAttribute("AreaName", "Studio"..exteriorStudioFolder.Name)
end

local function visitStudio(plr: Player, plrToVisit: Player, studioIndex: string)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local studioExteriorFolder = Workspace.Map.Buildings.Studios:FindFirstChild(tostring(studioIndex))
    local interiorPlayerTpPart = studioExteriorFolder:FindFirstChild("PlrTeleportToPartInterior")
    local exteriorPlayerTpPart = studioExteriorFolder:FindFirstChild("TeleportToPart")

    local alreadyPlacedFurnitureData = StudioPlaceablesServer.AlreadyPlacedFurnitureData(plrToVisit, studioIndex)
    if plr == plrToVisit then
        profile.Data.Studio.ActiveStudio = studioIndex
        StudioConfigServer.PlrStudios[plrToVisit.UserId].StudioIndex = profile.Data.Studio.ActiveStudio

        StudioConfigServer.PlrsInStudio[plr.UserId] = {
            PlrVisitingId = plr.UserId,
            StudioIndex = studioIndex
        }
        Remotes.Studio.General.VisitOwnStudio:FireClient(plr, plr.UserId, studioIndex, interiorPlayerTpPart, exteriorPlayerTpPart, alreadyPlacedFurnitureData)
    else
        StudioConfigServer.PlrsInStudio[plr.UserId] = {
            PlrVisitingId = plrToVisit.UserId,
            StudioIndex = studioIndex
        }
        Remotes.Studio.General.VisitOtherStudio:FireClient(plr, plrToVisit.UserId, studioIndex, interiorPlayerTpPart, exteriorPlayerTpPart, alreadyPlacedFurnitureData)
    end
end

local function updateStudioWhitelist(plr: Player): "open" | "closed" | "friends"
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local plrStudioInfo = StudioConfigServer.PlrStudios[plr.UserId]
    if not plrStudioInfo then return end

    local currentWhitelistSetting = plrStudioInfo.StudioStatus
    if currentWhitelistSetting ==  "open" then
        StudioConfigServer.PlrStudios[plr.UserId].StudioStatus = "friends"
    elseif currentWhitelistSetting == "friends" then
        StudioConfigServer.PlrStudios[plr.UserId].StudioStatus = "closed"
    elseif currentWhitelistSetting == "closed" then
        StudioConfigServer.PlrStudios[plr.UserId].StudioStatus = "open"
    end

    profile.Data.Studio.StudioStatus = StudioConfigServer.PlrStudios[plr.UserId].StudioStatus
    return profile.Data.Studio.StudioStatus
end

local function canVisitStudio(plr: Player, plrToVisit: Player): boolean
    if not StudioConfigServer.PlrStudios[plr.UserId] then return end

    local whitelistSetting = StudioConfigServer.PlrStudios[plrToVisit.UserId].StudioStatus
    if whitelistSetting == "friends" and plr:IsFriendsWith(plrToVisit.UserId) then
        return true
    elseif whitelistSetting == "open" then
        return true
    end

    return false
end

local function kickAllPlrsFromStudio(plrWhosStudioToClear: Player, ignoreFriends: boolean)
    for plrUserId, studioInfo in StudioConfigServer.PlrsInStudio do

        -- if studioInfo exists then it means the plr is in a studio
        if studioInfo then
            -- ignore studio owner
            if plrUserId == plrWhosStudioToClear.UserId then continue end

            -- check if the studio the plr is in matches with who fired this remote
            if studioInfo.PlrVisitingId == plrWhosStudioToClear.UserId then
                local plrToKick: Player = Players:GetPlayerByUserId(plrUserId)
                if plrToKick then
                    if ignoreFriends and plrToKick:IsFriendsWith(plrWhosStudioToClear.UserId) then continue end

                    StudioConfigServer.PlrsInStudio[plrToKick.UserId] = false
                    Remotes.Studio.General.KickFromStudio:FireClient(plrToKick)
                    Remotes.GUI.DisplayNotification:FireClient(plrToKick, "general", string.format("%s has removed you from their studio", plrWhosStudioToClear.Name))
                end
            end
        end
    end
end

-- register studio exterior teleports
for _i, studioFolder in studioExteriorsFolder do
    local studioIndex = studioFolder.Name
    
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

-- function for replicating placed item to all plrs currently in studio
-- plr, additionalParams.Action, "furniture", itemInfo
local function replicatePlaceItem(studioOwner: Player, action: "newItem" | "move", itemType: string, itemInfo: {})
    for plrUserId, studioInfo in StudioConfigServer.PlrsInStudio do
        if plrUserId == studioOwner.UserId then continue end

        if studioInfo then
            if studioInfo.PlrVisitingId == studioOwner.UserId then
                local plrToUpdate: Player = Players:GetPlayerByUserId(plrUserId)

                Remotes.Studio.BuildMode.ReplicatePlaceItem:FireClient(plrToUpdate, itemType, itemInfo)

                -- if the item got moved, delete the 'old' model
                if action == "move" then Remotes.Studio.BuildMode.RemoveItem:FireClient(plrToUpdate, itemType, itemInfo) end
            end
        end
    end
end

local function placeFurnitureItem(plr, itemInfo, additionalParams)
    local modelCategoryFolder = ReplicatedStorage.Assets.Models.Studio.StudioFurnishing[itemInfo.ItemCategory]
    if not modelCategoryFolder then return end

    local plrStudioInfo = StudioConfigServer.PlrStudios[plr.UserId]
    if not plrStudioInfo then return end

    -- place and store item data as a new item
    if additionalParams.Action == "newItem" then
        if not StudioPlaceablesServer.HasFurnitureItem(plr, itemInfo, plrStudioInfo.StudioIndex, false) then return end

        itemInfo.ItemUUID = StudioPlaceablesServer.StoreFurnitureItemData(plr, itemInfo, plrStudioInfo.StudioIndex)

    elseif additionalParams.Action == "move" then
        -- item was previously placed, only update item data
        StudioPlaceablesServer.UpdateFurnitureItemData(plr, itemInfo, plrStudioInfo.StudioIndex)
    end

    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    -- data that gets sent to client to populate build mode gui with
    local studioFurnitureInventory = StudioConfig.GetFurnitureAvailableForStudio(profile.Data)

    Remotes.Studio.BuildMode.PlaceItem:FireClient(plr, "furniture", itemInfo)
    Remotes.Studio.BuildMode.ExitPlaceMode:FireClient(plr, studioFurnitureInventory)

    -- replicate to others in studio
    replicatePlaceItem(plr, additionalParams.Action, "furniture", itemInfo)
end

local function placeEssentialItem(plr, itemInfo, additionalParams)
    local plrStudioInfo = StudioConfigServer.PlrStudios[plr.UserId]
    if not plrStudioInfo then return end

    StudioPlaceablesServer.StoreEssentialItemData(plr, itemInfo, plrStudioInfo.StudioIndex)

    Remotes.Studio.BuildMode.PlaceItem:FireClient(plr, "essential", itemInfo)
    Remotes.Studio.BuildMode.ExitPlaceMode:FireClient(plr)

    -- replicate to others in studio
    replicatePlaceItem(plr, additionalParams.Action, "essential", itemInfo)
end

-- STUDIO BUILD MODE FUNCTIONALITY
local function placeStudioItem(plr: Player, itemType: "furniture" | "essential", itemInfo, additionalParams): boolean
    if itemType == "furniture" then
        placeFurnitureItem(plr, itemInfo, additionalParams)
    
    elseif itemType == "essential" then
        placeEssentialItem(plr, itemInfo, additionalParams)
    end
end

-- function stores placed item back in inventory
local function storeStudioItem(plr: Player, itemType: string, itemInfo: {})
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local plrStudioInfo = StudioConfigServer.PlrStudios[plr.UserId]
    if not plrStudioInfo then return end

    if itemType == "furniture" then
        local hasItem = StudioPlaceablesServer.HasFurnitureItem(plr, itemInfo, plrStudioInfo.StudioIndex, true)
        if not hasItem then return end

        StudioPlaceablesServer.StoreFurnitureItem(plr, itemInfo, plrStudioInfo.StudioIndex)
    end

    -- remove item for all plrs in studio
    for plrUserId, studioInfo in StudioConfigServer.PlrsInStudio do
        if studioInfo then
            if studioInfo.PlrVisitingId == plr.UserId then
                local plrToUpdate: Player = Players:GetPlayerByUserId(plrUserId)
                Remotes.Studio.BuildMode.RemoveItem:FireClient(plrToUpdate, itemType, itemInfo)
            end
        end
    end
end

Remotes.Studio.General.VisitOwnStudio.OnServerEvent:Connect(function(plr: Player)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local studioIndex = profile.Data.Studio.ActiveStudio
    visitStudio(plr, plr, studioIndex)
end)

Remotes.Studio.General.VisitOtherStudio.OnServerEvent:Connect(function(plr: Player, userIdOfPlrToVisit: number)
    if not StudioConfigServer.PlrStudios[plr.UserId] then return end

    local plrToVisit: Player = Players:GetPlayerByUserId(userIdOfPlrToVisit)
    if not plrToVisit then return end

    local profile = PlrDataManager.Profiles[plrToVisit]
    if not profile then return end

    if canVisitStudio(plr, plrToVisit) then
        local studioIndex = profile.Data.Studio.ActiveStudio
        visitStudio(plr, plrToVisit, studioIndex)
    end
end)

Remotes.Studio.General.LeaveStudio.OnServerEvent:Connect(function(plr: Player)
    StudioConfigServer.PlrsInStudio[plr.UserId] = false

    -- switch left-side gui btn from build-mode to tp btn
    Remotes.Studio.General.LeaveStudio:FireClient(plr)
end)

Remotes.Studio.General.PurchaseNextStudio.OnServerEvent:Connect(function(plr: Player)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local purchased = StudioConfigServer.PurchaseNextStudio(plr)
    if purchased then
        StudioConfigServer.PlrStudios[plr.UserId]["StudioIndex"] = profile.Data.Studio.ActiveStudio
        Remotes.GUI.Studio.UpdateStudioList:FireAllClients(plr.UserId, "update", StudioConfigServer.PlrStudios[plr.UserId])
    end
end)

Remotes.Studio.General.UpdateWhitelist.OnServerEvent:Connect(function(plr: Player)
    local newWhitelistSetting = updateStudioWhitelist(plr)

    if newWhitelistSetting == "friends" then
        kickAllPlrsFromStudio(plr, true)
    elseif newWhitelistSetting == "closed" then
        kickAllPlrsFromStudio(plr, false)
    end

    -- update new whitelist setting visually for plr
    Remotes.Studio.General.UpdateWhitelist:FireClient(plr, newWhitelistSetting)

    -- update new whitelist setting on all client Studio Lists
    Remotes.GUI.Studio.UpdateStudioList:FireAllClients(plr.UserId, "update", StudioConfigServer.PlrStudios[plr.UserId])
end)

Remotes.Studio.General.KickFromStudio.OnServerEvent:Connect(function(plr: Player)
    kickAllPlrsFromStudio(plr, false)
end)

Remotes.Studio.BuildMode.EnterBuildMode.OnServerEvent:Connect(function(plr: Player)
    -- check if plr is in their own studio, in cases where exploiters might fire remote when not in their studio
    local plrStudioInfo = StudioConfigServer.PlrsInStudio[plr.UserId]
    if plrStudioInfo then
        if plrStudioInfo.PlrVisitingId == plr.UserId then
            local profile = PlrDataManager.Profiles[plr]
            if not profile then return end

            local studioData = profile.Data.Inventory
            -- 1) populate build-mode gui
            -- 2) enable build-mode functionality
            local studioFurnitureInventory = StudioConfig.GetFurnitureAvailableForStudio(profile.Data)

            Remotes.Studio.BuildMode.EnterBuildMode:FireClient(plr, studioFurnitureInventory)
        end
    end
end)

Remotes.Studio.BuildMode.EnterPlaceMode.OnServerEvent:Connect(function(plr: Player, itemType: "furniture" | "essential", itemInfo: {}, movingItem: boolean)
    if itemType == "furniture" then
        local hasItem: boolean = StudioPlaceablesServer.HasFurnitureItem(plr, itemInfo, StudioConfigServer.PlrStudios[plr.UserId].StudioIndex, movingItem)
        if not hasItem then return end

        Remotes.Studio.BuildMode.EnterPlaceMode:FireClient(plr, itemType, itemInfo, movingItem)
    end

    if itemType == "essential" then
        Remotes.Studio.BuildMode.EnterPlaceMode:FireClient(plr, itemType, itemInfo, movingItem)
    end
end)

Remotes.Studio.BuildMode.PlaceItem.OnServerEvent:Connect(placeStudioItem)

Remotes.Studio.BuildMode.ExitPlaceMode.OnServerEvent:Connect(function(plr: Player)
    -- terminate place mode functionality on client
    Remotes.Studio.BuildMode.ExitPlaceMode:FireClient(plr, nil)
end)

Remotes.Studio.BuildMode.StoreItem.OnServerEvent:Connect(storeStudioItem)

Remotes.GameDev.UnlockGenreBindable.Event:Connect(function(plrWhoUnlocked, genreName)
    for plrUserId, studioInfo in StudioConfigServer.PlrsInStudio do
        if studioInfo then
            if plrUserId == plrWhoUnlocked.UserId then continue end

            if studioInfo.PlrVisitingId == plrWhoUnlocked.UserId then
                local plrToFireRemote = Players:GetPlayerByUserId(plrUserId)
                Remotes.GameDev.UnlockGenre:FireClient(plrToFireRemote, genreName)
            end
        end
    end
end)

Remotes.GameDev.UnlockTopicBindable.Event:Connect(function(plrWhoUnlocked, topicName)
    for plrUserId, studioInfo in StudioConfigServer.PlrsInStudio do
        if studioInfo then
            if plrUserId == plrWhoUnlocked.UserId then continue end

            if studioInfo.PlrVisitingId == plrWhoUnlocked.UserId then
                local plrToFireRemote = Players:GetPlayerByUserId(plrUserId)
                Remotes.GameDev.UnlockTopic:FireClient(plrToFireRemote, topicName)
            end
        end
    end
end)