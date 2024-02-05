local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlobalVariables = require(ReplicatedStorage:WaitForChild("GlobalVariables"))
local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))
local Zone = require(ReplicatedStorage.Libs:WaitForChild("Zone"))
local StudioConfig = require(ReplicatedStorage.Configs.Studio:WaitForChild("Studio"))
local StaffMemberConfig = require(ReplicatedStorage.Configs.Staff:WaitForChild("StaffMember"))
local CameraControls = require(ReplicatedStorage.Utils.Camera:WaitForChild("CameraControls"))
local PlayerServices = require(ReplicatedStorage.Utils.Player:WaitForChild("Player"))
local DatastoreUtils = require(ReplicatedStorage.Utils.DS:WaitForChild("DatastoreUtils"))

local Remotes = ReplicatedStorage.Remotes
local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui
local camera = Workspace:WaitForChild("Camera")

local StudioExteriorsFolder = Workspace:WaitForChild("Map").Buildings.Studios
local StudioInteriorsFolder = ReplicatedStorage:WaitForChild("Assets").Models.Studio.Studios

-- CONSTANT VARIABLES --
local INTERACTION_BILLBOARDS_VIEWING_DIST = 15 -- studs

-- STATE VARIABLES --
local studioExteriorTpPart = nil
local interiorFurnitureData = nil
local currentStudioIndex = nil
local studioInteriorFolder = nil
local studioInteriorPlot = nil
local studioInteriorPlacedItems = nil
local studioItemPlacementFolder = nil
local studioInteriorModel = nil
local studioInteriorExitZone = nil
local computerModel = nil
local shelfModel = nil
local genreIterationIndex = 1 -- vars for book model placement on shelf
local topicIterationIndex = 1
local presentInteractionBillboards = {} -- holds all existing interaction billboards

-- connections
local shelfViewBtnBtnConnection = nil
local computerMakeGameBtnConnection = nil
local computerUpgradeBtnConnection
local studioEssentialsProximityConnection = nil -- connection for detecting what item interactions should show

-- make a copy of all studio exteriors, so when player leaves a studio and
-- needs to make the studio exterior visible again, copy it from this table
-- and put it back into the workspace 'StudioExteriorsFolder'
local studioExteriorsCopy = {}
for _i, studioExteriorFolder in StudioExteriorsFolder:GetChildren() do
    studioExteriorsCopy[studioExteriorFolder.Name] = studioExteriorFolder:Clone()
end

local function calculateYOffset(model: Model): number
    if not model:IsA("Model") then return end

    return model.PrimaryPart.Size.Y / 2
end

local function resetStudioVariables()
    currentStudioIndex = nil
    studioInteriorFolder = nil
    studioInteriorPlacedItems = nil
    studioInteriorExitZone = nil
    studioExteriorTpPart = nil
    presentInteractionBillboards = {}
    genreIterationIndex = 1
    topicIterationIndex = 1
end

local function resetStudioConnections()
    if shelfViewBtnBtnConnection then shelfViewBtnBtnConnection:Disconnect() end
    shelfViewBtnBtnConnection = nil

    if computerMakeGameBtnConnection then computerMakeGameBtnConnection:Disconnect() end
    computerMakeGameBtnConnection = nil

    if computerUpgradeBtnConnection then computerUpgradeBtnConnection:Disconnect() end
    computerUpgradeBtnConnection = nil

    if studioEssentialsProximityConnection then studioEssentialsProximityConnection:Disconnect() end
    studioEssentialsProximityConnection = nil
end

local function placeFurnitureItem(model: Model, itemUUID: string, itemOffsetCFrame: CFrame)
    -- convert CFrame from objectspace that is relative to plot, to worldspace.
    local placementCFrame = studioInteriorPlot.CFrame:ToWorldSpace(itemOffsetCFrame)

    model:PivotTo(placementCFrame)
    model.Name = itemUUID
    model.Parent = studioItemPlacementFolder
