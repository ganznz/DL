local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))
local GlobalVariables = require(ReplicatedStorage:WaitForChild("GlobalVariables"))
local ComputerConfig = require(ReplicatedStorage.Configs:WaitForChild("Computer"))
local RouterConfig = require(ReplicatedStorage.Configs:WaitForChild("Router"))

local Remotes = ReplicatedStorage.Remotes

local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui

-- item shop gui
local itemShopContainer = PlayerGui:WaitForChild("TechStore"):WaitForChild("ItemShopContainer")
local itemShopHeader = itemShopContainer.HeaderText
local itemShopExitBtn = itemShopContainer.ExitBtn
local itemShopScrollingFrame = itemShopContainer.ScrollingFrame
local itemShopScrollingFrameTemplate = itemShopScrollingFrame.Template

local itemShopContainerVisibleGuiPos = itemShopContainer.Position
local itemShopContainerVisibleGuiSize = itemShopContainer.Size

GuiServices.DefaultMainGuiStyling(itemShopContainer, GlobalVariables.Gui.MainGuiInvisiblePosOffset)

local COMPUTER_ITEM_STAT_TEMPLATE = "Power: AMT"
local ROUTER_ITEM_STAT_TEMPLATE = "Upload Speed: AMT/sec"
local BUY_BTN_PRICE_TEMPLATE = "AMT Cash"
local purchasableItemBtnColour = GlobalVariables.Gui.ValidGreenColour
local notPurchasableItemBtnColour = GlobalVariables.Gui.InvalidGreyColour
local cantAffordBtnColour = GlobalVariables.Gui.CantAffordColour

local buyBtnConnections = {
    Computers = {},
    Routers = {}
}

local function clearItemShopScrollingFrame()
    for _i, instance in itemShopScrollingFrame:GetChildren() do
        if instance.Name == "Template" or instance.Name == "UIListLayout" then continue end
        instance:Destroy()
    end
end

local function createComputerScrollingFrameItem(plrData, itemIndex, itemConfig: ComputerConfig.ComputerConfig)
    local plrComputerLevel = plrData.GameDev.Computer
    
    local template = itemShopScrollingFrameTemplate:Clone()
    template.Name = itemIndex
    template.LayoutOrder = itemIndex
    template.Parent = itemShopScrollingFrame
    
    local itemNameText = template:FindFirstChild("ItemName")
    itemNameText.Text = itemConfig.Name
    local itemStatText = template:FindFirstChild("ItemStat")
    itemStatText.Text = COMPUTER_ITEM_STAT_TEMPLATE:gsub("AMT", itemConfig.AddOns)
    
    local buyBtn = template:FindFirstChild("BuyBtn")
    if plrComputerLevel >= itemIndex then
        -- already owns item
        buyBtn.BackgroundColor3 = purchasableItemBtnColour
        buyBtn.Text = "Owned"
        
        elseif plrComputerLevel + 1 == itemIndex then
            if ComputerConfig.CanUpgrade(plrData) then
                -- item player next upgrades to
                buyBtnConnections.Computers[itemIndex] = buyBtn.Activated:Connect(function()
                    Remotes.Purchase.PurchaseComputer:FireServer(itemIndex)
                end)
                buyBtn.BackgroundColor3 = purchasableItemBtnColour
            else
                buyBtn.BackgroundColor3 = cantAffordBtnColour
        end
        buyBtn.Text = BUY_BTN_PRICE_TEMPLATE:gsub("AMT", ComputerConfig.GetItemPrice(itemIndex))
        
    else
        -- item is locked
        buyBtn.BackgroundColor3 = notPurchasableItemBtnColour
        buyBtn.Text = "Locked"
    end

    local vpFrame = template:FindFirstChild("ViewportFrame")
    local vpCamera = Instance.new("Camera", vpFrame)
    local itemModel = ComputerConfig.GetModel(itemIndex)
    if itemModel then GuiServices.GenerateViewportFrame(vpFrame, vpCamera, itemModel, Vector3.new(-6, 4, 3)) end

    template.Visible = true
end

local function createRouterScrollingFrameItem(plrData, itemIndex, itemConfig: RouterConfig.RouterConfig)
    local plrRouterLevel = plrData.GameDev.Router
    
    local template = itemShopScrollingFrameTemplate:Clone()
    template.Name = itemIndex
    template.LayoutOrder = itemIndex
    template.Parent = itemShopScrollingFrame
    
    local itemNameText = template:FindFirstChild("ItemName")
    itemNameText.Text = itemConfig.Name
    local itemStatText = template:FindFirstChild("ItemStat")
    itemStatText.Text = ROUTER_ITEM_STAT_TEMPLATE:gsub("AMT", itemConfig.UploadSpeed)
    
    local buyBtn = template:FindFirstChild("BuyBtn")
    if plrRouterLevel >= itemIndex then
        -- already owns item
        buyBtn.BackgroundColor3 = purchasableItemBtnColour
        buyBtn.Text = "Owned"
        
    elseif plrRouterLevel + 1 == itemIndex then

        if RouterConfig.CanUpgrade(plrData) then
            -- item player next upgrades to
            buyBtnConnections.Routers[itemIndex] = buyBtn.Activated:Connect(function()
                Remotes.Purchase.PurchaseRouter:FireServer(itemIndex)
            end)
            buyBtn.BackgroundColor3 = purchasableItemBtnColour
        else
            buyBtn.BackgroundColor3 = cantAffordBtnColour
        end
        buyBtn.Text = BUY_BTN_PRICE_TEMPLATE:gsub("AMT", RouterConfig.GetItemPrice(itemIndex))
        
    else
        -- item is locked
        buyBtn.BackgroundColor3 = notPurchasableItemBtnColour
        buyBtn.Text = "Locked"
    end

    local vpFrame = template:FindFirstChild("ViewportFrame")
    local vpCamera = Instance.new("Camera", vpFrame)
    local itemModel = RouterConfig.GetModel(itemIndex)
    if itemModel then GuiServices.GenerateViewportFrame(vpFrame, vpCamera, itemModel, Vector3.new(-6, 4, 3)) end

    template.Visible = true
