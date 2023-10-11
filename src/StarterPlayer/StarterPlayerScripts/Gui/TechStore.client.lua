local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))
local GlobalVariables = require(ReplicatedStorage:WaitForChild("GlobalVariables"))
local ComputerConfig = require(ReplicatedStorage.Configs:WaitForChild("Computer"))
-- add router config

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
local BUY_BTN_PRICE_TEMPLATE = "AMT Cash"
local purchasableItemBtnColour = GuiServices.ValidGreenColour
local notPurchasableItemBtnColour = GuiServices.InvalidGreyColour

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
    template.LayoutOrder = itemConfig.Price -- orders from cheapest item first
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
            if ComputerConfig.CanUpgrade(plrData) then
                buyBtn.BackgroundColor3 = purchasableItemBtnColour
            else
                buyBtn.BackgroundColor3 = notPurchasableItemBtnColour
        end
        buyBtn.Text = BUY_BTN_PRICE_TEMPLATE:gsub("AMT", ComputerConfig.GetItemPrice(itemIndex))
        
    else
        -- item is locked
        buyBtn.BackgroundColor3 = notPurchasableItemBtnColour
        buyBtn.Text = "Locked"
    end

    local vpFrame = template:FindFirstChild("ViewportFrame")
    local vpCamera = Instance.new("Camera", vpFrame)
    vpFrame.CurrentCamera = vpCamera
    local itemModel = ComputerConfig.GetModel(itemIndex)
    if itemModel then
        itemModel.Parent = vpFrame
        vpCamera.CFrame = CFrame.new(itemModel.PrimaryPart.Position + Vector3.new(-6, 4, 3), itemModel.PrimaryPart.Position)
    end
    
    template.Visible = true
end

local function populateItemShopScrollingFrame(plrData, itemType: "Computers" | "Routers")
    local allItems
    if itemType == "Computers" then
        allItems = ComputerConfig.Config
        for key, itemConfig: ComputerConfig.ComputerConfig in allItems do
            print(itemConfig.Name)
            createComputerScrollingFrameItem(plrData, key, itemConfig)
        end
    end
end

local function updateItemShopGui(itemType: "Computers" | "Routers")
    local plrData = Remotes.Data.GetAllData:InvokeServer()

    local plrItemLevel
    if itemType == "Computers" then
        plrItemLevel = plrData.GameDev.Computer

    elseif itemType == "Routers" then
        plrItemLevel = plrData.GameDev.Router
    end

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