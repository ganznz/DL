local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))
local TimeUtils = require(ReplicatedStorage.Utils.Time:WaitForChild("Time"))
local GlobalVariables = require(ReplicatedStorage:WaitForChild("GlobalVariables"))

local Remotes = ReplicatedStorage.Remotes

local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui

local icecreamStoreFolder = Workspace:WaitForChild("Map").Buildings.IceCreamStore
local interiorTeleportToPart = icecreamStoreFolder:WaitForChild("IceCreamStoreInterior"):WaitForChild("TeleportToPart")

local jobInfoContainer = PlayerGui:WaitForChild("Jobs").CashierJob:WaitForChild("JobInfoContainer")
local exitBtn = jobInfoContainer.ExitBtn
local startBtn = jobInfoContainer.StartBtn
local rewardText = jobInfoContainer.RewardsContainer.RewardText
local levelText = jobInfoContainer.LevelBarContainer.LevelText
local levelXpText = jobInfoContainer.LevelBarContainer.LevelXp
local levelBar = jobInfoContainer.LevelBarContainer.LevelBar
local levelBarProg = levelBar.LevelBarProg

local visibleGuiPos = jobInfoContainer.Position
local visibleGuiSize = jobInfoContainer.Size

local REWARD_TEXT_TEMPLATE = "+AMT Focus"
local LEVEL_XP_TEXT_TEMPLATE = "CURRENT / MAX XP"
local COOLDOWN_TEXT_TEMPLATE_1 = "Wait MINm SECs"
local COOLDOWN_TEXT_TEMPLATE_2 = "Wait SECs"
local BTN_ENABLED_COLOUR = Color3.fromRGB(93, 217, 91)
local BTN_DISABLED_COLOUR = Color3.fromRGB(210, 210, 210)
local BTN_TEXT_STROKE_ENABLED_COLOUR = Color3.fromRGB(67, 153, 66)
local BTN_TEXT_STROKE_DISABLED_COLOUR = Color3.fromRGB(133, 133, 133)

local cooldownDifference = nil

GuiServices.DefaultMainGuiStyling(jobInfoContainer, GlobalVariables.Gui.MainGuiInvisiblePosOffset)

local function updateJobInfoGui(info)
    rewardText.Text = REWARD_TEXT_TEMPLATE:gsub("AMT", info.skillPointsReward)
    levelText.Text = info.jobLevel
    levelXpText.Text = LEVEL_XP_TEXT_TEMPLATE:gsub("CURRENT", info.xp):gsub("MAX", info.levelUpXpRequirement)
    levelBarProg.Size = UDim2.fromScale(info.xp / info.levelUpXpRequirement, 1)
end

local function updateJobBtnTimer(cooldown)
    cooldownDifference = cooldown - os.time()
    -- if negative, enable
    -- if positive, disable
    if cooldownDifference <= 0 then
        startBtn.BackgroundColor3 = BTN_ENABLED_COLOUR
        startBtn.TextStrokeColor3 = BTN_TEXT_STROKE_ENABLED_COLOUR
        startBtn.Text = "Start shift!"
    else
        startBtn.BackgroundColor3 = BTN_DISABLED_COLOUR
        startBtn.TextStrokeColor3 = BTN_TEXT_STROKE_DISABLED_COLOUR
        local parsedTime = TimeUtils.ParseTime(cooldownDifference)
        if parsedTime.Minutes == 0 then
            startBtn.Text = COOLDOWN_TEXT_TEMPLATE_2:gsub("SEC", parsedTime.Seconds)
        else
            startBtn.Text = COOLDOWN_TEXT_TEMPLATE_1:gsub("MIN", parsedTime.Minutes):gsub("SEC", parsedTime.Seconds)
        end
    end
end

exitBtn.Activated:Connect(function(_inputObj, _clickCount)
    GuiServices.HideGuiStandard(jobInfoContainer, UDim2.new(visibleGuiPos.X.Scale, 0, visibleGuiPos.Y.Scale + 0.3, 0), UDim2.new(visibleGuiSize.X.Scale, 0, visibleGuiSize.Y.Scale - 0.2, 0), true)
end)

startBtn.Activated:Connect(function(_inputObject, _clickCount)
    if cooldownDifference <= 0 then
        Remotes.GUI.ChangeGuiStatusBindable:Fire("loadingBgSplash", true, { TeleportPart = interiorTeleportToPart })
        Remotes.Jobs.StartShift:FireServer("IceCreamStoreCashier")
        GuiServices.HideGuiStandard(jobInfoContainer, UDim2.new(visibleGuiPos.X.Scale, 0, visibleGuiPos.Y.Scale + 0.3, 0), UDim2.new(visibleGuiSize.X.Scale, 0, visibleGuiSize.Y.Scale - 0.2, 0), true)
    end
end)

Remotes.GUI.ChangeGuiStatusRemote.OnClientEvent:Connect(function(guiName, showGui, options)
    if guiName == "cashierJobInfo" then
        if showGui then
            updateJobInfoGui(options)
            GuiServices.ShowGuiStandard(jobInfoContainer, visibleGuiPos, visibleGuiSize, true)
        else
            GuiServices.HideGuiStandard(jobInfoContainer, UDim2.new(visibleGuiPos.X.Scale, 0, visibleGuiPos.Y.Scale + 0.3, 0), UDim2.new(visibleGuiSize.X.Scale, 0, visibleGuiSize.Y.Scale - 0.2, 0), true)
        end
    end
end)

Remotes.GUI.Jobs.UpdateJobAvailableTimer.OnClientEvent:Connect(function(jobType, timeUntilEnabled)
    if jobType == "cashierJob" then
        updateJobBtnTimer(timeUntilEnabled)
    end
end)