local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlobalVariables = require(ReplicatedStorage:WaitForChild("GlobalVariables"))
local Zone = require(ReplicatedStorage.Libs:WaitForChild("Zone"))
local StudioConfig = require(ReplicatedStorage.Configs:WaitForChild("Studio"))
local CameraControls = require(ReplicatedStorage.Libs:WaitForChild("CameraControls"))
local PlayerServices = require(ReplicatedStorage.Utils.Player:WaitForChild("Player"))
local DatastoreUtils = require(ReplicatedStorage.Utils.DS:WaitForChild("DatastoreUtils"))

local Remotes = ReplicatedStorage.Remotes
local plr = Players.LocalPlayer
local PlayerGui = plr.PlayerGui
local camera = Workspace:WaitForChild("Camera")

local StudioExteriorsFolder = Workspace:WaitForChild("Map").Buildings.Studios
local StudioInteriorsFolder = ReplicatedStorage:WaitForChild("Assets").Models.Studio.Studios

-- state variables
local char = plr.Character or plr.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

local inStudio = false
local studioExteriorTpPart = nil
local interiorFurnitureData = nil
local currentStudioIndex = nil
local studioInteriorFolder = nil
local studioInteriorPlot = nil
local studioFurnitureFolder = nil
local studioInteriorModel = nil
local studioInteriorExitZone = nil

local computerModel = nil
local shelfModel = nil

-- connections
local ComputerShelfInteractionBtnConnection = nil -- connection used for interacting w/ computer & shelf. Disconnect when plr leaves their studio

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
    inStudio = false
    currentStudioIndex = nil
    studioInteriorFolder = nil
    studioInteriorExitZone = nil
    studioExteriorTpPart = nil
end

local function placeFurnitureItem(model: Model, itemUUID: string, itemOffsetCFrame: CFrame)
    -- convert CFrame from objectspace that is relative to plot, to worldspace.
    local placementCFrame = studioInteriorPlot.CFrame:ToWorldSpace(itemOffsetCFrame)

    model:PivotTo(placementCFrame)
    model.Name = itemUUID
    model.Parent = studioFurnitureFolder
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

local function disableInteractionBtns()
    if ComputerShelfInteractionBtnConnection then ComputerShelfInteractionBtnConnection:Disconnect() end
    ComputerShelfInteractionBtnConnection = nil
    
    local shelfInteractionBillboard = PlayerGui.AllGui.Studio:FindFirstChild("ShelfInteractionSettings")
    if shelfInteractionBillboard then shelfInteractionBillboard.Enabled = false end

    local computerInteractionBillboard = PlayerGui.AllGui.Studio:FindFirstChild("ComputerInteractionSettings")
    if computerInteractionBillboard then computerInteractionBillboard.Enabled = false end
end

local function registerShelfViewBtn(viewBtn)
    viewBtn.Activated:Connect(function()
        local cameraPos: Vector3 = shelfModel:FindFirstChild("CameraPositionPart").Position
        local cameraLookAt: Vector3 = shelfModel:FindFirstChild("CameraLookAt").Position

        PlayerServices.HidePlayer(plr, true)
        CameraControls.FocusOnObject(plr, camera, cameraPos, cameraLookAt, true, true)

        disableInteractionBtns()
        Remotes.GUI.Studio.ViewShelf:Fire()
    end)
end

