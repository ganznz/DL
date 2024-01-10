local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")

local PlacementSystem = require(ReplicatedStorage.Libs:WaitForChild("PlacementSystem"))
local StudioConfig = require(ReplicatedStorage.Configs.Studio:WaitForChild("Studio"))
local MoodFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("MoodFurniture"))
local EnergyFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("EnergyFurniture"))
local HungerFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("HungerFurniture"))
local DecorFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("DecorFurniture"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui
local mouse = localPlr:GetMouse()

local plrPlatformProfile = Remotes.Player.GetPlrPlatformData:InvokeServer()

local studioFurnitureModelsFolder = ReplicatedStorage.Assets.Models.Studio.StudioFurnishing
local StaffMemberModelsFolder = ReplicatedStorage.Assets.Models.StaffMembers

-- INSTANCE VARIABLES
local BuildModeGuiFolder = PlayerGui:WaitForChild("AllGui").Studio:WaitForChild("StudioBuildMode")
local furnitureItemSettingsBillboard: BillboardGui = BuildModeGuiFolder:WaitForChild("FurnitureItemSettings")
local essentialItemSettingsBillboard: BillboardGui = BuildModeGuiFolder:WaitForChild("EssentialItemSettings")
local existingItemSettingBillboards = BuildModeGuiFolder:WaitForChild("ExistingItemSettingBillboards")

-- STATE VARIABLES
local plrData
local placement
local studioInteriorFolder
local placedObjectsFolder
local studioInteriorModel
local studioInteriorPlot
local placeItemConnection = nil
local computerModel = nil
local shelfModel = nil

local function unbindInputs()
    ContextActionService:UnbindAction("Rotate")
    ContextActionService:UnbindAction("Cancel")
end

local function exitPlaceMode()
    placement:Deactivate()
    unbindInputs()

    if placeItemConnection then
        placeItemConnection:Disconnect()
        placeItemConnection = nil
    end
end

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

local function disableModelClickConnection(itemType: "furniture", opts: {})
    if itemType == "furniture" then
        local itemModel = placedObjectsFolder:FindFirstChild(opts["ItemUUID"])
        if not itemModel then return end

        local clickDetector = itemModel:FindFirstChild("ClickDetector", true)
        if clickDetector then clickDetector:Destroy() end

        local itemSettingsBillboard = existingItemSettingBillboards:FindFirstChild(opts["ItemUUID"])
        if itemSettingsBillboard then itemSettingsBillboard:Destroy() end
    
    elseif itemType == "essential" then
        if opts["EssentialItemType"] == "Computer" then
            local clickDetector = computerModel:FindFirstChild("ClickDetector", true)
            if clickDetector then clickDetector:Destroy() end
            
        elseif opts["EssentialItemType"] == "Shelf" then
            local clickDetector = shelfModel:FindFirstChild("ClickDetector", true)
            if clickDetector then clickDetector:Destroy() end
        end

        local itemSettingsBillboard = existingItemSettingBillboards:FindFirstChild(opts["EssentialItemType"])
        if itemSettingsBillboard then itemSettingsBillboard:Destroy() end
    end
end

local function disableAllModelClickConnections()
    -- disable furniture click connections
    for _i, itemModel: Model in placedObjectsFolder:GetChildren() do
        disableModelClickConnection("furniture", { ItemUUID = itemModel.Name })
    end

    -- disable computer & shelf click connections
    if computerModel then
        disableModelClickConnection("essential", { EssentialItemType = "Computer" })
    end
    if shelfModel then
        disableModelClickConnection("essential", { EssentialItemType = "Shelf" })
    end
end

local function registerItemMoveBtn(billboardGui, moveBtn, itemType: "furniture" | "essential")
    moveBtn.Activated:Connect(function()
        local itemModel = billboardGui.Adornee
        local itemInfo

        if itemType == "furniture" then
            itemInfo = {
                ItemName = itemModel:GetAttribute("Name"),
                ItemCategory = itemModel:GetAttribute("Category"),
                ItemUUID = itemModel.Name
            }
        
        elseif itemType == "essential" then
            itemInfo = {
                ItemName = itemModel.Name
            }
        
        elseif itemType == "staff" then
            itemInfo = {
                ItemUUID = itemModel.Name,
                ItemModel = itemModel:GetAttribute("Model")
            }
        end

        Remotes.Studio.BuildMode.EnterPlaceMode:FireServer(itemType, itemInfo, true)
    end)
end

local function registerItemDeleteBtn(billboardGui, deleteBtn, itemType: "furniture")
    deleteBtn.Activated:Connect(function()
        local itemModel = billboardGui.Adornee
        local itemName = itemModel:GetAttribute("Name")
        local itemCategory = itemModel:GetAttribute("Category")
        local itemUUID = itemModel.Name

        if localPlr:GetAttribute("InBuildMode") then
            placement:DestroyGrid()
            localPlr:SetAttribute("InBuildMode", false)
            disableAllModelClickConnections()
        end

        -- prompt UI
        local itemToDelete = {}
        if itemType == "furniture" then
            itemToDelete[itemCategory] = {}
            itemToDelete[itemCategory][itemName] = { itemUUID }
        
        elseif itemType == "staff" then
            itemToDelete = { itemUUID }
        end

        Remotes.GUI.Inventory.DeleteItemPopup:Fire(itemType, itemToDelete)
    end)
end

local function registerItemStoreBtn(billboardGui, storeBtn, itemType: "furniture")
    storeBtn.Activated:Connect(function()
        local itemModel = billboardGui.Adornee
        local itemInfo

        if itemType == "furniture" then
            itemInfo = {
                ItemName = itemModel:GetAttribute("Name"),
                ItemCategory = itemModel:GetAttribute("Category"),
                ItemUUID = itemModel.Name
            }
            -- remove click connection & settings billboard
            disableModelClickConnection("furniture", { ItemUUID = itemInfo.ItemUUID })
        
        elseif itemType == "staff" then
            itemInfo = {
                ItemUUID = itemModel.Name
            }
        end

        Remotes.Studio.BuildMode.StoreItem:FireServer(itemType, itemInfo)
    end)
end

local function registerFurnitureItemSettingButtons(billboard: BillboardGui)
    local settingsContainer = billboard:FindFirstChild("SettingsContainer")
    local deleteBtn = settingsContainer:FindFirstChild("DeleteBtn")
    local moveBtn = settingsContainer:FindFirstChild("MoveBtn")
    local storeBtn = settingsContainer:FindFirstChild("StoreBtn")
    
    local itemModel = billboard.Adornee
    local itemCategory = itemModel:GetAttribute("Category")
    local itemName = itemModel:GetAttribute("Name")
    local itemUUID = itemModel.Name
    local itemLocked = plrData.Inventory.StudioFurnishing[itemCategory][itemName][itemUUID].Locked

    registerItemMoveBtn(billboard, moveBtn, "furniture")
    registerItemStoreBtn(billboard, storeBtn, "furniture")
    if not itemLocked then registerItemDeleteBtn(billboard, deleteBtn, "furniture") else deleteBtn.Visible = false end
end

local function registerStaffMemberItemSettingButtons(billboard: BillboardGui)
    local settingsContainer = billboard:FindFirstChild("SettingsContainer")
    local deleteBtn = settingsContainer:FindFirstChild("DeleteBtn")
    local moveBtn = settingsContainer:FindFirstChild("MoveBtn")
    local storeBtn = settingsContainer:FindFirstChild("StoreBtn")
    
    local itemModel = billboard.Adornee
    local itemUUID = itemModel.Name

    local itemLocked = plrData.Inventory.StaffMembers[itemUUID].Locked
    
    registerItemMoveBtn(billboard, moveBtn, "staff")
    registerItemStoreBtn(billboard, storeBtn, "staff")
    if not itemLocked then registerItemDeleteBtn(billboard, deleteBtn, "staff") else deleteBtn.Visible = false end
end

local function registerEssentialItemSettingButtons(billboard: BillboardGui)
    local settingsContainer = billboard:FindFirstChild("SettingsContainer")
    local moveBtn = settingsContainer:FindFirstChild("MoveBtn")

    registerItemMoveBtn(billboard, moveBtn, "essential")
end


-- modelType: "essential" - these items can't be stored or deleted, only moved
local function registerModelClickConnection(model, modelType: "furniture" | "essential")
    local clickDetector = Instance.new("ClickDetector", model)

    local billboardGui
    if modelType == "furniture" or modelType == "staff" then -- furniture & staff models share same buildmode setting buttons
        billboardGui = furnitureItemSettingsBillboard:Clone()
    elseif modelType == "essential" then
        billboardGui = essentialItemSettingsBillboard:Clone()
    end

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

    if modelType == "furniture" then
        registerFurnitureItemSettingButtons(billboardGui)

    elseif modelType == "essential" then
        registerEssentialItemSettingButtons(billboardGui)
    
    elseif modelType == "staff" then
        registerStaffMemberItemSettingButtons(billboardGui)
    end
end

local function enableAllModelClickConnections()
    -- clear previous connections to prevent duplication
    disableAllModelClickConnections()

    for _i, itemModel: Model in placedObjectsFolder:GetChildren() do
        local itemType = itemModel:GetAttribute("ItemType")
        registerModelClickConnection(itemModel, itemType)
    end

    computerModel = studioInteriorFolder:FindFirstChild("Computer", true)
    shelfModel = studioInteriorFolder:FindFirstChild("Shelf", true)

    if computerModel then registerModelClickConnection(computerModel, "essential") end
    if shelfModel then registerModelClickConnection(shelfModel, "essential") end
end

Remotes.Studio.BuildMode.EnterBuildMode.OnClientEvent:Connect(function(_studioInventoryData)
    plrData = Remotes.Data.GetAllData:InvokeServer()

    localPlr:SetAttribute("InBuildMode", true)

    studioInteriorFolder = Workspace.TempAssets.Studios:FindFirstChild(localPlr.UserId)
    studioInteriorModel = studioInteriorFolder:FindFirstChild("Interior")
    studioInteriorPlot = studioInteriorFolder:FindFirstChild("Plot", true)
    placedObjectsFolder = studioInteriorFolder:FindFirstChild("PlacedObjects", true)

    computerModel = studioInteriorFolder:FindFirstChild("Computer", true)
    shelfModel = studioInteriorFolder:FindFirstChild("Shelf", true)

    placement = PlacementSystem.new(2, studioInteriorPlot)
    placement:RenderGrid()

    enableAllModelClickConnections()
end)

local function rotateItem(_actionName, inputState, _inputObj)
    if placement then
        -- if user on PC
        -- ensures item only rotates once (on key down, not on key up too)
        if inputState and inputState == Enum.UserInputState.Begin then
            placement:Rotate()

        elseif not inputState then
            -- user is on other platform
            placement:Rotate()
        end
    end
end

local function cancelOnTermination(_actionName, inputState, inputObj)
    -- if user on PC
    -- ensures cancel only occurs once (on key down, not on key up too)
    if inputState and inputState == Enum.UserInputState.Begin then
        exitPlaceMode()
        localPlr:SetAttribute("InPlaceMode", false)

    elseif not inputState then
        -- user is on other platform
        exitPlaceMode()
        localPlr:SetAttribute("InPlaceMode", false)
    end
    
    -- reopen build-mode gui & related build-mode functionality declared in other files
    Remotes.Studio.BuildMode.ExitPlaceModeBindable:Fire()
end

local function bindInputs()
    ContextActionService:BindAction("Rotate", rotateItem, false, Enum.KeyCode.R)
    ContextActionService:BindAction("Cancel", cancelOnTermination, false, Enum.KeyCode.X)
end

local function applyBuildModeSettings()
    if plrPlatformProfile.Platform == "pc" then
        bindInputs()
    end
end

Remotes.Studio.BuildMode.EnterPlaceMode.OnClientEvent:Connect(function(itemType: string, itemInfo: {}, movingItem: boolean)
    localPlr:SetAttribute("InPlaceMode", true)

    local itemModel
    local actionType

    if itemType == "furniture" then
        if movingItem then
            actionType = "move"
            itemModel = placedObjectsFolder:FindFirstChild(itemInfo.ItemUUID)
        else
            actionType = "newItem"
            itemModel = studioFurnitureModelsFolder[itemInfo.ItemCategory]:FindFirstChild(itemInfo.ItemName):Clone()
        end
        placement:Activate(itemModel, placedObjectsFolder)

    elseif itemType == "essential" then
        if movingItem then
            actionType = "move"
            itemModel = studioInteriorFolder:FindFirstChild(itemInfo.ItemName, true)
        end
        placement:Activate(itemModel, studioInteriorModel)
    
    elseif itemType == "staff" then
        if movingItem then
            actionType = "move"
            itemModel = placedObjectsFolder:FindFirstChild(itemInfo.ItemUUID)
        else
            actionType = "newItem"
            itemModel = StaffMemberModelsFolder:FindFirstChild(itemInfo.ItemModel):Clone()
            if not itemModel then return end
        end
        placement:Activate(itemModel, placedObjectsFolder)
    end

    applyBuildModeSettings()

    if plrPlatformProfile.Platform == "pc" then
        placeItemConnection = mouse.Button1Down:Connect(function()
            placement:place(itemType, itemInfo, { Action = actionType })
        end)
    end

    disableAllModelClickConnections()
    hideOtherFurnitureItemSettings()
end)

Remotes.Studio.BuildMode.ExitPlaceMode.OnClientEvent:Connect(function(_studioFurnitureInventory)
    exitPlaceMode()

    localPlr:SetAttribute("InPlaceMode", false)

    if localPlr:GetAttribute("InBuildMode") then
        enableAllModelClickConnections()
    end
end)

-- place item in studio
Remotes.Studio.BuildMode.PlaceItem.OnClientEvent:Connect(function(itemType, itemInfo)
    local itemParent

    if itemType == "furniture" or itemType == "staff" then
        itemParent = placedObjectsFolder
    elseif itemType == "essential" then
        itemParent = studioInteriorModel
    end

    StudioConfig.PlaceItemOnPlot(itemType, itemInfo, itemParent)
end)

-- exit build mode
Remotes.Studio.BuildMode.ExitBuildModeBindable.Event:Connect(function()
    placement:DestroyGrid()
    disableAllModelClickConnections()
    localPlr:SetAttribute("InBuildMode", false)
end)

Remotes.Studio.BuildMode.FurnitureItemRotate.Event:Connect(function()
    rotateItem(nil, nil, nil)
end)

Remotes.Studio.BuildMode.FurnitureItemCancel.Event:Connect(function()
    cancelOnTermination(nil, nil, nil)
end)

Remotes.Player.PlatformChanged.OnClientEvent:Connect(function(newPlatformProfile)
    plrPlatformProfile = newPlatformProfile
end)

local function characterAdded(char: Model)
    if localPlr:GetAttribute("InBuildMode") then
        placement:DestroyGrid()
        disableAllModelClickConnections()
    end

    if localPlr:GetAttribute("InPlaceMode") then
        exitPlaceMode()
    end
end

if localPlr.Character then characterAdded(localPlr.Character) end

localPlr.CharacterAdded:Connect(characterAdded)