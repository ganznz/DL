local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local GlobalVariables = require(ReplicatedStorage.GlobalVariables)
local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local PlayerCharacterManager = require(ServerScriptService.Functionality.PlayerCharacterManager.PlayerCharacterManager)
local StudioConfig = require(ReplicatedStorage.Configs.Studio.Studio)
local StudioPlaceablesServer = require(ServerScriptService.Functionality.Studio.StudioPlaceablesServer)
local FurnitureConfigServer = require(ServerScriptService.Functionality.Furniture.FurnitureConfigServer)
local StudioConfigServer = require(ServerScriptService.Functionality.Studio.StudioConfigServer)
local StaffConfigServer = require(ServerScriptService.Functionality.Staff.StaffConfigServer)
local Zone = require(ReplicatedStorage.Libs.Zone)

local Remotes = ReplicatedStorage.Remotes
local studioExteriorsFolder = CollectionService:GetTagged("Studio")

Players.PlayerAdded:Connect(function(plr: Player)
    repeat task.wait() until PlrDataManager.Profiles[plr]

    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    -- if it's players first time joining the game, establish first studio data
    if not profile.Data.Studio.Studios.Standard["1"] then
        StudioConfigServer.InitializeStudioData(plr, "Standard", "1")
        profile.Data.Studio.ActiveStudio = "1"
    end

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

    local alreadyPlacedFurnitureData = FurnitureConfigServer.AlreadyPlacedFurnitureData(plrToVisit, studioIndex)
    local switchingStudios = plr:GetAttribute("InStudio")

    plr:SetAttribute("InStudio", true)

    Remotes.GUI.ChangeGuiStatusRemote:FireClient(plr, "loadingBgSplash")
    -- tp plr to studio. if plr is visiting someone elses studio, bypass checks that determine whether the plr owns the area (studio) they are teleporting to
    task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
        PlayerCharacterManager.TeleportPlr(plr, `Studio{studioIndex}`, "Interior", plr ~= plrToVisit)
    end)

    if plr == plrToVisit then
        profile.Data.Studio.ActiveStudio = studioIndex
        StudioConfigServer.PlrStudios[plrToVisit.UserId].StudioIndex = profile.Data.Studio.ActiveStudio

        StudioConfigServer.PlrsInStudio[plr.UserId] = {
            PlrVisitingId = plr.UserId,
            StudioIndex = studioIndex
        }

        Remotes.Studio.General.VisitOwnStudio:FireClient(plr, plr.UserId, studioIndex, interiorPlayerTpPart, exteriorPlayerTpPart, alreadyPlacedFurnitureData, { SwitchingStudios = switchingStudios })
    else
        StudioConfigServer.PlrsInStudio[plr.UserId] = {
            PlrVisitingId = plrToVisit.UserId,
            StudioIndex = studioIndex
        }
        Remotes.Studio.General.VisitOtherStudio:FireClient(plr, plrToVisit.UserId, studioIndex, interiorPlayerTpPart, exteriorPlayerTpPart, alreadyPlacedFurnitureData, { SwitchingStudios = switchingStudios })
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
    local kickMsg: string = `<font color="#b0edff"><stroke color="#418ea6" thickness="2">{plrWhosStudioToClear.Name}</stroke></font> has removed you from their studio`
    local indexOfStudioToKickPlrsFrom: string = StudioConfigServer.PlrsInStudio[plrWhosStudioToClear.UserId].StudioIndex

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

                    plrToKick:SetAttribute("InStudio", false)
                    StudioConfigServer.PlrsInStudio[plrToKick.UserId] = false
                    Remotes.Studio.General.KickFromStudio:FireClient(plrToKick)
                    Remotes.GUI.DisplayNotification:FireClient(plrToKick, "general", kickMsg)

                    -- tp plr out of studio
                    Remotes.GUI.ChangeGuiStatusRemote:FireClient(plrToKick, "loadingBgSplash")
                    task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
                        PlayerCharacterManager.TeleportPlr(plrToKick, `Studio{indexOfStudioToKickPlrsFrom}`, "Exterior")
                    end)
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
    local plrStudioInfo = StudioConfigServer.PlrStudios
    local ownerStudioInfo = plrStudioInfo[studioOwner.UserId]

    for plrUserId, visitingPlrStudioInfo in StudioConfigServer.PlrsInStudio do
        if plrUserId == studioOwner.UserId then continue end

        if visitingPlrStudioInfo then
            if visitingPlrStudioInfo.PlrVisitingId == studioOwner.UserId and visitingPlrStudioInfo.StudioIndex == ownerStudioInfo.StudioIndex then
                local plrToUpdate: Player = Players:GetPlayerByUserId(plrUserId)

                Remotes.Studio.BuildMode.ReplicatePlaceItem:FireClient(plrToUpdate, itemType, itemInfo)

                -- if the item got moved, delete the *old* model
                if action == "move" then Remotes.Studio.BuildMode.RemoveItem:FireClient(plrToUpdate, itemType, itemInfo) end
            end
        end
    end