local function registerInteractionBtns()
    local shelfInteractionBillboard = PlayerGui.AllGui.Studio:FindFirstChild("ShelfInteractionSettings")
    local shelfViewBtn = shelfInteractionBillboard:FindFirstChild("View", true)
    local shelfViewDistance = 15 -- studs
    shelfInteractionBillboard.Adornee = shelfModel.PrimaryPart

    local computerInteractionBillboard = PlayerGui.AllGui.Studio:FindFirstChild("ComputerInteractionSettings")
    local computerMakeGameBtn = computerInteractionBillboard:FindFirstChild("MakeGame", true)
    local computerUpgradeBtn = computerInteractionBillboard:FindFirstChild("Upgrade", true)
    local computerViewDistance = 15
    computerInteractionBillboard.Adornee = computerModel.PrimaryPart

    registerShelfViewBtn(shelfViewBtn)

    -- if computer and shelf are near eachother, only show interaction btns for whichever item is closer to plr
    ComputerShelfInteractionBtnConnection = RunService.Stepped:Connect(function()

        local shelfDistanceFromPlr = (char:FindFirstChild("HumanoidRootPart").Position - shelfInteractionBillboard.Adornee.Position).Magnitude
        local computerDistanceFromPlr = (char:FindFirstChild("HumanoidRootPart").Position - computerInteractionBillboard.Adornee.Position).Magnitude
        
        -- check if plr is within viewing distance
        local isShelfInteractable = shelfDistanceFromPlr <= shelfViewDistance and (shelfDistanceFromPlr < computerDistanceFromPlr)
        local isComputerInteractable = computerDistanceFromPlr <= computerViewDistance and (computerDistanceFromPlr < shelfDistanceFromPlr)
        
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


local function loadShelfModel(plrData, studioType: "Standard" | "Premium")
    local unlockedGenres = plrData.GameDev.Genres
    local unlockedTopics = plrData.GameDev.Topics

    shelfModel = replaceShelfModel(plrData, studioType)

    -- display books on shelf
    local genreIterationIndex = 1
    local genreBooksFolder = shelfModel:FindFirstChild("GenreBooks")
    for genre in unlockedGenres do
        local genreBookModel = ReplicatedStorage.Assets.Models.Studio.GenreBooks:FindFirstChild(genre):Clone()
        local yOffset = genreBookModel.PrimaryPart.Size.Y * 0.5 -- GETS HEIGHT OF BOOK
        
        local placementAttachment = shelfModel:FindFirstChild("GenrePlacementParts"):FindFirstChild(genreIterationIndex)
        if placementAttachment then
            genreBookModel.Parent = genreBooksFolder

            genreBookModel:PivotTo(placementAttachment.WorldCFrame * CFrame.new(0, yOffset, 0))
            genreIterationIndex += 1
        end
    end

    local topicIterationIndex = 1
    local topicBooksFolder = shelfModel:FindFirstChild("TopicBooks")
    for topic in unlockedTopics do
        local topicBookModel = ReplicatedStorage.Assets.Models.Studio.TopicBooks:FindFirstChild(topic):Clone()
        local yOffset = topicBookModel.PrimaryPart.Size.Y * 0.5 -- GETS HEIGHT OF BOOK
        
        local placementAttachment = shelfModel:FindFirstChild("TopicPlacementParts"):FindFirstChild(topicIterationIndex)
        if placementAttachment then
            topicBookModel.Parent = topicBooksFolder

            topicBookModel:PivotTo(placementAttachment.WorldCFrame * CFrame.new(0, yOffset, 0))
            topicIterationIndex += 1
        end
    end

    return shelfModel
end

-- function used for replacing placeholder shelf in studio interior plots with 'real' one
local function replaceComputerModel(plrData, studioType: "Standard" | "Premium"): Model
    local plrComputerLevel = plrData.GameDev.Computer

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

local function loadComputerModel(plrData, studioType: "Standard" | "Premium")
    computerModel = replaceComputerModel(plrData, studioType)
end

local function enterStudio(interiorPlrTpPart, plrToVisit: Player)
    local plrToVisitData = Remotes.Data.GetAllData:InvokeServer(plrToVisit)

    -- tp plr into studio interior
    Remotes.GUI.ChangeGuiStatusBindable:Fire("loadingBgSplash", true, { TeleportPart = interiorPlrTpPart })

    local studioExteriorFolder = StudioExteriorsFolder:FindFirstChild(currentStudioIndex)
    local interiorTpPart = studioExteriorFolder:FindFirstChild("InteriorTeleportPart")
    studioInteriorModel = studioInteriorFolder:FindFirstChild("Interior")
    studioInteriorPlot = studioInteriorModel:FindFirstChild("Plot")
    
    local yOffset = calculateYOffset(studioInteriorModel)

    local studioType: "Standard" | "Premium" = StudioConfig.GetConfig(currentStudioIndex).StudioType

    task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
        studioInteriorModel:PivotTo(interiorTpPart.CFrame * CFrame.new(0, yOffset, 0))
        loadComputerModel(plrToVisitData, studioType)
        loadShelfModel(plrToVisitData, studioType)
        loadInteriorFurniture()

        studioExteriorFolder:Destroy() -- hide studio exterior from players view
        studioInteriorFolder.Parent = Workspace.TempAssets.Studios
        
        -- set up computer & shelf interaction buttons if the player whose studio is being visited is the same as LocalPlayer
        if plrToVisit == plr then
            registerInteractionBtns()
        end
    end)
end

-- when plr exists studio, destroy all traces of the studio interior
local function destroyInterior()
    studioInteriorExitZone:destroy()
    studioInteriorFolder:Destroy()

    -- if plr is leaving their own studio, disconnect computer & shelf interactions
    if ComputerShelfInteractionBtnConnection then ComputerShelfInteractionBtnConnection:Disconnect() end
    ComputerShelfInteractionBtnConnection = nil
end

local function regenerateExterior()
    local replacedStudioExterior = studioExteriorsCopy[currentStudioIndex]:Clone()
    replacedStudioExterior.Parent = Workspace.Map.Buildings.Studios
end

local function studioInteriorExitListener()
    local studioInteriorExitHitbox = studioInteriorFolder:FindFirstChild("TeleportHitboxZone", true)

    studioInteriorExitZone = Zone.new(studioInteriorExitHitbox)
    studioInteriorExitZone.localPlayerEntered:Connect(function(_plr: Player)
        Remotes.GUI.ChangeGuiStatusBindable:Fire("loadingBgSplash", true, { TeleportPart = studioExteriorTpPart })
        Remotes.Studio.General.LeaveStudio:FireServer()
        inStudio = false

        task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
            destroyInterior()
            regenerateExterior()
            resetStudioVariables()
        end)
    end)
