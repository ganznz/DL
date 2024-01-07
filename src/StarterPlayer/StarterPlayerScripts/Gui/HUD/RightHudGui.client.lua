local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))
local GuiTemplates = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiTemplates"))

local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui

-- GUI VARIABLES
local AllGuiScreenGui: ScreenGui = PlayerGui:WaitForChild("AllGui")
local HudFolder = AllGuiScreenGui.Hud

-- right HUD containers
local RightHudFolder = HudFolder:WaitForChild("Right")
local RightHudBtnContainer = RightHudFolder:WaitForChild("RightBtnContainer")

GuiServices.StoreInCache(RightHudBtnContainer)

-- functionality for this btn in StudioGui.client.lua
local PlrStudiosBtn = RightHudBtnContainer.PlrStudiosBtn

GuiTemplates.CreateButton(PlrStudiosBtn, { Rotates = true })
