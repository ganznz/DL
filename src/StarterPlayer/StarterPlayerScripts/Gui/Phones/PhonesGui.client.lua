local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))
local GuiTemplates = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiTemplates"))
local GlobalVariables = require(ReplicatedStorage:WaitForChild("GlobalVariables"))
local GeneralUtils = require(ReplicatedStorage.Utils:WaitForChild("GeneralUtils"))
local GeneralConfig = require(ReplicatedStorage.Configs:WaitForChild("General"))
local PhonesConfig = require(ReplicatedStorage.Configs.Phones:WaitForChild("Phones"))
local StaffMemberConfig = require(ReplicatedStorage.Configs.Staff:WaitForChild("StaffMember"))
local StaffFoodConfig = require(ReplicatedStorage.Configs.Staff:WaitForChild("StaffFood"))
local MaterialsConfig = require(ReplicatedStorage.Configs.Materials:WaitForChild("Materials"))

local Remotes = ReplicatedStorage.Remotes

local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui

-- GUI VARIABLES --
local AllGuiScreenGui = PlayerGui:WaitForChild("AllGui")
local PhonePopupContainer = AllGuiScreenGui.Phones:WaitForChild("PhoneContainerOuter")
local ExitBtn = PhonePopupContainer:WaitForChild("ExitBtn")
local HeaderText = PhonePopupContainer.PhoneContainerInner:WaitForChild("HeaderText")

local BuyBtn = PhonePopupContainer:WaitForChild("BuyBtn")
local BuyBtnCurrencyImage = BuyBtn:WaitForChild("CurrencyImage")
local BuyBtnCurrencyImageDropshadow = BuyBtnCurrencyImage:WaitForChild("CurrencyImageDropshadow")
local BuyBtnCostText = BuyBtn:WaitForChild("CostText")

local RewardContainer = PhonePopupContainer.PhoneContainerInner:WaitForChild("RewardContainer")
local StaffRewardsContainer = RewardContainer:WaitForChild("StaffRewards")
local StaffFoodRewardsContainer = RewardContainer:WaitForChild("StaffFoodRewards")
local MaterialsRewardsContainer = RewardContainer:WaitForChild("MaterialsRewards")
local PercentageTemplateContainer = StaffRewardsContainer.RewardDisplay:WaitForChild("PercentageTemplateContainer")
local UndetailedTemplateContainer = StaffRewardsContainer.RewardDisplay:WaitForChild("UndetailedTemplateContainer")

local PhoneRewardContainer = AllGuiScreenGui.Phones:WaitForChild("PhoneRewardContainer")
local RewardIcon = PhoneRewardContainer:WaitForChild("RewardIcon")
local RewardIconItemImage = RewardIcon:WaitForChild("ItemImage")
local RewardIconItemNameText = RewardIcon:WaitForChild("ItemName")
local RewardIconItemCategoryText = RewardIcon:WaitForChild("ItemCategory")

-- CONSTANT VARIABLES --
local PHONE_GUI_HEADER_TEXT = "NAME Phone!"
local REWARDS_CONTAINER_HEADER_TEXT_VERBOSE = "TITLE - PERCENTAGE"
local BUY_BTN_TEXT = "AMT CURRENCY"
local REWARD_APPEARANCE_LENGTH = 3.5

-- STATE VARIABLES --
local plrData = nil
local phoneName = nil -- currently viewed phones name
local phoneConfig = nil -- currently viewed phones config
local buyBtnConnection = nil

GuiServices.StoreInCache(PhonePopupContainer)
GuiServices.StoreInCache(PhoneRewardContainer)

GuiServices.DefaultMainGuiStyling(PhonePopupContainer)

GuiTemplates.CreateButton(ExitBtn, { Rotates = true })
GuiTemplates.CreateButton(BuyBtn)

GuiTemplates.HeaderText(HeaderText)

local function resetConnection()
    if buyBtnConnection then buyBtnConnection:Disconnect() end
    buyBtnConnection = nil
end

local function activateBuyBtnConnection()
    buyBtnConnection = BuyBtn.Activated:Connect(function()
        Remotes.Phones.PurchasePhone:FireServer(phoneName)
    end)
end

