local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local GuiTransparency = require(ReplicatedStorage.Libs:WaitForChild("GUITransparency"))
local GlobalVariables = require(ReplicatedStorage.GlobalVariables)

local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui

local AllGuiScreenGui = PlayerGui:WaitForChild("AllGui")
local GuiBackdropFrame = AllGuiScreenGui.Misc:WaitForChild("GuiBackdrop")
local NotificationPanelFrame = AllGuiScreenGui.Misc.Notification:WaitForChild("NotificationPanel")

local GuiBlur = Lighting:WaitForChild("GuiBlur")

local LEVEL_XP_TEXT_TEMPLATE = "CURRENT / MAX XP"
local OFFSET_PER_NOTI = 0.27
local NOTI_VISIBLE_X_POS = 0.5 -- scale value
local NOTI_HIDDEN_X_POS = 2 -- scale value

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

local function updateVisibleNotifications(notiToIgnore, action: "moveDown" | "moveUp")
    local tweenInfo = TweenInfo.new(0.2)

    for _i, noti in NotificationPanelFrame:GetChildren() do
        if noti.Name == "Template" or noti.Name == "UIAspectRatioConstraint" then continue end
        if noti == notiToIgnore then continue end

        -- move notification
        local tween
        local currentYpos = noti.Position.Y.Scale
        if action == "moveDown" then
            tween = TweenService:Create(noti, tweenInfo, { Position = UDim2.fromScale(NOTI_VISIBLE_X_POS, currentYpos + OFFSET_PER_NOTI)  })
            
        elseif action == "moveUp" then
            tween = TweenService:Create(noti, tweenInfo, { Position = UDim2.fromScale(NOTI_VISIBLE_X_POS, currentYpos - OFFSET_PER_NOTI)  })
        end
        tween:Play()
    end
end

local function setNotificiationDetails(noti, msg: string, type: "standard" | "good" | "warning")
    local msgText = noti:FindFirstChild("NotificationText")
    local indicatorIcon = noti:FindFirstChild("Indicator")
    local progBar = noti:FindFirstChild("ProgressBar")

    msgText.Text = msg

    if type == "standard" then
        indicatorIcon.TextColor3 = GlobalVariables.Gui.NotificationStandard
        progBar.BackgroundColor3 = GlobalVariables.Gui.NotificationStandard
    elseif type == "good" then
        indicatorIcon.TextColor3 = GlobalVariables.Gui.NotificationGood
        progBar.BackgroundColor3 = GlobalVariables.Gui.NotificationGood
    elseif type == "warning" then
        indicatorIcon.TextColor3 = GlobalVariables.Gui.NotificationWarning
        progBar.BackgroundColor3 = GlobalVariables.Gui.NotificationWarning
    end
end

function GuiServices.CreateNotification(msg: string, type: "standard" | "good" | "warning")
    local template = NotificationPanelFrame:FindFirstChild("Template"):Clone()
    template.Name = msg
    template.Parent = NotificationPanelFrame
    local progBar = template:FindFirstChild("ProgressBar")

    template.Visible = true
    template.Position = UDim2.fromScale(NOTI_HIDDEN_X_POS, 0)
    progBar.Size = UDim2.fromScale(0, 0.1)

    setNotificiationDetails(template, msg, type)
    updateVisibleNotifications(template, "moveDown")

    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Elastic)
    local tweenShow = TweenService:Create(template, tweenInfo, { Position = UDim2.fromScale(NOTI_VISIBLE_X_POS, 0) })
    local progBarTweenInfo = TweenInfo.new(5, Enum.EasingStyle.Linear)
    local progBarTween = TweenService:Create(progBar, progBarTweenInfo, { Size = UDim2.fromScale(1, 0.1) })
    
    tweenShow:Play()

    -- start prog bar tween
    tweenShow.Completed:Connect(function(_playbackState) progBarTween:Play() end)

    -- hide noti
    progBarTween.Completed:Connect(function(_playbackState)
        local currentYpos = template.Position.Y.Scale
        local tweenHide = TweenService:Create(template, tweenInfo, { Position = UDim2.fromScale(NOTI_HIDDEN_X_POS, currentYpos) })
        tweenHide:Play()

        -- destroy noti
        tweenHide.Completed:Connect(function(_playbackState) template:destroy() end)
    end)

end

function GuiServices.GenerateViewportFrame(vpf: ViewportFrame, vpc: Camera, model, posOffset: Vector3)
    vpf.CurrentCamera = vpc
    model.Parent = vpf
    vpc.CFrame = CFrame.new(model.PrimaryPart.Position + posOffset, model.PrimaryPart.Position)
end

return GuiServices