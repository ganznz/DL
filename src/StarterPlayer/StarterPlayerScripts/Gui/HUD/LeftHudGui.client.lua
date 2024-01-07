local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))
local GuiTemplates = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiTemplates"))

local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui

-- GUI VARIABLES
local AllGuiScreenGui: ScreenGui = PlayerGui:WaitForChild("AllGui")
local HudFolder = AllGuiScreenGui.Hud

-- left HUD containers
local LeftHudFolder = HudFolder:WaitForChild("Left")
local LeftHudBtnContainer = LeftHudFolder:WaitForChild("LeftBtnContainer")
local LeftHudPlrInfoContainer = LeftHudFolder:WaitForChild("PlrInfoContainer")

GuiServices.StoreInCache(LeftHudBtnContainer)
GuiServices.StoreInCache(LeftHudPlrInfoContainer)

-- functionality for these btns in StudioGui.client.lua
local StudioTeleportBtnContainer = LeftHudBtnContainer.StudioTpBtnContainer
local StudioTeleportBtn = StudioTeleportBtnContainer.StudioTpBtn
local StudioBuildModeBtnContainer = LeftHudBtnContainer.StudioBuildModeBtnContainer
local StudioBuildModeBtn = StudioBuildModeBtnContainer.StudioBuildModeBtn

local ShopBtnContainer = LeftHudBtnContainer.ShopBtnContainer
local ShopBtn = ShopBtnContainer.ShopBtn

GuiTemplates.CreateButton(StudioTeleportBtn, { Rotates = true })
GuiTemplates.CreateButton(StudioBuildModeBtn, { Rotates = true })
GuiTemplates.CreateButton(ShopBtn, { Rotates = true })