local function applyBuyBtnStyle()
    local phonePrice = phoneConfig.Price
    local plrCurrencyAmt = plrData[phoneConfig.Currency]
    local canAfford = (plrCurrencyAmt - phonePrice) >= 0

    if phoneConfig.Currency == "Coins" then
        BuyBtnCurrencyImage.Image = GeneralUtils.GetDecalUrl(GlobalVariables.Images.Icons.CoinIcon)
        BuyBtnCurrencyImageDropshadow.Image = GeneralUtils.GetDecalUrl(GlobalVariables.Images.Icons.CoinIconDropshadow)
    elseif phoneConfig.Currency == "Gems" then
        BuyBtnCurrencyImage.Image = GeneralUtils.GetDecalUrl(GlobalVariables.Images.Icons.GemIcon)
        BuyBtnCurrencyImageDropshadow.Image = GeneralUtils.GetDecalUrl(GlobalVariables.Images.Icons.GemIconDropshadow)
    end

    BuyBtnCostText.Text = BUY_BTN_TEXT:gsub("AMT", phoneConfig.Price):gsub("CURRENCY", phoneConfig.Currency)

    if canAfford then
        BuyBtn.BackgroundColor3 = GlobalVariables.Gui.ValidGreenColour
        activateBuyBtnConnection()
    else
        BuyBtn.BackgroundColor3 = GlobalVariables.Gui.InvalidGreyColour
    end
end

local function clearRewardContainer()
    for _i, v in StaffRewardsContainer:FindFirstChild("RewardDisplay"):GetChildren() do
        if v.Name == "UIListLayout" or v.Name == "PercentageTemplateContainer" or v.Name == "UndetailedTemplateContainer" then continue end
        v:Destroy()
    end
    for _i, v in StaffFoodRewardsContainer:FindFirstChild("RewardDisplay"):GetChildren() do
        if v.Name == "UIListLayout" or v.Name == "PercentageTemplateContainer" or v.Name == "UndetailedTemplateContainer" then continue end
        v:Destroy()
    end
    for _i, v in MaterialsRewardsContainer:FindFirstChild("RewardDisplay"):GetChildren() do
        if v.Name == "UIListLayout" or v.Name == "PercentageTemplateContainer" or v.Name == "UndetailedTemplateContainer" then continue end
        v:Destroy()
    end
end

local function enableRewardContainerVisibility(categoryUnlockables)
    if categoryUnlockables["Staff"] then StaffRewardsContainer.Visible = true end
    if categoryUnlockables["Staff Food"] then StaffFoodRewardsContainer.Visible = true end
    if categoryUnlockables["Materials"] then MaterialsRewardsContainer.Visible = true end
end

local function populateRewardContainer()
    for unlockableType, unlockableInfo in phoneConfig.Unlockables do
        local header

        -- apply reward container header styling
        if unlockableType == "Staff" then
            header = StaffRewardsContainer:FindFirstChild("HeaderText")
            header.Text = "Staff Members"

        elseif unlockableType == "Staff Food" then
            header = StaffFoodRewardsContainer:FindFirstChild("HeaderText")
            header.Text = REWARDS_CONTAINER_HEADER_TEXT_VERBOSE:gsub("TITLE", "Staff Food")
                                                               :gsub("PERCENTAGE", `<font color="#FFF"><stroke color="#FF9B0B" thickness="3">{PhonesConfig.GetTotalItemChance(phoneName, unlockableType)}%%</stroke></font>`)

        elseif unlockableType == "Materials" then
            header = MaterialsRewardsContainer:FindFirstChild("HeaderText")
            header.Text = REWARDS_CONTAINER_HEADER_TEXT_VERBOSE:gsub("TITLE", "Materials")
                                                               :gsub("PERCENTAGE", `<font color="#FFF"><stroke color="#FF9B0B" thickness="3">{PhonesConfig.GetTotalItemChance(phoneName, unlockableType)}%%</stroke></font>`)
        end

        -- populate reward display
        for unlockableItemName, unlockableItemInfo in unlockableInfo do
            local categoryConfig
            local itemConfig
            local templateContainer
            local template
            local percentageText

            if unlockableType == "Staff" then
                categoryConfig = StaffMemberConfig
                templateContainer = PercentageTemplateContainer:Clone()
                template = templateContainer:FindFirstChild("PercentageTemplate")

                percentageText = template:FindFirstChild("Percentage")
                percentageText.Text = `{unlockableItemInfo.Chance}%`

                templateContainer.Parent = StaffRewardsContainer:FindFirstChild("RewardDisplay")
                
            elseif unlockableType == "Staff Food" then
                categoryConfig = StaffFoodConfig
                templateContainer = UndetailedTemplateContainer:Clone()
                template = templateContainer:FindFirstChild("UndetailedTemplate")

                templateContainer.Parent = StaffFoodRewardsContainer:FindFirstChild("RewardDisplay")
            
            elseif unlockableType == "Materials" then
                categoryConfig = MaterialsConfig
                templateContainer = UndetailedTemplateContainer:Clone()
                template = templateContainer:FindFirstChild("UndetailedTemplate")

                templateContainer.Parent = MaterialsRewardsContainer:FindFirstChild("RewardDisplay")
            end

            itemConfig = categoryConfig.GetConfig(unlockableItemName)

            local icon = template:FindFirstChild("Icon")
            icon.Image = GeneralUtils.GetDecalUrl(itemConfig.IconStroke)

            local templateColour = GeneralConfig.GetRarityColour(itemConfig.Rarity)
            if templateColour then template.BackgroundColor3 = templateColour end

            templateContainer.Name = unlockableItemName
            GuiTemplates.CreateButton(template, { Rotates = true })
            templateContainer.Visible = true
            templateContainer.LayoutOrder = -unlockableItemInfo.Chance -- makes common items appear first

        end
    end

    enableRewardContainerVisibility(phoneConfig.Unlockables)