end

local function placeStaffMember(model: Model, itemUUID: string, itemOffsetCFrame: CFrame)
        -- convert CFrame from objectspace that is relative to plot, to worldspace.
        local placementCFrame = studioInteriorPlot.CFrame:ToWorldSpace(itemOffsetCFrame)

        model:PivotTo(placementCFrame)
        model.Name = itemUUID
        model.Parent = studioItemPlacementFolder
end


local function loadInteriorFurniture()
    for itemCategory, itemsInCategory in interiorFurnitureData do
        for itemName, allItemInstances in itemsInCategory do
            for itemUUID, itemData in allItemInstances do
                local itemCFrame = DatastoreUtils.TableToCFrame(itemData.CFrame)
                local itemModel = StudioConfig.GetFurnitureItemModel(itemName, itemCategory)

                placeFurnitureItem(itemModel, itemUUID, itemCFrame)
            end
        end
    end
end

local function loadInteriorStaffMembers(plrToVisitData: {}, studioType: "Standard" | "Premium")
    local inventoryStaffMemberData = plrToVisitData.Inventory.StaffMembers
    local studioStaffMemberData = plrToVisitData.Studio.Studios[studioType][currentStudioIndex].StaffMembers

    for staffMemberUUID, staffMemberData in studioStaffMemberData do
        local staffMemberModelName = inventoryStaffMemberData[staffMemberUUID].Model

        local itemCFrame = DatastoreUtils.TableToCFrame(staffMemberData.CFrame)
        local itemModel = StaffMemberConfig.GetStaffMemberModel(staffMemberModelName)

        placeStaffMember(itemModel, staffMemberUUID, itemCFrame)
    end
end

local function deleteStaffInteractionBillboards()
    for _i, billboardGuiInstance in PlayerGui.AllGui.Studio.StudioInteractionBillboards:GetChildren() do
        -- don't delete template billboard
        if billboardGuiInstance.Name == "StaffInteractionSettings" then continue end
        if billboardGuiInstance:GetAttribute("ItemType") == "staff" then
            billboardGuiInstance:Destroy()
        end
    end
end

local function disableInteractionBtns()
    resetStudioConnections()
    deleteStaffInteractionBillboards()
    
    -- computer & shelf
    local shelfInteractionBillboard = PlayerGui.AllGui.Studio.StudioInteractionBillboards:FindFirstChild("ShelfInteractionSettings")
    local computerInteractionBillboard = PlayerGui.AllGui.Studio.StudioInteractionBillboards:FindFirstChild("ComputerInteractionSettings")
    if shelfInteractionBillboard then shelfInteractionBillboard.Enabled = false end
    if computerInteractionBillboard then computerInteractionBillboard.Enabled = false end
end

local function registerShelfViewBtn(viewBtn)
    shelfViewBtnBtnConnection = viewBtn.Activated:Connect(function()
        GuiServices.HideHUD({ HideGuiFrames = true })

        local cameraPos: Vector3 = shelfModel:FindFirstChild("CameraPositionPart").Position
        local cameraLookAt: Vector3 = shelfModel:FindFirstChild("CameraLookAt").Position

        PlayerServices.HidePlayer(localPlr, true)
        CameraControls.FocusOnObject(localPlr, camera, cameraPos, cameraLookAt, true, true)

        disableInteractionBtns()
        Remotes.GUI.Studio.ViewShelf:Fire()
    end)
end

local function registerShelfInteractionBtns()
    local shelfInteractionBillboard = PlayerGui.AllGui.Studio.StudioInteractionBillboards:FindFirstChild("ShelfInteractionSettings")
    local shelfViewBtn = shelfInteractionBillboard:FindFirstChild("View", true)

    registerShelfViewBtn(shelfViewBtn)
    shelfInteractionBillboard.Adornee = shelfModel.PrimaryPart
    table.insert(presentInteractionBillboards, shelfInteractionBillboard)

    return shelfInteractionBillboard