end

local function populateItemShopScrollingFrame(plrData, itemType: "Computers" | "Routers")
    local allItems
    if itemType == "Computers" then
        allItems = ComputerConfig.Config
        for key, itemConfig: ComputerConfig.ComputerConfig in allItems do
            createComputerScrollingFrameItem(plrData, key, itemConfig)
        end
    elseif itemType == "Routers" then
        allItems = RouterConfig.Config
        for key, itemConfig: RouterConfig.RouterConfig in allItems do
            createRouterScrollingFrameItem(plrData, key, itemConfig)
        end
    end
end

local function generateItemShopGui(itemType: "Computers" | "Routers")
    local plrData = Remotes.Data.GetAllData:InvokeServer()
    
    itemShopHeader.Text = itemType
    populateItemShopScrollingFrame(plrData, itemType)
end

local function updateItemShopGui(itemType: "Computers" | "Routers", purchasedItemIndex: number)
    local plrData = Remotes.Data.GetAllData:InvokeServer()
    local itemConfig
    local purchaseRemote
    if itemType == "Computers" then
        itemConfig = ComputerConfig
        purchaseRemote = "PurchaseComputer"
    elseif itemType == "Routers" then
        itemConfig = RouterConfig
        purchaseRemote = "PurchaseRouter"
    end

    for _i, instance in itemShopScrollingFrame:GetChildren() do
        if instance.Name == "Template" or instance.Name == "UIListLayout" then continue end
        
        local itemIndex = tonumber(instance.Name)

        -- update buttons from newly bought item onwards
        if tonumber(itemIndex) < purchasedItemIndex then continue end

        local buyBtn = instance:FindFirstChild("BuyBtn")
        if tonumber(itemIndex) == purchasedItemIndex then
            -- item that was just purchased
            buyBtn.BackgroundColor3 = purchasableItemBtnColour
            buyBtn.Text = "Owned"

            -- disconnect connection so player can't click/purchase using this btn again
            buyBtnConnections[itemType][purchasedItemIndex]:Disconnect()

        elseif tonumber(itemIndex) == purchasedItemIndex + 1 then
            -- item player next upgrades to
            if itemConfig.CanUpgrade(plrData) then
                buyBtnConnections[itemType][itemIndex] = buyBtn.Activated:Connect(function()
                    Remotes.Purchase[purchaseRemote]:FireServer(itemIndex)
                end)
                buyBtn.BackgroundColor3 = purchasableItemBtnColour
            else
                buyBtn.BackgroundColor3 = cantAffordBtnColour
            end
            buyBtn.Text = BUY_BTN_PRICE_TEMPLATE:gsub("AMT", itemConfig.GetItemPrice(tonumber(itemIndex)))
        
        else
            -- item is locked
            buyBtn.BackgroundColor3 = notPurchasableItemBtnColour
            buyBtn.Text = "Locked"
        end
    end
end

itemShopExitBtn.Activated:Connect(function()
    GuiServices.HideGuiStandard(itemShopContainer,
        UDim2.new(itemShopContainerVisibleGuiPos.X.Scale, 0, itemShopContainerVisibleGuiPos.Y.Scale + GlobalVariables.Gui.MainGuiInvisiblePosOffset, 0),
        UDim2.new(itemShopContainerVisibleGuiSize.X.Scale, 0, itemShopContainerVisibleGuiSize.Y.Scale - 0.2, 0))
end)

Remotes.Purchase.PurchaseComputer.OnClientEvent:Connect(function(purchasedItemIndex)
    updateItemShopGui("Computers", purchasedItemIndex)
end)

Remotes.Purchase.PurchaseRouter.OnClientEvent:Connect(function(purchasedItemIndex)
    updateItemShopGui("Routers", purchasedItemIndex)
end)

Remotes.GUI.ChangeGuiStatusRemote.OnClientEvent:Connect(function(guiName, showGui, options)
    if guiName == "techStoreItemShop" and showGui then
        clearItemShopScrollingFrame()
        generateItemShopGui(options.itemsToDisplay)
        GuiServices.ShowGuiStandard(itemShopContainer, itemShopContainerVisibleGuiPos, itemShopContainerVisibleGuiSize, GlobalVariables.Gui.GuiBackdropColourDefault)
    end
end)
