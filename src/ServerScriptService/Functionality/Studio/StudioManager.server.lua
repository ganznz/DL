local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

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
-- { [plr.UserId] = { PlrVisitingId: number, studioIndex: number } | false }
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
    tpPart:SetAttribute("AreaAccessibility", "General")  -- set to "General" so plrs can tp into other plrs studios.
    tpPart:SetAttribute("AreaName", "Studio"..exteriorStudioFolder.Name)
end

local function visitStudio(plr: Player, plrToVisit: Player, studioIndex: number)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local studioExteriorFolder = Workspace.Map.Buildings.Studios:FindFirstChild(tostring(studioIndex))
    local interiorPlayerTpPart = studioExteriorFolder:FindFirstChild("PlrTeleportToPartInterior")
    local exteriorPlayerTpPart = studioExteriorFolder:FindFirstChild("TeleportToPart")

    local alreadyPlacedFurnitureData = StudioConfigServer.AlreadyPlacedFurnitureData(plrToVisit, studioIndex)
    if plr == plrToVisit then
        profile.Data.Studio.ActiveStudio = studioIndex
        plrStudios[plrToVisit.UserId].StudioIndex = profile.Data.Studio.ActiveStudio

        plrsInStudio[plr.UserId] = {
            PlrVisitingId = plr.UserId,
            StudioIndex = studioIndex
        }
        Remotes.Studio.General.VisitOwnStudio:FireClient(plr, plr.UserId, studioIndex, interiorPlayerTpPart, exteriorPlayerTpPart, alreadyPlacedFurnitureData)
    else
        plrsInStudio[plr.UserId] = {
            PlrVisitingId = plrToVisit.UserId,
            StudioIndex = studioIndex
        }
        Remotes.Studio.General.VisitOtherStudio:FireClient(plr, plrToVisit.UserId, studioIndex, interiorPlayerTpPart, exteriorPlayerTpPart, alreadyPlacedFurnitureData)
    end
end

local function updateStudioWhitelist(plr: Player): "open" | "closed" | "friends"
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

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

    profile.Data.Studio.StudioStatus = plrStudios[plr.UserId].StudioStatus
    return profile.Data.Studio.StudioStatus
end

local function canVisitStudio(plr: Player, plrToVisit: Player): boolean
    if not plrStudios[plr.UserId] then return end

    local whitelistSetting = plrStudios[plrToVisit.UserId].StudioStatus
    if whitelistSetting == "friends" and plr:IsFriendsWith(plrToVisit.UserId) then
        return true
    elseif whitelistSetting == "open" then
        return true
    end

    return false
end

local function kickAllPlrsFromStudio(plrWhosStudioToClear: Player, ignoreFriends: boolean)
    for plrUserId, studioInfo in plrsInStudio do

        -- if studioInfo exists then it means the plr is in a studio
        if studioInfo then
            -- ignore studio owner
            if plrUserId == plrWhosStudioToClear.UserId then continue end

            -- check if the studio the plr is in matches with who fired this remote
            if studioInfo.PlrVisitingId == plrWhosStudioToClear.UserId then
                local plrToKick: Player = Players:GetPlayerByUserId(plrUserId)
                if plrToKick then
                    if ignoreFriends and plrToKick:IsFriendsWith(plrWhosStudioToClear.UserId) then continue end

                    plrsInStudio[plrToKick.UserId] = false
                    Remotes.Studio.General.KickFromStudio:FireClient(plrToKick)
                    Remotes.GUI.DisplayNotification:FireClient(plrToKick, "general", string.format("%s has removed you from their studio", plrWhosStudioToClear.Name))
                end
            end
        end
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



-- STUDIO BUILD MODE FUNCTIONALITY
local function placeStudioItem(plr: Player, objectName, objectCFrame: CFrame, additionalParams): boolean
    local modelCategoryFolder = ReplicatedStorage.Assets.Models.StudioFurnishing[additionalParams.category]
    if not modelCategoryFolder then return end

    local plrStudioInfo = plrStudios[plr.UserId]
    if not plrStudioInfo then return end

    local itemUUID

    -- place and store item data as a new item
    if additionalParams.action == "newItem" then
        if not StudioConfigServer.HasItem(plr, objectName, additionalParams.category, plrStudioInfo.StudioIndex) then return end
        itemUUID = StudioConfigServer.StoreFurnitureItemData(plr, objectName, objectCFrame, additionalParams.category, plrStudioInfo.StudioIndex)

    elseif additionalParams.action == "move" then
        -- item was previously placed, only update item data
        itemUUID = additionalParams.uuid
        StudioConfigServer.UpdateFurnitureItemData(plr, objectName, itemUUID, objectCFrame, additionalParams.category, plrStudioInfo.StudioIndex)
    end

    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    -- data that gets sent to client to populate build mode gui with
    local studioFurnitureInventory = StudioConfig.GetFurnitureAvailableForStudio(profile.Data)

    Remotes.Studio.BuildMode.PlaceItem:FireClient(plr, objectName, additionalParams.category, objectCFrame, itemUUID)
    Remotes.Studio.BuildMode.ExitPlaceMode:FireClient(plr, studioFurnitureInventory)

    -- replicate placed item to all plrs currently in this studio
    for plrUserId, studioInfo in plrsInStudio do
        if plrUserId == plr.UserId then continue end

        if studioInfo then
            if studioInfo.PlrVisitingId == plr.UserId then
                local plrToUpdate: Player = Players:GetPlayerByUserId(plrUserId)

                -- if the item got moved, delete the 'old' model before placing the new one in the updated position
                if additionalParams.action == "move" then Remotes.Studio.BuildMode.RemoveItem:FireClient(plrToUpdate, itemUUID) end

                Remotes.Studio.BuildMode.ReplicatePlaceItem:FireClient(plrToUpdate, objectName, additionalParams.category, objectCFrame, itemUUID)

            end
        end
    end