end

local function registerComputerInteractionBtns()
    local computerInteractionBillboard = PlayerGui.AllGui.Studio.StudioInteractionBillboards:FindFirstChild("ComputerInteractionSettings")
    local computerMakeGameBtn = computerInteractionBillboard:FindFirstChild("MakeGame", true)
    local computerUpgradeBtn = computerInteractionBillboard:FindFirstChild("Upgrade", true)

    computerInteractionBillboard.Adornee = computerModel.PrimaryPart
    table.insert(presentInteractionBillboards, computerInteractionBillboard)

    computerMakeGameBtnConnection = computerMakeGameBtn.Activated:Connect(function()
        disableInteractionBtns()
        Remotes.GUI.ChangeGuiStatusBindable:Fire("developGame", true, nil)
    end)

    computerUpgradeBtnConnection = computerUpgradeBtn.Activated:Connect(function()
        
    end)

    return computerInteractionBillboard
end

local function registerStaffInteractionBtns()
    for _i, placedItem in studioInteriorPlacedItems:GetChildren() do
        local itemType = placedItem:GetAttribute("ItemType")
        if itemType ~= "staff" then return end

        local staffMemberUUID = placedItem.Name

        local staffInteractionBillboard = PlayerGui.AllGui.Studio.StudioInteractionBillboards:FindFirstChild("StaffInteractionSettings"):Clone()
        local viewStaffMemberBtn = staffInteractionBillboard:FindFirstChild("View", true)
        local trainStaffMemberBtn = staffInteractionBillboard:FindFirstChild("Train", true)
        
        staffInteractionBillboard.Name = staffMemberUUID
        staffInteractionBillboard.Adornee = placedItem
        staffInteractionBillboard.Enabled = true
        staffInteractionBillboard.Parent = PlayerGui.AllGui.Studio.StudioInteractionBillboards
        table.insert(presentInteractionBillboards, staffInteractionBillboard)

        viewStaffMemberBtn.Activated:Connect(function()
            disableInteractionBtns()
            Remotes.GUI.ChangeGuiStatusBindable:Fire("viewStaffMemberStudio", true, { StaffMemberUUID = staffMemberUUID })
        end)
        
        trainStaffMemberBtn.Activated:Connect(function()
            disableInteractionBtns()
            Remotes.GUI.ChangeGuiStatusBindable:Fire("trainStaffMemberStudio", true, { StaffMemberUUID = staffMemberUUID })
        end)
    end
end

-- this function determines which interaction billboard is visible (among billboards for the shelf, computer, staff members, etc)
local function determineVisibleInteractionBillboard()
end


local function registerInteractionBtns()
    computerModel = studioInteriorModel:FindFirstChild("Computer")
    shelfModel = studioInteriorModel:FindFirstChild("Shelf")

    local shelfInteractionBillboard = registerShelfInteractionBtns()
    local computerInteractionBillboard = registerComputerInteractionBtns()
    registerStaffInteractionBtns()

    -- if computer and shelf are near eachother, only show interaction btns for whichever item is closer to plr
    studioEssentialsProximityConnection = RunService.Stepped:Connect(function()

        local shelfDistanceFromPlr = (localPlr.Character:FindFirstChild("HumanoidRootPart").Position - shelfInteractionBillboard.Adornee.Position).Magnitude
        local computerDistanceFromPlr = (localPlr.Character:FindFirstChild("HumanoidRootPart").Position - computerInteractionBillboard.Adornee.Position).Magnitude
        
        -- check if plr is within viewing distance
        local isShelfInteractable = shelfDistanceFromPlr <= INTERACTION_BILLBOARDS_VIEWING_DIST and (shelfDistanceFromPlr < computerDistanceFromPlr)
        local isComputerInteractable = computerDistanceFromPlr <= INTERACTION_BILLBOARDS_VIEWING_DIST and (computerDistanceFromPlr < shelfDistanceFromPlr)
        
        if isShelfInteractable then
            shelfInteractionBillboard.Enabled = true
            computerInteractionBillboard.Enabled = false
            return
            
        elseif isComputerInteractable then
            computerInteractionBillboard.Enabled = true
            shelfInteractionBillboard.Enabled = false
            return
        end

        -- plr is near neither shelf or computer
        shelfInteractionBillboard.Enabled = false
        computerInteractionBillboard.Enabled = false
    end)
