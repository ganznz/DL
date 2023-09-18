local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local GuiTransparency = require(ReplicatedStorage.Libs:WaitForChild("GUITransparency"))

local GuiServices = {}

function GuiServices.DefaultMainGuiStyling(guiInstance: Frame)
    guiInstance.Position = UDim2.fromScale(0.5, guiInstance.Position.Y.Scale + 0.3)
    GuiTransparency:SetTransparency(guiInstance, 1, TweenInfo.new(0))
end

function GuiServices.ShowGuiStandard(guiInstance: Frame, goalPos, goalSize)
    guiInstance.Visible = true
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    local mainTween = TweenService:Create(guiInstance, tweenInfo, {
        Position = goalPos,
        Size = goalSize
    })
    mainTween:Play()
    GuiTransparency:SetTransparency(guiInstance, 0, TweenInfo.new(0.2))
end

function GuiServices.HideGuiStandard(guiInstance: Frame, goalPos, goalSize)
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    local mainTween = TweenService:Create(guiInstance, tweenInfo, {
        Position = goalPos,
        Size = goalSize
    })
    mainTween:Play()
    GuiTransparency:SetTransparency(guiInstance, 1, TweenInfo.new(0.2))
    task.delay(0.2, function() guiInstance.Visible = false end)
end

return GuiServices