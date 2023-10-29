local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local GuiTransparency = require(ReplicatedStorage.Libs:WaitForChild("GUITransparency"))

local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui

local AllGuiScreenGui = PlayerGui:WaitForChild("AllGui")

local GuiBackdropFrame = AllGuiScreenGui.Misc:WaitForChild("GuiBackdrop")

local GuiBlur = Lighting:WaitForChild("GuiBlur")

local LEVEL_XP_TEXT_TEMPLATE = "CURRENT / MAX XP"

local GuiServices = {}

function GuiServices.EnableUnrelatedButtons(guiInstanceToIgnore)
    for _i, instance in PlayerGui:GetDescendants() do
        if (instance:IsA("ImageButton") or instance:IsA("TextButton")) and not instance:IsDescendantOf(guiInstanceToIgnore) then
            instance.Active = true
        end
    end
end

function GuiServices.DisableUnrelatedButtons(guiInstanceToIgnore)
    for _i, instance in PlayerGui:GetDescendants() do
        if (instance:IsA("ImageButton") or instance:IsA("TextButton")) and not instance:IsDescendantOf(guiInstanceToIgnore) then
            instance.Active = false
        end
    end
end

function GuiServices.DefaultMainGuiStyling(guiInstance: Frame, posOffset: number)
    guiInstance.Position = UDim2.fromScale(0.5, guiInstance.Position.Y.Scale + posOffset)
    guiInstance.Visible = false
end

function GuiServices.ShowGuiStandard(guiInstance, goalPos, goalSize, backdropColour: Color3)
    guiInstance.Visible = true
    
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    local mainTween = TweenService:Create(guiInstance, tweenInfo, {
        Position = goalPos,
        Size = goalSize
    })
    
    -- backdrop should be present
    if backdropColour then
        GuiServices.DisableUnrelatedButtons(guiInstance)

        GuiBackdropFrame.BackgroundColor3 = backdropColour
        GuiBackdropFrame.Visible = true
        
        local guiBackdropTween = TweenService:Create(GuiBackdropFrame, tweenInfo, { BackgroundTransparency = 0.6 })
        guiBackdropTween:Play()
    
        local guiBlurTween = TweenService:Create(GuiBlur, tweenInfo, { Size = 20 })
        guiBlurTween:Play()
    end

    mainTween:Play()

    return mainTween
end

function GuiServices.HideGuiStandard(guiInstance, goalPos, goalSize)
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    local mainTween = TweenService:Create(guiInstance, tweenInfo, {
        Position = goalPos,
        Size = goalSize
    })
    mainTween:Play()
    mainTween.Completed:Connect(function(_playbackState)
        guiInstance.Visible = false
    end)

    local guiBackdropTween = TweenService:Create(GuiBackdropFrame, tweenInfo, { BackgroundTransparency = 1 })
    guiBackdropTween:Play()
    guiBackdropTween.Completed:Connect(function(_playbackState)
        GuiBackdropFrame.Visible = false
        GuiServices.EnableUnrelatedButtons(guiInstance)
    end)

    local guiBlurTween = TweenService:Create(GuiBlur, tweenInfo, { Size = 0 })
    guiBlurTween:Play()

    return mainTween
end

function GuiServices.AdjustTransparency(guiInstance, transparencyValue, tweenInfo)
    GuiTransparency:SetTransparency(guiInstance, transparencyValue, tweenInfo)
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