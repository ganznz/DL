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
            -- item player next upgrades to
            buyBtn.Activated:Connect(function()
                Remotes.Purchase.PurchaseComputer:FireServer(itemIndex)
            end)

            if ComputerConfig.CanUpgrade(plrData) then
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
            -- item player next upgrades to
            buyBtn.Activated:Connect(function()
                Remotes.Purchase.PurchaseRouter:FireServer(itemIndex)
            end)

            if RouterConfig.CanUpgrade(plrData) then
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

local function updateItemShopGui(itemType: "Computers" | "Routers")
    local plrData = Remotes.Data.GetAllData:InvokeServer()
    
    itemShopHeader.Text = itemType
    populateItemShopScrollingFrame(plrData, itemType)
end

Remotes.GUI.ChangeGuiStatusRemote.OnClientEvent:Connect(function(guiName, showGui, options)
    if guiName == "techStoreItemShop" and showGui then
        clearItemShopScrollingFrame()
        updateItemShopGui(options.itemsToDisplay)
        GuiServices.ShowGuiStandard(itemShopContainer, itemShopContainerVisibleGuiPos, itemShopContainerVisibleGuiSize)
    end
end)