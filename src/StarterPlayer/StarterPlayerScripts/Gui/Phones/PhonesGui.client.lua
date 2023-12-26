local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))
local GuiTemplates = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiTemplates"))
local GlobalVariables = require(ReplicatedStorage:WaitForChild("GlobalVariables"))
local GeneralUtils = require(ReplicatedStorage.Utils:WaitForChild("GeneralUtils"))
local PhonesConfig = require(ReplicatedStorage.Configs.Phones:WaitForChild("Phones"))
local StaffMemberConfig = require(ReplicatedStorage.Configs.Staff:WaitForChild("StaffMember"))

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
local PercentageTemplate = StaffRewardsContainer.RewardDisplay:WaitForChild("PercentageTemplate")
local UndetailedTemplate = StaffRewardsContainer.RewardDisplay:WaitForChild("UndetailedTemplate")

-- CONSTANT VARIABLES --
local PHONE_GUI_HEADER_TEXT = "NAME Phone!"
local REWARDS_CONTAINER_HEADER_TEXT_VERBOSE = "TITLE - PERCENTAGE"
local BUY_BTN_TEXT = "AMT CURRENCY"

-- STATE VARIABLES --
local plrData = nil
local phoneName = nil -- currently viewed phones name
local phoneConfig = nil -- currently viewed phones config
local buyBtnConnection = nil

GuiServices.StoreInCache(PhonePopupContainer)

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
    local canAfford = (phonePrice - plrCurrencyAmt) >= 0

    if phoneConfig.Currency == "Coins" then
        BuyBtnCurrencyImage.Image = GeneralUtils.GetDecalUrl(GlobalVariables.Images.Icons.CoinIcon)
        BuyBtnCurrencyImageDropshadow.Image = GeneralUtils.GetDecalUrl(GlobalVariables.Images.Icons.CoinIconDropshadow)
    elseif phoneConfig.Currency == "Gems" then
        BuyBtnCurrencyImage.Image = GeneralUtils.GetDecalUrl(GlobalVariables.Images.Icons.GemIcon)
        BuyBtnCurrencyImageDropshadow.Image = GeneralUtils.GetDecalUrl(GlobalVariables.Images.Icons.GemIconDropshadow)
    end

    if canAfford then
        BuyBtn.BackgroundColor3 = GlobalVariables.Gui.ValidGreenColour
        BuyBtnCostText.Text = BUY_BTN_TEXT:gsub("AMT", phoneConfig.Price):gsub("CURRENCY", phoneConfig.Currency)

        activateBuyBtnConnection()
    else
        BuyBtn.BackgroundColor3 = GlobalVariables.Gui.InvalidGreyColour
    end
end

local function populateRewardContainer()
    for unlockableType, unlockableInfo in phoneConfig.Unlockables do
        local header

        -- apply reward container header styling
        if unlockableType == "Staff" then
            header = StaffRewardsContainer:FindFirstChild("HeaderText")
            header.Text = "Staff Members"

        elseif unlockableType == "Consumables" then
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
            local template
            local icon
            local percentageText
            local templateColour

            if unlockableType == "Staff" then
                template = PercentageTemplate:Clone()
                icon = template:FindFirstChild("Icon")

                percentageText = template:FindFirstChild("Percentage")
                percentageText.Text = `{unlockableItemInfo.Chance}%`
                
                templateColour = StaffMemberConfig.GetRarityColour(unlockableItemName)
                if templateColour then template.BackgroundColor3 = templateColour end
                template.Parent = StaffRewardsContainer:FindFirstChild("RewardDisplay")
                
            elseif unlockableType == "Consumables" then
                template = UndetailedTemplate:Clone()
                icon = template:FindFirstChild("Icon")
                template.Parent = StaffFoodRewardsContainer:FindFirstChild("RewardDisplay")
            
            elseif unlockableType == "Materials" then
                template = UndetailedTemplate:Clone()
                icon = template:FindFirstChild("Icon")
                template.Parent = MaterialsRewardsContainer:FindFirstChild("RewardDisplay")
            
            end

            GuiTemplates.CreateButton(template, { Rotates = true })
            template.Visible = true
        end
    end
end

local function populatePhoneGui()
    HeaderText.Text = PHONE_GUI_HEADER_TEXT:gsub("NAME", phoneName)
    applyBuyBtnStyle()
    populateRewardContainer()
end

local function resetPhoneGui()
    phoneName = nil
    resetConnection()
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

Remotes.GUI.Phones.PhonePopup.Event:Connect(showPhoneGui)