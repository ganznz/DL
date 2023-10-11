local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))
local TimeUtils = require(ReplicatedStorage.Utils.Time:WaitForChild("Time"))
local GlobalVariables = require(ReplicatedStorage:WaitForChild("GlobalVariables"))
local JobConfig = require(ReplicatedStorage.Configs.Jobs:WaitForChild("Job"))

local Remotes = ReplicatedStorage.Remotes

local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui

-- job time remaining gui
local jobTimeRemainingContainer = PlayerGui:WaitForChild("Jobs").AllJobs:WaitForChild("JobTimeRemaining")
local jobTimeRemainingText = jobTimeRemainingContainer.TimeRemaining

local jobTimeRemainingContainerVisibleGuiPos = jobTimeRemainingContainer.Position
local jobTimeRemainingContainerVisibleGuiSize = jobTimeRemainingContainer.Size
local TIME_TEXT_TEMPLATE_1 = "MINm SECs"
local TIME_TEXT_TEMPLATE_2 = "SECs"


-- shift results gui
local jobShiftResultsContainer = PlayerGui:WaitForChild("Jobs").AllJobs:WaitForChild("JobShiftResults")
local shiftResultsHeaderText = jobShiftResultsContainer.HeaderText
local shiftResultsJobIdentifierText = jobShiftResultsContainer.JobLevelHeaderText
local shiftResultsEnterBtn = jobShiftResultsContainer.EnterBtn
local shiftResultsNewUpgradesText = jobShiftResultsContainer.NewUpgradesText
local shiftResultsSkillPtsRewardText = jobShiftResultsContainer.SkillPointsReward

local shiftResultsSkillLvlBarContainer = jobShiftResultsContainer.SkillLevelBarContainer
local shiftResultsSkillLvlText = shiftResultsSkillLvlBarContainer.LevelText
local shiftResultsSkillLevelXpText = shiftResultsSkillLvlBarContainer.LevelXp
local shiftResultsSkillLvlBar = shiftResultsSkillLvlBarContainer.LevelBar
local shiftResultsSkillLvlBarProg = shiftResultsSkillLvlBar.LevelBarProg

local shiftResultsPlrLvlBarContainer = jobShiftResultsContainer.PlrLevelBarContainer
local shiftResultsPlrLvlText = shiftResultsPlrLvlBarContainer.LevelText
local shiftResultsPlrLevelXpText = shiftResultsPlrLvlBarContainer.LevelXp
local shiftResultsPlrLvlBar = shiftResultsPlrLvlBarContainer.LevelBar
local shiftResultsPlrLvlBarProg = shiftResultsPlrLvlBar.LevelBarProg

local jobShiftResultsContainerVisibleGuiPos = jobShiftResultsContainer.Position
local jobShiftResultsContainerVisibleGuiSize = jobShiftResultsContainer.Size
local JOB_IDENTIFIER_TEXT_TEMPLATE = "JOB_TYPE job level"
local SKILL_PTS_REWARD_TEXT_TEMPLATE = "+AMT SKILL points"
local LEVEL_XP_TEXT_TEMPLATE = "CURRENT / MAX XP"
local DEFAULT_HEADER_TEXT = "Shift complete!"
local FORCE_ENDED_HEADER_TEXT = "Shift ended early"
local CASHIER_SKILL_BAR_COLOUR = Color3.fromRGB(0, 126, 184)
local CASHIER_SKILL_BAR_PROG_COLOUR = Color3.fromRGB(0, 174, 255)

GuiServices.DefaultMainGuiStyling(jobTimeRemainingContainer, -0.1)
GuiServices.DefaultMainGuiStyling(jobShiftResultsContainer, GlobalVariables.Gui.MainGuiInvisiblePosOffset)