end

-- function used for replacing placeholder shelf in studio interior plots with 'real' one
local function replaceShelfModel(plrData, studioType: "Standard" | "Premium"): Model
    local placeholderShelfModel = studioInteriorModel:FindFirstChild("Shelf")
    local newShelfModel = ReplicatedStorage.Assets.Models.Studio:FindFirstChild("Shelf"):Clone()
    
    -- convert CFrame from objectspace that is relative to plot, to worldspace.
    local itemOffsetCFrame = plrData.Studio.Studios[studioType][currentStudioIndex].StudioEssentials.Shelf.CFrame
    itemOffsetCFrame = DatastoreUtils.TableToCFrame(itemOffsetCFrame)
    local placementCFrame = studioInteriorPlot.CFrame:ToWorldSpace(itemOffsetCFrame)
    newShelfModel:PivotTo(placementCFrame)
    
    placeholderShelfModel:Destroy()
    newShelfModel.Parent = studioInteriorModel
    
    return newShelfModel
end

local function addBookModelToShelf(bookType: "genre" | "topic", name: string)
    local bookModel
    local placementAttachment

    if bookType == "genre" then
        bookModel = ReplicatedStorage.Assets.Models.Studio.GenreBooks:FindFirstChild(name):Clone()
        placementAttachment = shelfModel:FindFirstChild("GenrePlacementParts"):FindFirstChild(genreIterationIndex)
        bookModel.Parent = shelfModel:FindFirstChild("GenreBooks")
        genreIterationIndex += 1
    else
        bookModel = ReplicatedStorage.Assets.Models.Studio.TopicBooks:FindFirstChild(name):Clone()
        placementAttachment = shelfModel:FindFirstChild("TopicPlacementParts"):FindFirstChild(topicIterationIndex)
        bookModel.Parent = shelfModel:FindFirstChild("TopicBooks")
        topicIterationIndex += 1
    end

    local yOffset = bookModel.PrimaryPart.Size.Y * 0.5 -- GETS HEIGHT OF BOOK
    
    if placementAttachment then
        bookModel:PivotTo(placementAttachment.WorldCFrame * CFrame.new(0, yOffset, 0))
    end
end

local function loadShelfModel(plrData, studioType: "Standard" | "Premium")
    local unlockedGenres = plrData.GameDev.Genres
    local unlockedTopics = plrData.GameDev.Topics

    shelfModel = replaceShelfModel(plrData, studioType)

    -- display books on shelf
    for genre in unlockedGenres do
        addBookModelToShelf("genre", genre)
    end

    for topic in unlockedTopics do
        addBookModelToShelf("topic", topic)
    end
end

-- function used for replacing placeholder shelf in studio interior plots with 'real' one
local function replaceComputerModel(plrData, studioType: "Standard" | "Premium"): Model
    local plrComputerLevel = plrData.GameDev.Computer.Level

    local placeholderComputerModel = studioInteriorModel:FindFirstChild("Computer")
    local newComputerModel = ReplicatedStorage.Assets.Models.Studio.Computers:FindFirstChild(plrComputerLevel):Clone()

    local itemOffsetCFrame = plrData.Studio.Studios[studioType][currentStudioIndex].StudioEssentials.Computer.CFrame
    itemOffsetCFrame = DatastoreUtils.TableToCFrame(itemOffsetCFrame)
    local placementCFrame = studioInteriorPlot.CFrame:ToWorldSpace(itemOffsetCFrame)
    newComputerModel:PivotTo(placementCFrame)
    
    placeholderComputerModel:Destroy()

    newComputerModel.Name = "Computer"
    newComputerModel.Parent = studioInteriorModel

    return newComputerModel
