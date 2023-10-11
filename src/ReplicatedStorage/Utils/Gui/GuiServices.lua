local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local GuiTransparency = require(ReplicatedStorage.Libs:WaitForChild("GUITransparency"))

local LEVEL_XP_TEXT_TEMPLATE = "CURRENT / MAX XP"

local GuiServices = {}

GuiServices.ValidGreenColour = Color3.fromRGB(93, 217, 91)
GuiServices.InvalidGreyColour = Color3.fromRGB(210, 210, 210)

function GuiServices.DefaultMainGuiStyling(guiInstance: Frame, posOffset: number, ignoreElements: {})
    if not ignoreElements then ignoreElements = {} end

    guiInstance.Position = UDim2.fromScale(0.5, guiInstance.Position.Y.Scale + posOffset)
    guiInstance.Visible = false
    -- GuiServices.AdjustTransparency(guiInstance, 1, TweenInfo.new(0), ignoreElements)
end

-- function GuiServices.ShowGuiStandard(guiInstance: Frame, goalPos, goalSize, opacityTween: boolean, ignoreElements: {})
--     if not ignoreElements then ignoreElements = {} end

--     guiInstance.Visible = true
--     local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
--     local mainTween = TweenService:Create(guiInstance, tweenInfo, {
--         Position = goalPos,
--         Size = goalSize
--     })

--     if opacityTween then
--         GuiServices.AdjustTransparency(guiInstance, 0, TweenInfo.new(0.2), ignoreElements)
--     else
--         GuiServices.AdjustTransparency(guiInstance, 0, TweenInfo.new(0), ignoreElements)
--     end
--     mainTween:Play()

--     return mainTween
-- end

function GuiServices.ShowGuiStandard(guiInstance, goalPos, goalSize, ignoreElements: {})
    if not ignoreElements then ignoreElements = {} end

    guiInstance.Visible = true
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    local mainTween = TweenService:Create(guiInstance, tweenInfo, {
        Position = goalPos,
        Size = goalSize
    })

    mainTween:Play()

    return mainTween
end

-- function GuiServices.HideGuiStandard(guiInstance: Frame, goalPos, goalSize, opacityTween: boolean, ignoreElements: {})
--     if not ignoreElements then ignoreElements = {} end

--     local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
--     local mainTween = TweenService:Create(guiInstance, tweenInfo, {
--         Position = goalPos,
--         Size = goalSize
--     })
--     mainTween:Play()

--     if opacityTween then
--         GuiServices.AdjustTransparency(guiInstance, 1, TweenInfo.new(0.2), ignoreElements)
--     end

--     task.delay(0.5, function()
--         guiInstance.Visible = false
--         if not opacityTween then
--             GuiServices.AdjustTransparency(guiInstance, 1, TweenInfo.new(0), ignoreElements)
--         end
--     end)

--     return mainTween
-- end

function GuiServices.HideGuiStandard(guiInstance, goalPos, goalSize, ignoreElements: {})
    if not ignoreElements then ignoreElements = {} end

    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    local mainTween = TweenService:Create(guiInstance, tweenInfo, {
        Position = goalPos,
        Size = goalSize
    })
    mainTween:Play()
    mainTween.Completed:Connect(function(_playbackState)
        guiInstance.Visible = false
    end)

    return mainTween
end

function GuiServices.AdjustTransparency(guiInstance, transparencyValue, tweenInfo, ignoreElements: {})
    if not ignoreElements then ignoreElements = {} end

    GuiTransparency:SetTransparency(guiInstance, transparencyValue, tweenInfo, ignoreElements)
end

function GuiServices.AdjustTextTransparency(guiInstance, transparencyValue: number, transparencyTween: boolean)
    local tweenInfo
    if transparencyTween then
        tweenInfo = TweenInfo.new(0.3)
    else
        tweenInfo = TweenInfo.new(0)
    end

    local tween = TweenService:Create(guiInstance, tweenInfo, { TextTransparency = transparencyValue })
    tween:Play()
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
        tween.Completed:Connect(function(_playbackState)
            progBarXpText.Text = LEVEL_XP_TEXT_TEMPLATE:gsub("CURRENT", postAdjustmentXp):gsub("MAX", postAdjustmentMaxXp)
            GuiServices.AdjustTextTransparency(progBarXpText, 0, true)
        end)
    end
end

function GuiServices.DisplayClickIcon(adornee)
    local clickIconBillboard = ReplicatedStorage.Assets.Gui:FindFirstChild("ClickIconBillboard"):Clone()
    clickIconBillboard.Parent = adornee

    local tween = TweenService:Create(clickIconBillboard, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, math.huge, true), {
        Size = UDim2.fromScale(1.3, 1.3)
    })
    tween:Play()
end

function GuiServices.GenerateViewportFrame(vpf: ViewportFrame, vpc: Camera, model, posOffset: Vector3)
    vpf.CurrentCamera = vpc
    model.Parent = vpf
    vpc.CFrame = CFrame.new(model.PrimaryPart.Position + posOffset, model.PrimaryPart.Position)
end

return GuiServices