end

Remotes.Studio.General.VisitOwnStudio.OnClientEvent:Connect(function(studioOwnerId, studioIndex, interiorPlrTpPart, exteriorPlrTpPart, placedFurnitureData)
    -- if plr was already in a studio (their own or someone elses)
    if inStudio then
        destroyInterior()
        regenerateExterior()
        resetStudioVariables()
    end
    
    inStudio = true
    studioExteriorTpPart = exteriorPlrTpPart
    currentStudioIndex = studioIndex
    studioInteriorFolder = StudioInteriorsFolder:FindFirstChild(currentStudioIndex):Clone()
    studioInteriorFolder.Name = studioOwnerId
    studioFurnitureFolder = studioInteriorFolder:FindFirstChild("Interior"):FindFirstChild("PlacedObjects")
    interiorFurnitureData = placedFurnitureData

    local plrToVisit = Players:GetPlayerByUserId(studioOwnerId)
    enterStudio(interiorPlrTpPart, plrToVisit)

    -- listener for when player exits studio
    studioInteriorExitListener()

end)

Remotes.Studio.General.VisitOtherStudio.OnClientEvent:Connect(function(studioOwnerId, studioIndex, interiorPlrTpPart, exteriorPlrTpPart, placedFurnitureData)
    -- if plr was already in a studio (their own or someone elses)
    if inStudio then
        destroyInterior()
        regenerateExterior()
        resetStudioVariables()
    end

    inStudio = true
    studioExteriorTpPart = exteriorPlrTpPart
    currentStudioIndex = studioIndex
    studioInteriorFolder = StudioInteriorsFolder:FindFirstChild(currentStudioIndex):Clone()
    studioInteriorFolder.Name = studioOwnerId
    studioFurnitureFolder = studioInteriorFolder:FindFirstChild("Interior"):FindFirstChild("PlacedObjects")
    interiorFurnitureData = placedFurnitureData

    local plrToVisit = Players:GetPlayerByUserId(studioOwnerId)
    enterStudio(interiorPlrTpPart, plrToVisit)

    -- listener for when player exits studio
    studioInteriorExitListener()
end)

Remotes.Studio.General.KickFromStudio.OnClientEvent:Connect(function()
    inStudio = false
    Remotes.GUI.ChangeGuiStatusBindable:Fire("loadingBgSplash", true, { TeleportPart = studioExteriorTpPart })
    task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
        destroyInterior()
        regenerateExterior()
        resetStudioVariables()
    end)
end)

Remotes.Studio.BuildMode.ReplicatePlaceItem.OnClientEvent:Connect(function(itemType: string, itemInfo)
    -- check that plr is ACTUALLY inside studio
    if not studioInteriorFolder then return end

    local itemModelToPlace
    if itemType == "furniture" then
        itemModelToPlace = StudioConfig.GetFurnitureItemModel(itemInfo.ItemName, itemInfo.ItemCategory)
        StudioConfig.PlaceItemOnPlot(itemType, itemModelToPlace, itemInfo, studioFurnitureFolder)

    elseif itemType == "essentials" then
        itemModelToPlace = studioInteriorModel:FindFirstChild(itemInfo.ItemName)
        StudioConfig.PlaceItemOnPlot(itemType, itemModelToPlace, itemInfo, studioInteriorModel)
    end
end)

Remotes.Studio.BuildMode.RemoveItem.OnClientEvent:Connect(function(itemType: string, itemInfo: {})
    if itemType == "furniture" then
        local furnitureModel = studioFurnitureFolder:FindFirstChild(itemInfo.ItemUUID)
        if furnitureModel then furnitureModel:Destroy() end

    elseif itemType == "essential" then
        local itemModel = studioInteriorModel:FindFirstChild(itemInfo.ItemName)
        if itemModel then itemModel:Destroy() end
    end
end)

-- plr stopped viewing shelf
Remotes.GUI.Studio.StopViewingShelf.Event:Connect(function()
    PlayerServices.ShowPlayer(plr, true)
    CameraControls.SetDefault(plr, camera, true)
    registerInteractionBtns()
end)

humanoid.Died:Connect(function()
    if inStudio then
        inStudio = false
        destroyInterior()
        regenerateExterior()
        resetStudioVariables()
        Remotes.Studio.General.LeaveStudio:FireServer()
    end
end)

plr.CharacterAdded:Connect(function(character: Model)
    char = character
    humanoid = char:WaitForChild("Humanoid")

    humanoid.Died:Connect(function()
        if inStudio then
            destroyInterior()
            regenerateExterior()
            resetStudioVariables()
            Remotes.Studio.General.LeaveStudio:FireServer()
        end
    end)
end)





local aaaa = PlayerGui:WaitForChild("AllGui").Studio:WaitForChild("StudioBuildMode"):WaitForChild("TextButton")
aaaa.Activated:Connect(function()
    Remotes.Studio.General.PurchaseNextStudio:FireServer()
end)