local function updateShiftResultsGui(options)
    if options.forceEndedShift then shiftResultsHeaderText.Text = FORCE_ENDED_HEADER_TEXT else shiftResultsHeaderText.Text = DEFAULT_HEADER_TEXT end

    shiftResultsSkillLvlText.Text = options.preShiftSkillLvl
    shiftResultsSkillLevelXpText.Text = LEVEL_XP_TEXT_TEMPLATE:gsub("CURRENT", options.preShiftSkillXp):gsub("MAX", options.preShiftSkillLvlUpXpRequirement)
    shiftResultsSkillLvlBarProg.Size = UDim2.fromScale(options.preShiftSkillXp / options.preShiftSkillLvlUpXpRequirement, 1)
    shiftResultsPlrLvlText.Text = options.preShiftPlrLvl
    shiftResultsPlrLevelXpText.Text = LEVEL_XP_TEXT_TEMPLATE:gsub("CURRENT", options.preShiftPlrXp):gsub("MAX", options.preShiftPlrLvlUpXpRequirement)
    shiftResultsPlrLvlBarProg.Size = UDim2.fromScale(options.preShiftPlrXp / options.preShiftPlrLvlUpXpRequirement, 1)
    shiftResultsSkillPtsRewardText.Text = SKILL_PTS_REWARD_TEXT_TEMPLATE:gsub("AMT", options.skillPointsReward):gsub("SKILL", JobConfig.GetSkillType(options.jobInstance))
    
    -- for cashier job
    if options.jobType == "cashierJob" then
        shiftResultsJobIdentifierText.Text = JOB_IDENTIFIER_TEXT_TEMPLATE:gsub("JOB_TYPE", "Cashier")
        shiftResultsJobIdentifierText.TextColor3 = CASHIER_SKILL_BAR_PROG_COLOUR
        shiftResultsSkillLevelXpText.TextStrokeColor3 = CASHIER_SKILL_BAR_PROG_COLOUR
        shiftResultsSkillLvlBar.BackgroundColor3 = CASHIER_SKILL_BAR_COLOUR
        shiftResultsSkillLvlBarProg.BackgroundColor3 = CASHIER_SKILL_BAR_PROG_COLOUR
    end

    -- do for other jobs later
end

shiftResultsEnterBtn.Activated:Connect(function(_inputObj, _clickCount)
    GuiServices.HideGuiStandard(jobShiftResultsContainer, UDim2.new(jobShiftResultsContainerVisibleGuiPos.X.Scale, 0, jobShiftResultsContainerVisibleGuiPos.Y.Scale + GlobalVariables.Gui.MainGuiInvisiblePosOffset, 0), UDim2.new(jobShiftResultsContainerVisibleGuiSize.X.Scale, 0, jobShiftResultsContainerVisibleGuiSize.Y.Scale - 0.2, 0))
end)

Remotes.GUI.Jobs.ChangeJobTimerVisibility.OnClientEvent:Connect(function(showGui)
    if showGui then
        GuiServices.ShowGuiStandard(jobTimeRemainingContainer, UDim2.new(jobTimeRemainingContainerVisibleGuiPos.X.Scale, 0, jobTimeRemainingContainerVisibleGuiPos.Y.Scale + 0.1, 0), jobTimeRemainingContainerVisibleGuiSize)
    else
        GuiServices.HideGuiStandard(jobTimeRemainingContainer, jobTimeRemainingContainerVisibleGuiPos, jobTimeRemainingContainerVisibleGuiSize)
    end
end)

Remotes.GUI.ChangeGuiStatusRemote.OnClientEvent:Connect(function(guiName, showGui, options)
    if guiName == "jobShiftDetails" then
        if showGui then
            updateShiftResultsGui(options)
            GuiServices.ShowGuiStandard(jobShiftResultsContainer, jobShiftResultsContainerVisibleGuiPos, jobShiftResultsContainerVisibleGuiSize)
            GuiServices.AdjustTextTransparency(shiftResultsSkillLevelXpText, 1, false)
        end
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

Remotes.Jobs.AdjustJobXp.OnClientEvent:Connect(function(_jobType, jobInstance, preAdjustmentLvl, postAdjustmentLvl, postAdjustmentXp)
    task.delay(1, function()
        GuiServices.TweenProgBar(shiftResultsSkillLvlBarProg, shiftResultsSkillLvlText, shiftResultsSkillLevelXpText, preAdjustmentLvl, postAdjustmentLvl, postAdjustmentXp, JobConfig.CalcLevelUpXpRequirement(jobInstance))
    end)
end)