local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local DataTemplate = ReplicatedStorage.PlayerData:WaitForChild("Template")

local Remotes = ReplicatedStorage.Remotes

local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui

-- GUI OBJECTS
local PlrInfoScreenGui = PlayerGui:WaitForChild("PlrInfo")
local PlrInfoContainer = PlrInfoScreenGui.PlrInfoContainer

local CameraViewport = PlrInfoContainer.PlrCameraViewport

local EnergyBar = PlrInfoContainer.PlrEnergyBar
local EnergyBarProg = EnergyBar.PlrEnergyBarProg
local EnergyBarProgText = EnergyBar.PlrEnergyBarProgText

local HungerBar = PlrInfoContainer.PlrHungerBar
local HungerBarProg = HungerBar.PlrHungerBarProg
local HungerBarProgText = HungerBar.PlrHungerBarProgText

local LevelBar = PlrInfoContainer.PlrLevelBar
local LevelBarProg = LevelBar.PlrLevelBarProg
local LevelBarProgText = LevelBar.PlrLevelBarProgText

local PlrLevel = PlrInfoContainer.PlrLevel
local PlrLevelText = PlrLevel.PlrLevelText

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential)
local function tweenBar(barProgInstance, currentValue, maxValue)
    local tween = TweenService:Create(barProgInstance, tweenInfo, { Size = UDim2.fromScale(currentValue / maxValue, 1) })
    tween:Play()
end


local plrData: DataTemplate.PlayerData = Remotes.Data.GetAllData:InvokeServer()

local PROG_TEXT_TEMPLATE = "CURRENT/MAX"


EnergyBarProg.Size = UDim2.fromScale(plrData.Character.Needs.Energy / plrData.Character.Needs.MaxEnergy, 1)
EnergyBarProgText.Text = PROG_TEXT_TEMPLATE:gsub("CURRENT", plrData.Character.Needs.Energy):gsub("MAX", plrData.Character.Needs.MaxEnergy)

HungerBarProg.Size = UDim2.fromScale(plrData.Character.Needs.Hunger / plrData.Character.Needs.MaxHunger, 1)
HungerBarProgText.Text = PROG_TEXT_TEMPLATE:gsub("CURRENT", plrData.Character.Needs.Hunger):gsub("MAX", plrData.Character.Needs.MaxHunger)

LevelBarProgText.Text = PROG_TEXT_TEMPLATE:gsub("CURRENT", plrData.Character.Exp):gsub("MAX", 100)
LevelBarProg.Size = UDim2.fromScale(plrData.Character.Exp / 10, 1)

PlrLevelText.Text = plrData.Character.Level

Remotes.Character.AdjustPlrEnergy.OnClientEvent:Connect(function(newPlrData)
    plrData = newPlrData
    tweenBar(EnergyBarProg, plrData.Character.Needs.Energy, plrData.Character.Needs.MaxEnergy)
    EnergyBarProgText.Text = PROG_TEXT_TEMPLATE:gsub("CURRENT", plrData.Character.Needs.Energy):gsub("MAX", plrData.Character.Needs.MaxEnergy)
end)

Remotes.Character.AdjustPlrHunger.OnClientEvent:Connect(function(newPlrData)
    plrData = newPlrData
    tweenBar(HungerBarProg, plrData.Character.Needs.Hunger, plrData.Character.Needs.MaxHunger)
    HungerBarProgText.Text = PROG_TEXT_TEMPLATE:gsub("CURRENT", plrData.Character.Needs.Hunger):gsub("MAX", plrData.Character.Needs.MaxHunger)
end)