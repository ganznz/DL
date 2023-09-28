local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local GuiTransparency = require(ReplicatedStorage.Libs:WaitForChild("GUITransparency"))

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
end

return GuiServices