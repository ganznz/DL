local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))
local GuiTemplates = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiTemplates"))

local Remotes = ReplicatedStorage.Remotes

local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui

-- GUI VARIABLES
local AllGuiScreenGui = PlayerGui:WaitForChild("AllGui")
local BottomBtnsContainer = AllGuiScreenGui.Hud.Bottom:WaitForChild("BottomBtns")
local InventoryBtnContainer = BottomBtnsContainer:WaitForChild("InventoryBtnContainer")
local ShopBtnContainer = BottomBtnsContainer:WaitForChild("ShopBtnContainer")
local AchievementsBtnContainer = BottomBtnsContainer:WaitForChild("AchievementsBtnContainer")
local TradingBtnContainer = BottomBtnsContainer:WaitForChild("TradingBtnContainer")
local SettingsBtnContainer = BottomBtnsContainer:WaitForChild("SettingsBtnContainer")
local InventoryBtn = InventoryBtnContainer:WaitForChild("InventoryBtn")
local ShopBtn = ShopBtnContainer:WaitForChild("ShopBtn")
local AchievementsBtn = AchievementsBtnContainer:WaitForChild("AchievementsBtn")
local TradingBtn = TradingBtnContainer:WaitForChild("TradingBtn")
local SettingsBtn = SettingsBtnContainer:WaitForChild("SettingsBtn")

local InventoryFrame = AllGuiScreenGui.Inventory:WaitForChild("InventoryContainerOuter")

-- these are the btns that can be shown and hidden
local hideableBtns = {ShopBtnContainer, AchievementsBtnContainer, TradingBtnContainer, SettingsBtnContainer}

-- STATIC VARIABLES
-- all frames that are opened as a result of activating bottom HUD btns
local HUD_FRAMES = {InventoryFrame}

-- STATE VARIABLES
local currentFrame = nil -- used to track which UI window is open ("inventory" | "shop" | "achievements" | "trading" | "settings" | nil)

-- OTHER VARIABLES
local btnTweenInfo = TweenInfo.new(0.15)

GuiServices.StoreInCache(BottomBtnsContainer)

GuiTemplates.CreateButton(InventoryBtn, { Rotates = true })
GuiTemplates.CreateButton(ShopBtn, { Rotates = true })
GuiTemplates.CreateButton(AchievementsBtn, { Rotates = true })
GuiTemplates.CreateButton(TradingBtn, { Rotates = true })
GuiTemplates.CreateButton(SettingsBtn, { Rotates = true })

local function expandBtnsContainer()
    BottomBtnsContainer:SetAttribute("Expanded", true)

    for _i, btn in hideableBtns do
        btn.Visible = true
        local tween = TweenService:Create(btn, btnTweenInfo, { Size = UDim2.fromScale(1, 1) })
        tween:Play()
    end
end

local function minimiseBtnsContainer()
    BottomBtnsContainer:SetAttribute("Expanded", false)
    currentFrame = nil

    for _i, btn in hideableBtns do
        local tween = TweenService:Create(btn, btnTweenInfo, { Size = UDim2.fromScale(0, 0) })
        tween:Play()

        tween.Completed:Connect(function() btn.Visible = false end)
    end
end
InventoryBtn.Activated:Connect(function()
    local isExpanded = BottomBtnsContainer:GetAttribute("Expanded")

    -- if isExpanded and current open UI window is inventory, minimise btns and close GUI
    if isExpanded and currentFrame == "inventory" then
        minimiseBtnsContainer()
        GuiServices.HideGuiStandard(InventoryFrame)

    -- if isExpanded but current open UI is NOT inventory, keep expanded and switch to inventory GUI
    elseif currentFrame then
        currentFrame = "inventory"

    -- expand btns and open inventory GUI
    else
        expandBtnsContainer()
        currentFrame = "inventory"
        Remotes.GUI.ChangeGuiStatusBindable:Fire(currentFrame, true, nil)
    end
end)

Remotes.GUI.ToggleBottomHUD.Event:Connect(function(guiDisplayed: string | nil)
    -- if (no gui being displayed or gui being displayed isn't a bottom HUD frame)
    if (not guiDisplayed or not table.find(HUD_FRAMES, guiDisplayed)) then
        minimiseBtnsContainer()
    end
end)