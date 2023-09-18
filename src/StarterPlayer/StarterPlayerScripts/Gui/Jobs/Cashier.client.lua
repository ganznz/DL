local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))

local Remotes = ReplicatedStorage.Remotes

local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui

local jobInfoContainer = PlayerGui:WaitForChild("Jobs").CashierJob.CashierJob.JobInfo:WaitForChild("Container")
local exitBtn = jobInfoContainer.ExitBtn
local startBtn = jobInfoContainer.StartBtn
local rewardText = jobInfoContainer.RewardsContainer.RewardText
local levelText = jobInfoContainer.LevelBarContainer.LevelText
local levelXp = jobInfoContainer.LevelBarContainer.LevelXp
local levelBar = jobInfoContainer.LevelBarContainer.LevelBar
local levelBarProg = levelBar.LevelBarProg

local visibleGuiPos = jobInfoContainer.Position
local visibleGuiSize = jobInfoContainer.Size

local REWARD_TEXT_TEMPLATE = "+AMT Focus"

GuiServices.DefaultMainGuiStyling(jobInfoContainer)

Remotes.GUI.ChangeGuiStatusRemote.OnClientEvent:Connect(function(guiName, showGui, options)
    if guiName == "cashierJobInfo" then
        if showGui then
            GuiServices.ShowGuiStandard(jobInfoContainer, visibleGuiPos, visibleGuiSize)
        else
            GuiServices.HideGuiStandard(jobInfoContainer, UDim2.new(visibleGuiPos.X.Scale, 0, visibleGuiPos.Y.Scale + 0.3, 0), UDim2.new(visibleGuiSize.X.Scale, 0, visibleGuiSize.Y.Scale - 0.2, 0))
        end
    end
end)

exitBtn.Activated:Connect(function(_inputObj, _clickCount)
    GuiServices.HideGuiStandard(jobInfoContainer, UDim2.new(visibleGuiPos.X.Scale, 0, visibleGuiPos.Y.Scale + 0.3, 0), UDim2.new(visibleGuiSize.X.Scale, 0, visibleGuiSize.Y.Scale - 0.2, 0))
end)