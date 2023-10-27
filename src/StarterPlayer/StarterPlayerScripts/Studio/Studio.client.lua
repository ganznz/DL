local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlobalVariables = require(ReplicatedStorage:WaitForChild("GlobalVariables"))
local Zone = require(ReplicatedStorage.Libs.Zone)

local Remotes = ReplicatedStorage.Remotes
local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

local StudioExteriorsFolder = Workspace:WaitForChild("Map").Buildings.Studios
local StudioInteriorsFolder = ReplicatedStorage:WaitForChild("Assets").Models.Studios

local inStudio = false
local currentStudioIndex = nil
local studioInteriorFolder = nil
local studioFurnitureFolder = nil
local studioInteriorExitZone = nil
local studioExteriorTpPart = nil
local interiorFurnitureData = nil

-- make a copy of all studio exteriors, so when player leaves a studio and
-- needs to make the studio exterior visible again, copy it from this table
-- and put it back into the workspace 'StudioExteriorsFolder'
local studioExteriorsCopy = {}
for _i, studioExteriorFolder in StudioExteriorsFolder:GetChildren() do
    studioExteriorsCopy[tonumber(studioExteriorFolder.Name)] = studioExteriorFolder:Clone()
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

local function getFurnitureItemModel(itemName: string, itemCategory: string)
    return ReplicatedStorage.Assets.Models.StudioFurnishing[itemCategory]:FindFirstChild(itemName):Clone()
end

local function placeFurnitureItem(model: Model, itemUUID: string, itemCFrame: CFrame)
    model:PivotTo(itemCFrame)
    model.Name = itemUUID
    model.Parent = studioFurnitureFolder
end

local function loadInteriorFurniture()
    for itemCategory, itemsInCategory in interiorFurnitureData do
        for itemName, allItemInstances in itemsInCategory do
            for itemUUID, itemData in allItemInstances do
                local itemCFrame = itemData.CFrame
                local itemModel = getFurnitureItemModel(itemName, itemCategory)
                if itemModel then
                    placeFurnitureItem(itemModel, itemUUID, itemCFrame)
                end
            end
        end
    end
end

local function enterStudio(interiorPlrTpPart)
    -- tp plr into studio interior
    Remotes.GUI.ChangeGuiStatusBindable:Fire("loadingBgSplash", true, { TeleportPart = interiorPlrTpPart })

    local studioExteriorFolder = StudioExteriorsFolder:FindFirstChild(currentStudioIndex)
    local interiorTpPart = studioExteriorFolder:FindFirstChild("InteriorTeleportPart")
    local studioInteriorModel = studioInteriorFolder:FindFirstChild("Interior")
    
    local yOffset = calculateYOffset(studioInteriorModel)

    task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
        studioInteriorModel:PivotTo(interiorTpPart.CFrame * CFrame.new(0, yOffset, 0))
        loadInteriorFurniture()
        studioExteriorFolder:Destroy() -- hide studio exterior from players view
        studioInteriorFolder.Parent = Workspace.TempAssets.Studios
    end)
end

-- when plr exists studio, destroy all traces of the studio interior
local function destroyInterior()
    studioInteriorExitZone:destroy()
    studioInteriorFolder:Destroy()
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
        Remotes.Studio.LeaveStudio:FireServer()
        inStudio = false

        task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
            destroyInterior()
            regenerateExterior()
            resetStudioVariables()
        end)
    end)
end

Remotes.Studio.VisitOwnStudio.OnClientEvent:Connect(function(studioOwnerId, studioIndex, interiorPlrTpPart, exteriorPlrTpPart, placedFurnitureData)
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

    enterStudio(interiorPlrTpPart)

    -- listener for when player exits studio
    studioInteriorExitListener()

end)

Remotes.Studio.VisitOtherStudio.OnClientEvent:Connect(function(studioOwnerId, studioIndex, interiorPlrTpPart, exteriorPlrTpPart, placedFurnitureData)
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

    enterStudio(interiorPlrTpPart)

    -- listener for when player exits studio
    studioInteriorExitListener()
end)

Remotes.Studio.KickFromStudio.OnClientEvent:Connect(function()
    inStudio = false
    Remotes.GUI.ChangeGuiStatusBindable:Fire("loadingBgSplash", true, { TeleportPart = studioExteriorTpPart })
    task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
        destroyInterior()
        regenerateExterior()
        resetStudioVariables()
    end)
end)

Remotes.Studio.ReplicatePlaceItem.OnClientEvent:Connect(function(itemName: string, itemCategory: string, itemCFrame, itemUUID)
    -- check that plr is ACTUALLY inside studio
    if not studioInteriorFolder then return end

    local itemModelToPlace = getFurnitureItemModel(itemName, itemCategory)
    if itemModelToPlace then
        placeFurnitureItem(itemModelToPlace, itemUUID, itemCFrame )
    end
end)

humanoid.Died:Connect(function()
    if inStudio then
        inStudio = false
        destroyInterior()
        regenerateExterior()
        resetStudioVariables()
        Remotes.Studio.LeaveStudio:FireServer()
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
            Remotes.Studio.LeaveStudio:FireServer()
        end
    end)
end)


local PlayerGui = plr.PlayerGui

local aaaa = PlayerGui:WaitForChild("BuildMode"):WaitForChild("TextButton")
aaaa.Activated:Connect(function()
    Remotes.Studio.PurchaseNextStudio:FireServer()
end)