end

local function deleteStudioItems(plr: Player, itemsToDelete)
    for category, itemsInCategory in itemsToDelete do
        for itemName, itemInfo in itemsInCategory do
            
            -- only 1 item to delete
            if itemInfo["ItemUUID"] then
                local uuidToDelete = StudioConfigServer.DeleteSingleItem(plr, category, itemName, itemInfo.ItemUUID)
                
                -- remove item for all plrs in studio
                if uuidToDelete then
                    for plrUserId, studioInfo in plrsInStudio do
                        if studioInfo then
                            if studioInfo.PlrVisitingId == plr.UserId then
                                local plrToUpdate: Player = Players:GetPlayerByUserId(plrUserId)
                                Remotes.Studio.BuildMode.RemoveItem:FireClient(plrToUpdate, uuidToDelete)
                            end
                        end
                    end
                end
            end

            -- potentially delete multiple items
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
    if not plrStudios[plr.UserId] then return end

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
    plrsInStudio[plr.UserId] = false

    -- switch left-side gui btn from build-mode to tp btn
    Remotes.Studio.General.LeaveStudio:FireClient(plr)
end)

Remotes.Studio.General.PurchaseNextStudio.OnServerEvent:Connect(function(plr: Player)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local purchased = StudioConfigServer.PurchaseNextStudio(plr)
    if purchased then
        plrStudios[plr.UserId]["StudioIndex"] = profile.Data.Studio.ActiveStudio
        Remotes.GUI.Studio.UpdateStudioList:FireAllClients(plr.UserId, "update", plrStudios[plr.UserId])
    end
end)

Remotes.Studio.General.GetStudioPlrInfo.OnServerInvoke = function()
    return plrStudios
end

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
    Remotes.GUI.Studio.UpdateStudioList:FireAllClients(plr.UserId, "update", plrStudios[plr.UserId])
end)

Remotes.Studio.General.KickFromStudio.OnServerEvent:Connect(function(plr: Player)
    kickAllPlrsFromStudio(plr, false)
end)

Remotes.Studio.BuildMode.EnterBuildMode.OnServerEvent:Connect(function(plr: Player)
    -- check if plr is in their own studio, in cases where exploiters might fire remote when not in their studio
    local plrStudioInfo = plrsInStudio[plr.UserId]
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

Remotes.Studio.BuildMode.EnterPlaceMode.OnServerEvent:Connect(function(plr: Player, itemName: string, itemCategory: "Mood" | "Energy" | "Hunger" | "Decor", movingItem: boolean, itemUUID: string | nil)
    if itemCategory == "Mood" or itemCategory == "Energy" or itemCategory == "Hunger" or itemCategory == "Decor" then

        if movingItem then
            -- moving an item which is already in the studio, so no need to check if plr already owns it
            Remotes.Studio.BuildMode.EnterPlaceMode:FireClient(plr, itemName, itemCategory, true, itemUUID)

        else
            local hasItem: boolean = StudioConfigServer.HasItem(plr, itemName, itemCategory, plrStudios[plr.UserId].StudioIndex)
            if hasItem then Remotes.Studio.BuildMode.EnterPlaceMode:FireClient(plr, itemName, itemCategory, false, nil) end
        end
    end
end)

Remotes.Studio.BuildMode.PlaceItem.OnServerEvent:Connect(placeStudioItem)

Remotes.Studio.BuildMode.ExitPlaceMode.OnServerEvent:Connect(function(plr: Player)
    -- terminate place mode functionality on client
    Remotes.Studio.BuildMode.ExitPlaceMode:FireClient(plr, nil)
end)

Remotes.Studio.BuildMode.DeleteItems.OnServerEvent:Connect(deleteStudioItems)