end

local function enterStudio(interiorPlrTpPart, plrToVisit: Player)
    local plrToVisitData = Remotes.Data.GetAllData:InvokeServer(plrToVisit)

    -- tp plr into studio interior
    Remotes.GUI.ChangeGuiStatusBindable:Fire("loadingBgSplash", true, { TeleportPart = interiorPlrTpPart })

    local studioExteriorFolder = StudioExteriorsFolder:FindFirstChild(currentStudioIndex)
    local interiorTpPart = studioExteriorFolder:FindFirstChild("InteriorTeleportPart")
    studioInteriorModel = studioInteriorFolder:FindFirstChild("Interior")
    studioInteriorPlacedItems = studioInteriorModel:FindFirstChild("PlacedObjects")
    studioInteriorPlot = studioInteriorModel:FindFirstChild("Plot")
    
    local yOffset = calculateYOffset(studioInteriorModel)

    local studioType: "Standard" | "Premium" = StudioConfig.GetConfig(currentStudioIndex).StudioType

    task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
        studioInteriorModel:PivotTo(interiorTpPart.CFrame * CFrame.new(0, yOffset, 0))
        replaceComputerModel(plrToVisitData, studioType)
        loadShelfModel(plrToVisitData, studioType)
        loadInteriorFurniture()
        loadInteriorStaffMembers(plrToVisitData, studioType)

        studioExteriorFolder:Destroy() -- hide studio exterior from players view
        studioInteriorFolder.Parent = Workspace.TempAssets.Studios
        
        -- set up computer & shelf interaction buttons if the player whose studio is being visited is the same as LocalPlayer
        if plrToVisit == localPlr then
            registerInteractionBtns()
        end
    end)
end

-- when plr exists studio, destroy all traces of the studio interior
local function destroyInterior()
    studioInteriorExitZone:destroy()
    studioInteriorFolder:Destroy()

    -- if plr is leaving their own studio, disconnect all related connections
    resetStudioConnections()
end

local function regenerateExterior()
    local replacedStudioExterior = studioExteriorsCopy[currentStudioIndex]:Clone()
    replacedStudioExterior.Parent = Workspace.Map.Buildings.Studios
end

local function studioInteriorCleanup()
    destroyInterior()
    regenerateExterior()
    resetStudioVariables()
end

local function studioInteriorExitListener()
    local studioInteriorExitHitbox = studioInteriorFolder:FindFirstChild("TeleportHitboxZone", true)

    studioInteriorExitZone = Zone.new(studioInteriorExitHitbox)
    studioInteriorExitZone.localPlayerEntered:Connect(function(_plr: Player)
        Remotes.GUI.ChangeGuiStatusBindable:Fire("loadingBgSplash", true, { TeleportPart = studioExteriorTpPart })
        Remotes.Studio.General.LeaveStudio:FireServer()

        task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
            studioInteriorCleanup()
        end)
    end)
end

local visitOwnStudioRemote = Remotes.Studio.General.VisitOwnStudio
local visitOtherStudioRemote = Remotes.Studio.General.VisitOtherStudio
for _i, remote in { visitOwnStudioRemote, visitOtherStudioRemote } do
    remote.OnClientEvent:Connect(function(studioOwnerId, studioIndex, interiorPlrTpPart, exteriorPlrTpPart, placedFurnitureData, opts: {})
        -- if plr was already in a studio (their own or someone elses)
        if opts and opts["SwitchingStudios"] then
            studioInteriorCleanup()
        end
    
        studioExteriorTpPart = exteriorPlrTpPart
        currentStudioIndex = studioIndex
        studioInteriorFolder = StudioInteriorsFolder:FindFirstChild(currentStudioIndex):Clone()
        studioInteriorFolder.Name = studioOwnerId
        studioItemPlacementFolder = studioInteriorFolder:FindFirstChild("Interior"):FindFirstChild("PlacedObjects")
        interiorFurnitureData = placedFurnitureData
    
        local plrToVisit = Players:GetPlayerByUserId(studioOwnerId)
        enterStudio(interiorPlrTpPart, plrToVisit)
    
        -- listener for when player exits studio
        studioInteriorExitListener()
    
    end)
