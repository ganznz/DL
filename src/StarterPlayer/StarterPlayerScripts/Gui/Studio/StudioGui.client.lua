local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))
local GlobalVariables = require(ReplicatedStorage.GlobalVariables)

local Remotes = ReplicatedStorage.Remotes

local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui

local LeftSideContainer = PlayerGui:WaitForChild("Left").LeftBtns:WaitForChild("LeftBtnContainer")
local StudioTeleportBtn = LeftSideContainer.StudioTpBtn
local StudioBuildModeBtn = LeftSideContainer.StudioBuildModeBtn

-- switches between the left-side studio btns (visit studio btn & build mode btn)
local function switchStudioBtns(btnToHide, btnToShow)
    btnToHide.Visible = false
    btnToShow.Visible = true
end

StudioTeleportBtn.Activated:Connect(function()
    Remotes.Studio.VisitOwnStudio:FireServer()
    task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
        switchStudioBtns(StudioTeleportBtn, StudioBuildModeBtn)
    end)
end)