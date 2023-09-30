local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local GuiTransparency = require(ReplicatedStorage.Libs:WaitForChild("GUITransparency"))

local LEVEL_XP_TEXT_TEMPLATE = "CURRENT / MAX XP"

local GuiServices = {}

function GuiServices.DefaultMainGuiStyling(guiInstance: Frame, posOffset: number)
    guiInstance.Position = UDim2.fromScale(0.5, guiInstance.Position.Y.Scale + posOffset)
    guiInstance.Visible = false
    GuiTransparency:SetTransparency(guiInstance, 1, TweenInfo.new(0))
end

function GuiServices.ShowGuiStandard(guiInstance: Frame, goalPos, goalSize, opacityTween: boolean)
    guiInstance.Visible = true
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    local mainTween = TweenService:Create(guiInstance, tweenInfo, {
        Position = goalPos,
        Size = goalSize
    })

    if opacityTween then
        GuiTransparency:SetTransparency(guiInstance, 0, TweenInfo.new(0.2))
    else
        GuiTransparency:SetTransparency(guiInstance, 0, TweenInfo.new(0))
    end
    mainTween:Play()

    return mainTween
end

function GuiServices.HideGuiStandard(guiInstance: Frame, goalPos, goalSize, opacityTween: boolean)
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    local mainTween = TweenService:Create(guiInstance, tweenInfo, {
        Position = goalPos,
        Size = goalSize
    })
    mainTween:Play()

    if opacityTween then
        GuiTransparency:SetTransparency(guiInstance, 1, TweenInfo.new(0.2))
    end

    task.delay(0.5, function()
        guiInstance.Visible = false
        if not opacityTween then
            GuiTransparency:SetTransparency(guiInstance, 1, TweenInfo.new(0))
        end
    end)

    return mainTween
end

function GuiServices.AdjustTransparency(guiInstance, transparencyValue, tweenInfo)
    GuiTransparency:SetTransparency(guiInstance, transparencyValue, tweenInfo)
end

function GuiServices.AdjustTextTransparency(guiInstance, transparencyValue: number, transparencyTween: boolean)
    if transparencyTween then
        local tween = TweenService:Create(guiInstance, TweenInfo.new(0.3), { TextTransparency = transparencyValue })
        tween:Play()
    end
end

function GuiServices.TweenProgBar(progBarInstance, progBarLvlTxt, progBarXpText, preAdjustmentLevel, postAdjustmentLevel, postAdjustmentXp, postAdjustmentMaxXp)
    local TWEEN_TIME = 1 -- seconds

    local tweenInfoSameLvl = TweenInfo.new((postAdjustmentXp/postAdjustmentMaxXp) * TWEEN_TIME, Enum.EasingStyle.Linear)
    local tweenInfoNewLvl = TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Linear)

    progBarLvlTxt.Text = preAdjustmentLevel

    if preAdjustmentLevel ~= postAdjustmentLevel then
        local tween = TweenService:Create(progBarInstance, tweenInfoNewLvl, { Size = UDim2.fromScale(1, 1) })
        tween:Play()
        tween.Completed:Connect(function(_playbackState)
            progBarInstance.Size = UDim2.fromScale(0, 1)
            GuiServices.TweenProgBar(progBarInstance, progBarLvlTxt, progBarXpText, preAdjustmentLevel + 1, postAdjustmentLevel, postAdjustmentXp, postAdjustmentMaxXp)
        end)
    else
        local tween = TweenService:Create(progBarInstance, tweenInfoSameLvl, { Size = UDim2.fromScale(postAdjustmentXp / postAdjustmentMaxXp, 1) })
        tween:Play()

        -- update xp text
        task.delay(0.1, function()
            progBarXpText.Text = LEVEL_XP_TEXT_TEMPLATE:gsub("CURRENT", postAdjustmentXp):gsub("MAX", postAdjustmentMaxXp)
        end)
    end
end

return GuiServices