end

-- leave studio
Remotes.Studio.General.LeaveStudio.OnClientEvent:Connect(function(_opts: {})
    disableInteractionBtns()
end)

Remotes.Studio.BuildMode.EnterBuildMode.OnClientEvent:Connect(function(_studioInventoryData)
    disableInteractionBtns()
end)

Remotes.Studio.General.KickFromStudio.OnClientEvent:Connect(function()
    Remotes.GUI.ChangeGuiStatusBindable:Fire("loadingBgSplash", true, { TeleportPart = studioExteriorTpPart })
    task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
        studioInteriorCleanup()
    end)
end)

Remotes.Studio.BuildMode.ReplicatePlaceItem.OnClientEvent:Connect(function(itemType: string, itemInfo)
    local itemParent

    if itemType == "furniture" or itemType == "staff" then
        itemParent = studioItemPlacementFolder
    elseif itemType == "essential" then
        itemParent = studioInteriorModel
    end

    StudioConfig.PlaceItemOnPlot(itemType, itemInfo, itemParent)
end)

-- Remotes.Studio.BuildMode.RemoveItem:FireClient(plrToUpdate, "staff", { ItemUUID = staffMemberUUID })
Remotes.Studio.BuildMode.RemoveItem.OnClientEvent:Connect(function(itemType: string, itemInfo: {})
    if itemType == "furniture" then
        local furnitureModel = studioItemPlacementFolder:FindFirstChild(itemInfo.ItemUUID)
        if furnitureModel then furnitureModel:Destroy() end

    elseif itemType == "essential" then
        local itemModel = studioInteriorModel:FindFirstChild(itemInfo.ItemName)
        if itemModel then itemModel:Destroy() end
    
    elseif itemType == "staff" then
        local staffMemberModel = studioItemPlacementFolder:FindFirstChild(itemInfo.ItemUUID)
        if staffMemberModel then staffMemberModel:Destroy() end
    end
end)

-- add books to shelves
Remotes.GameDev.GenreTopic.UnlockGenre.OnClientEvent:Connect(function(genreName)
    if localPlr:GetAttribute("InStudio") then addBookModelToShelf("genre", genreName) end
end)
Remotes.GameDev.GenreTopic.UnlockTopic.OnClientEvent:Connect(function(topicName)
    if localPlr:GetAttribute("InStudio") then addBookModelToShelf("topic", topicName) end
end)

-- re-enables placed item interaction btns (e.g. stop viewing shelf, training staff member, etc)
Remotes.Player.StopInspecting.Event:Connect(function()
    registerInteractionBtns()
end)

Remotes.Studio.BuildMode.ExitBuildMode.OnClientEvent:Connect(function(_opts: {})
    registerInteractionBtns()
end)

-- on plr spawn & death
local function characterAdded(char: Model)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        if localPlr:GetAttribute("InStudio") then
            studioInteriorCleanup()
            Remotes.Studio.General.LeaveStudio:FireServer()
        end
    end)
end

if localPlr.Character then characterAdded(localPlr.Character) end

localPlr.CharacterAdded:Connect(characterAdded)




local aaaa = PlayerGui:WaitForChild("AllGui").Studio:WaitForChild("StudioBuildMode"):WaitForChild("TextButton")
aaaa.Activated:Connect(function()
    Remotes.Studio.General.PurchaseNextStudio:FireServer()
end)