end

local function storeFurnitureItemPlacementData(plr, itemInfo, additionalParams)
    local modelCategoryFolder = ReplicatedStorage.Assets.Models.Studio.StudioFurnishing[itemInfo.ItemCategory]
    if not modelCategoryFolder then return end

    local plrStudioInfo = StudioConfigServer.PlrStudios[plr.UserId]
    if not plrStudioInfo then return end

    -- place and store item data as a new item
    if additionalParams.Action == "newItem" then
        if not FurnitureConfigServer.HasFurnitureItem(plr, itemInfo, plrStudioInfo.StudioIndex, false) then return end
        itemInfo.ItemUUID = FurnitureConfigServer.StoreFurnitureItemPlacementData(plr, itemInfo, plrStudioInfo.StudioIndex)

    elseif additionalParams.Action == "move" then
        FurnitureConfigServer.UpdateFurnitureItemPlacementData(plr, itemInfo, plrStudioInfo.StudioIndex)
    end
end

local function storeStaffMemberPlacementData(plr, itemInfo, additionalParams)
    local plrStudioInfo = StudioConfigServer.PlrStudios[plr.UserId]
    if not plrStudioInfo then return end

    if additionalParams.Action == "newItem" then
        if not StaffConfigServer.OwnsStaffMember(plr, itemInfo.ItemUUID) then return end
        StaffConfigServer.StoreStaffItemPlacementData(plr, itemInfo, plrStudioInfo.StudioIndex)

    elseif additionalParams.Action == "move" then
        StaffConfigServer.UpdateStaffItemPlacementData(plr, itemInfo, plrStudioInfo.StudioIndex)
    end
end

local function storeEssentialItemPlacementData(plr, itemInfo, additionalParams)
    local plrStudioInfo = StudioConfigServer.PlrStudios[plr.UserId]
    if not plrStudioInfo then return end

    StudioPlaceablesServer.StoreEssentialItemData(plr, itemInfo, plrStudioInfo.StudioIndex)
end

-- STUDIO BUILD MODE FUNCTIONALITY
local function placeStudioItem(plr: Player, itemType: "furniture" | "essential", itemInfo, additionalParams): boolean
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    if itemType == "furniture" then
        storeFurnitureItemPlacementData(plr, itemInfo, additionalParams)
    
    elseif itemType == "essential" then
        storeEssentialItemPlacementData(plr, itemInfo, additionalParams)
    
    elseif itemType == "staff" then
        storeStaffMemberPlacementData(plr, itemInfo, additionalParams)
    end

    -- data that gets sent to client to populate build mode gui with
    local studioFurnitureInventory = StudioConfig.GetFurnitureAvailableForStudio(profile.Data)

    Remotes.Studio.BuildMode.PlaceItem:FireClient(plr, itemType, itemInfo)
    Remotes.Studio.BuildMode.ExitPlaceMode:FireClient(plr, studioFurnitureInventory) -- disable place mode gui

    -- replicate to others in studio
    replicatePlaceItem(plr, additionalParams.Action, itemType, itemInfo)
end

