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
local LeftSideContainer = AllGuiScreenGui.Hud.Left:WaitForChild("LeftBtnContainer")

-- functionality for these btns in StudioGui.client.lua
local StudioTeleportBtnContainer = LeftSideContainer.StudioTpBtnContainer
local StudioTeleportBtn = StudioTeleportBtnContainer.StudioTpBtn
local StudioBuildModeBtnContainer = LeftSideContainer.StudioBuildModeBtnContainer
local StudioBuildModeBtn = StudioBuildModeBtnContainer.StudioBuildModeBtn

local ShopBtnContainer = LeftSideContainer.ShopBtnContainer
local ShopBtn = ShopBtnContainer.ShopBtn

GuiTemplates.CreateButton(StudioTeleportBtn, { Rotates = true })
GuiTemplates.CreateButton(StudioBuildModeBtn, { Rotates = true })
GuiTemplates.CreateButton(ShopBtn, { Rotates = true })