end

local function populatePhoneGui()
    HeaderText.Text = PHONE_GUI_HEADER_TEXT:gsub("NAME", phoneName)
    applyBuyBtnStyle()
    populateRewardContainer()
end

local function resetPhoneGui()
    -- phone display container
    phoneName = nil
    resetConnection()
    clearRewardContainer()
    StaffRewardsContainer.Visible = false
    StaffFoodRewardsContainer.Visible = false
    MaterialsRewardsContainer.Visible = false

    -- reward container
end

local function showPhoneGui(name: string)
    resetPhoneGui()

    phoneConfig = PhonesConfig.GetConfig(name)
    if not phoneConfig then return end

    -- update state vars
    plrData = Remotes.Data.GetAllData:InvokeServer() -- refresh plr data
    phoneName = name

    populatePhoneGui()
    GuiServices.ShowGuiStandard(PhonePopupContainer, GlobalVariables.Gui.GuiBackdropColourDefault)
end

local function showReward(reward: string)
    local cachedData = GuiServices.GetCachedData(PhoneRewardContainer)
    PhoneRewardContainer.Position = cachedData.Position

    local rewardCategory = reward[1]
    local rewardName = reward[2]

    RewardIconItemNameText.Text = rewardName
    RewardIconItemCategoryText.Text = rewardCategory

    local config
    local itemConfig
    if rewardCategory == "Staff" then
        config = StaffMemberConfig
        
    elseif rewardCategory == "Staff Food" then
        config = StaffFoodConfig
    
    elseif rewardCategory == "Materials" then
        config = MaterialsConfig
    end

    itemConfig = config.GetConfig(rewardName)
    local rarityColour = GeneralConfig.GetRarityColour(itemConfig.Rarity)

    RewardIconItemImage.Image = GeneralUtils.GetDecalUrl(itemConfig.IconStroke)
    RewardIcon.BackgroundColor3 = rarityColour
    RewardIconItemNameText.TextColor3 = rarityColour

    PhoneRewardContainer.Visible = true
end

local function hideReward()
    local hideTween = TweenService:Create(PhoneRewardContainer, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Position = UDim2.fromScale(PhoneRewardContainer.Position.X.Scale, 2.5)
    })
    hideTween:Play()
    hideTween.Completed:Connect(function()
        PhoneRewardContainer.Visible = false

        -- reset properties
        RewardIconItemNameText.Text = ""
        RewardIconItemCategoryText.Text = ""
        RewardIconItemImage.Image = ""
    end)
end

-- ACTIVATE EVENTS --
ExitBtn.Activated:Connect(function() GuiServices.HideGuiStandard(PhonePopupContainer) end)

-- REMOTES --
Remotes.GUI.Phones.PhonePopup.Event:Connect(showPhoneGui)

Remotes.Phones.PurchasePhone.OnClientEvent:Connect(function(_phoneName: string)
    GuiServices.HideGuiStandard(PhonePopupContainer)
end)

Remotes.Phones.OpenPhone.OnClientEvent:Connect(function(reward: string, _rarestItemInPhone: boolean)
    task.wait(GlobalVariables.Gui.FlashShowTime) -- wait until flash is opaque
    showReward(reward)
    task.delay(REWARD_APPEARANCE_LENGTH, function() hideReward() end)
end)