local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local PlrPlatformManager = require(ReplicatedStorage:WaitForChild("PlrPlatformManager"))
local PlacementSystem = require(ReplicatedStorage.Libs:WaitForChild("PlacementSystem"))
local MoodFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("MoodFurniture"))
local EnergyFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("EnergyFurniture"))
local HungerFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("HungerFurniture"))
local DecorFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("DecorFurniture"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui
local mouse = localPlr:GetMouse()

local plrPlatformProfile = PlrPlatformManager.GetProfile(localPlr)

local studioFurnitureModelsFolder = ReplicatedStorage.Assets.Models.StudioFurnishing

-- INSTANCE VARIABLES
local buildModeScreenGui = PlayerGui:WaitForChild("BuildMode")
local furnitureItemSettingsBillboard: BillboardGui = buildModeScreenGui:WaitForChild("FurnitureItemSettings")
local existingItemSettingBillboards = buildModeScreenGui:WaitForChild("ExistingItemSettingBillboards")

-- STATE VARIABLES
local char = localPlr.Character or localPlr.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local placement
local studioInteriorFolder
local studioFurnitureFolder
local studioInteriorPlot
local placeItemConnection = nil
local inBuildMode = false
local inPlaceMode = false

local function hideFurnitureItemSettings(billboardGui: BillboardGui)
    local TWEEN_TIME = 0.2
    local tweenInfo = TweenInfo.new(TWEEN_TIME)
    for _i, instance in billboardGui:WaitForChild("SettingsContainer"):GetChildren() do
        if instance:IsA("TextButton") or instance:IsA("ImageButton") then
            local tween = TweenService:Create(instance, tweenInfo, { Size = UDim2.fromScale(0.3, 0) })
            tween:Play()
        end
    end
end

local function hideOtherFurnitureItemSettings(billboardToIgnore: BillboardGui | nil)
    for _i, billboard: BillboardGui in existingItemSettingBillboards:GetChildren() do
        if billboardToIgnore and billboard == billboardToIgnore then continue end
        
        if billboard:GetAttribute("isVisible") then
            hideFurnitureItemSettings(billboard)
            billboard:SetAttribute("isVisible", false)
        end
    end
end


local function showFurnitureItemSettings(billboardGui: BillboardGui)
    billboardGui.Enabled = true
    local tweenInfo = TweenInfo.new(0.2)
    for _i, instance in billboardGui:WaitForChild("SettingsContainer"):GetChildren() do
        if instance:IsA("TextButton") or instance:IsA("ImageButton") then
            local tween = TweenService:Create(instance, tweenInfo, { Size = UDim2.fromScale(0.3, 1) })
            tween:Play()
        end
    end

    -- hide other furniture model settings if open
    hideOtherFurnitureItemSettings(billboardGui)
end

local function registerItemMoveBtn(billboardGui, moveBtn)
    moveBtn.Activated:Connect(function()
        print("move")
        local itemModel = billboardGui.Adornee
        local itemName = itemModel:GetAttribute("Name")
        local itemCategory = itemModel:GetAttribute("Category")
        local itemUUID = itemModel.Name

        Remotes.Studio.EnterPlaceMode:FireServer(itemName, itemCategory, true, itemUUID)
    end)
end

local function registerItemSettingButtons(billboard: BillboardGui)
    local settingsContainer = billboard:FindFirstChild("SettingsContainer")
    local deleteBtn = settingsContainer:FindFirstChild("DeleteBtn")
    local moveBtn = settingsContainer:FindFirstChild("MoveBtn")
    local storeBtn = settingsContainer:FindFirstChild("StoreBtn")

    registerItemMoveBtn(billboard, moveBtn)

    deleteBtn.Activated:Connect(function()
        print("delete")
    end)

    storeBtn.Activated:Connect(function()
        print("store")
    end)
end

local function registerModelClickConnection(model)
    local clickDetector = Instance.new("ClickDetector", model)

    local billboardGui = furnitureItemSettingsBillboard:Clone()
    billboardGui.Name = model.Name
    billboardGui.SizeOffset = Vector2.new(0, (model.PrimaryPart.Size.Y * 0.5) + 1)
    
    -- hide by default
    billboardGui.Enabled = false
    hideFurnitureItemSettings(billboardGui)
    
    billboardGui.Parent = existingItemSettingBillboards
    billboardGui.Adornee = model
    billboardGui:SetAttribute("isVisible", false)

    clickDetector.MouseClick:Connect(function(plr: Player)
        if billboardGui:GetAttribute("isVisible") then
            hideFurnitureItemSettings(billboardGui)
            billboardGui:SetAttribute("isVisible", false)
        else
            showFurnitureItemSettings(billboardGui)
            billboardGui:SetAttribute("isVisible", true)
        end
    end)

    registerItemSettingButtons(billboardGui)
end

local function enableAllModelClickConnections()
    for _i, itemModel: Model in studioFurnitureFolder:GetChildren() do
        registerModelClickConnection(itemModel)
    end
end

local function disableAllModelClickConnections()
    -- disable click connections
    for _i, itemModel: Model in studioFurnitureFolder:GetChildren() do
        local clickDetector = itemModel:FindFirstChild("ClickDetector", true)
        if clickDetector then clickDetector:Destroy() end
    end

    -- delete item settings billboards
    for _i, billboard in existingItemSettingBillboards:GetChildren() do
        billboard:Destroy()
    end
end

local function exitPlaceMode()
    placement:Deactivate()

    if placeItemConnection then
        placeItemConnection:Disconnect()
        placeItemConnection = nil
    end
end

Remotes.Studio.EnterBuildMode.OnClientEvent:Connect(function(_studioInventoryData)
    inBuildMode = true

    studioInteriorFolder = Workspace.TempAssets.Studios:FindFirstChild(localPlr.UserId)
    studioInteriorPlot = studioInteriorFolder:FindFirstChild("Plot", true)
    studioFurnitureFolder = studioInteriorFolder:FindFirstChild("PlacedObjects", true)

    placement = PlacementSystem.new(2, studioInteriorPlot, studioFurnitureFolder, false)
    placement:RenderGrid()

    enableAllModelClickConnections()
end)    

Remotes.Studio.EnterPlaceMode.OnClientEvent:Connect(function(itemName: string, itemCategory: string, movingItem: boolean, itemUUID: string | nil)
    inPlaceMode = true
    
    local itemModel
    local actionType: "newItem" | "move"
    if movingItem then
        itemModel = studioFurnitureFolder:FindFirstChild(itemUUID)
        actionType = "move"
        
    else
        itemModel = studioFurnitureModelsFolder[itemCategory]:FindFirstChild(itemName):Clone()
        actionType = "newItem"
    end

    placement:Activate(itemModel)

    if plrPlatformProfile.Platform == "pc" then
        placeItemConnection = mouse.Button1Down:Connect(function()
            placement:place(Remotes.Studio.PlaceItem, itemName, {
                action = actionType,
                category = itemCategory,
                uuid = itemUUID,
            })
        end)
    end

    disableAllModelClickConnections()
    hideOtherFurnitureItemSettings()
end)

Remotes.Studio.ExitPlaceMode.OnClientEvent:Connect(function(_studioFurnitureInventory)
    exitPlaceMode()
    inPlaceMode = false

    if inBuildMode then
        -- clear all connections to prevent duplicating
        disableAllModelClickConnections()
        
        enableAllModelClickConnections()
    end
end)


-- place item in studio
Remotes.Studio.PlaceItem.OnClientEvent:Connect(function(itemName, itemCategory, itemCFrame, itemUUID)
    local itemModelToPlace = studioFurnitureModelsFolder[itemCategory]:FindFirstChild(itemName):Clone()
    itemModelToPlace:PivotTo(itemCFrame)
    itemModelToPlace.Name = itemUUID
    itemModelToPlace.Parent = studioFurnitureFolder
end)

-- exit place mode
Remotes.Studio.ExitBuildMode.Event:Connect(function()
    placement:DestroyGrid()
    disableAllModelClickConnections()
    inBuildMode = false
end)

humanoid.Died:Connect(function()
    if inBuildMode then
        placement:DestroyGrid()
        inBuildMode = false
        disableAllModelClickConnections()
    end

    if inPlaceMode then
        exitPlaceMode()
        inPlaceMode = false
    end
end)

localPlr.CharacterAdded:Connect(function(character: Model)
    char = character
    humanoid = char:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        if inBuildMode then
            placement:DestroyGrid()
            inBuildMode = false
            disableAllModelClickConnections()
        end
    
        if inPlaceMode then
            exitPlaceMode()
            inPlaceMode = false
        end
    end)
end)