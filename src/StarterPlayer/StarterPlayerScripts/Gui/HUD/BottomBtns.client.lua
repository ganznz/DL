local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))

local Remotes = ReplicatedStorage.Remotes

local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui

-- GUI VARIABLES
local AllGuiScreenGui = PlayerGui:WaitForChild("AllGui")
local BottomBtnsContainer = AllGuiScreenGui.Hud.Bottom:WaitForChild("BottomBtns")
local InventoryBtn = BottomBtnsContainer:WaitForChild("InventoryBtn")
local ShopBtn = BottomBtnsContainer:WaitForChild("ShopBtn")
local AchievementsBtn = BottomBtnsContainer:WaitForChild("AchievementsBtn")
local TradingBtn = BottomBtnsContainer:WaitForChild("TradingBtn")
local SettingsBtn = BottomBtnsContainer:WaitForChild("SettingsBtn")

-- these are the btns that can be shown and hidden
local hideableBtns = {ShopBtn, AchievementsBtn, TradingBtn, SettingsBtn}

-- STATE VARIABLES
local currentFrame = nil -- used to track which UI window is open ("inventory" | "shop" | "achievements" | "trading" | "settings" | nil)

-- OTHER VARIABLES
local btnTweenInfo = TweenInfo.new(0.15)

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
        currentFrame = nil
        Remotes.GUI.ChangeGuiStatusBindable:Fire("inventory", false, nil)

    -- if isExpanded but current open UI is NOT inventory, keep expanded and switch to inventory GUI
    elseif currentFrame then
        currentFrame = "inventory"

    -- expand btns and open inventory GUI
    else
        expandBtnsContainer()
        currentFrame = "inventory"
        Remotes.GUI.ChangeGuiStatusBindable:Fire("inventory", true, nil)
    end
end)