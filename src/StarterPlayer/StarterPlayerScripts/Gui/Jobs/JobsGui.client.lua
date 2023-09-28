local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))
local TimeUtils = require(ReplicatedStorage.Utils.Time:WaitForChild("Time"))

local Remotes = ReplicatedStorage.Remotes

local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui

local jobTimeRemainingContainer = PlayerGui:WaitForChild("Jobs").JobTimeRemaining:WaitForChild("JobTimeRemaining")
local jobTimeRemainingText = jobTimeRemainingContainer.TimeRemaining

local visibleGuiPos = jobTimeRemainingContainer.Position
local visibleGuiSize = jobTimeRemainingContainer.Size

local TIME_TEXT_TEMPLATE_1 = "MINm SECs"
local TIME_TEXT_TEMPLATE_2 = "SECs"

GuiServices.DefaultMainGuiStyling(jobTimeRemainingContainer, -0.1)

Remotes.GUI.Jobs.ChangeJobTimerVisibility.OnClientEvent:Connect(function(showGui)
    if showGui then
        GuiServices.ShowGuiStandard(jobTimeRemainingContainer, UDim2.new(visibleGuiPos.X.Scale, 0, visibleGuiPos.Y.Scale + 0.1, 0), visibleGuiSize, false)
    else
        GuiServices.HideGuiStandard(jobTimeRemainingContainer, visibleGuiPos, visibleGuiSize, false)
    end
end)

Remotes.GUI.Jobs.UpdateJobTimer.OnClientEvent:Connect(function(seconds: number)
    local parsedTime = TimeUtils.ParseTime(seconds)
    if parsedTime.Minutes == 0 then
        jobTimeRemainingText.Text = TIME_TEXT_TEMPLATE_2:gsub("SEC", parsedTime.Seconds)
    else
        jobTimeRemainingText.Text = TIME_TEXT_TEMPLATE_1:gsub("MIN", parsedTime.Minutes):gsub("SEC", parsedTime.Seconds)
    end
end)