-- function stores placed item back in inventory
local function storeStudioItem(plr: Player, itemType: string, itemInfo: {})
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local ownerStudioInfo = StudioConfigServer.PlrStudios[plr.UserId]
    if not ownerStudioInfo then return end

    if itemType == "furniture" then
        local hasItem = FurnitureConfigServer.HasFurnitureItem(plr, itemInfo, ownerStudioInfo.StudioIndex, true)
        if not hasItem then return end

        FurnitureConfigServer.StoreFurnitureItem(plr, itemInfo, ownerStudioInfo.StudioIndex)
    
    elseif itemType == "staff" then
        local hasItem = StaffConfigServer.OwnsStaffMember(plr, itemInfo.ItemUUID)
        if not hasItem then return end

        StaffConfigServer.StoreStaffMember(plr, itemInfo, ownerStudioInfo.StudioIndex)
    end

    -- remove item for all plrs in studio
    for plrUserId, visitingPlrStudioInfo in StudioConfigServer.PlrsInStudio do
        if visitingPlrStudioInfo then
            if visitingPlrStudioInfo.PlrVisitingId == plr.UserId and visitingPlrStudioInfo.StudioIndex == ownerStudioInfo.StudioIndex then
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

Remotes.Studio.General.VisitOwnStudioBindable.Event:Connect(function(plr: Player)
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

Remotes.Studio.General.VisitOtherStudioBindable.Event:Connect(function(plr: Player, userIdOfPlrToVisit: number)
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
    local indexOfStudioBeingLeft: string = StudioConfigServer.PlrsInStudio[plr.UserId].StudioIndex
    StudioConfigServer.PlrsInStudio[plr.UserId] = false

    local previouslyInStudio = plr:GetAttribute("InStudio")
    local previouslyInBuildMode = plr:GetAttribute("InBuildMode")
    local previouslyInPlaceMode = plr:GetAttribute("InPlaceMode")

    plr:SetAttribute("InStudio", false)
    plr:SetAttribute("InPlaceMode", false)
    plr:SetAttribute("InBuildMode", false)

    -- switch left-side gui btn from build-mode to tp btn
    Remotes.Studio.General.LeaveStudio:FireClient(plr, {
        InStudio = previouslyInStudio,
        InBuildMode = previouslyInBuildMode,
        InPlaceMode = previouslyInPlaceMode,
    })

    -- tp plr
    Remotes.GUI.ChangeGuiStatusRemote:FireClient(plr, "loadingBgSplash")
    task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
        PlayerCharacterManager.TeleportPlr(plr, `Studio{indexOfStudioBeingLeft}`, "Exterior")
    end)
end)

Remotes.Studio.General.PurchaseNextStudio.OnServerEvent:Connect(function(plr: Player)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    StudioConfigServer.PurchaseNextStudio(plr)
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

            plr:SetAttribute("InBuildMode", true)
            Remotes.Studio.BuildMode.EnterBuildMode:FireClient(plr, studioFurnitureInventory)
        end
    end
end)

Remotes.Studio.BuildMode.EnterPlaceMode.OnServerEvent:Connect(function(plr: Player, itemType: string, itemInfo: {}, movingItem: boolean)
    if itemType == "furniture" then
        local hasItem: boolean = FurnitureConfigServer.HasFurnitureItem(plr, itemInfo, StudioConfigServer.PlrStudios[plr.UserId].StudioIndex, movingItem)
        if not hasItem then return end

        Remotes.Studio.BuildMode.EnterPlaceMode:FireClient(plr, itemType, itemInfo, movingItem)
    
    elseif itemType == "essential" then
        Remotes.Studio.BuildMode.EnterPlaceMode:FireClient(plr, itemType, itemInfo, movingItem)
    
    elseif itemType == "staff" then
        local hasItem: boolean = StaffConfigServer.OwnsStaffMember(plr, itemInfo.ItemUUID)
        if not hasItem then return end

        Remotes.Studio.BuildMode.EnterPlaceMode:FireClient(plr, itemType, itemInfo, movingItem)
    end
end)

Remotes.Studio.BuildMode.PlaceItem.OnServerEvent:Connect(placeStudioItem)

Remotes.Studio.BuildMode.ExitBuildMode.OnServerEvent:Connect(function(plr: Player)
    plr:SetAttribute("InBuildMode", false)
    Remotes.Studio.BuildMode.ExitBuildMode:FireClient(plr, nil)
end)

Remotes.Studio.BuildMode.ExitPlaceMode.OnServerEvent:Connect(function(plr: Player)
    -- terminate place mode functionality on client
    Remotes.Studio.BuildMode.ExitPlaceMode:FireClient(plr, nil)
end)

Remotes.Studio.BuildMode.StoreItem.OnServerEvent:Connect(storeStudioItem)