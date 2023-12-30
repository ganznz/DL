local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local GuiTransparency = require(ReplicatedStorage.Libs:WaitForChild("GUITransparency"))
local GlobalVariables = require(ReplicatedStorage.GlobalVariables)
local Stack = require(ReplicatedStorage.Utils.DataStructures:WaitForChild("Stack"))

local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui

local camera = Workspace:FindFirstChild("Camera")

local AllGuiScreenGui: ScreenGui = PlayerGui:WaitForChild("AllGui")
local GuiBackdropFrame: Frame = AllGuiScreenGui.Misc:WaitForChild("GuiBackdrop")
local NotificationPanelFrame = AllGuiScreenGui.Misc.Notification:WaitForChild("NotificationPanel")
local FlashFrame: Frame = AllGuiScreenGui.Misc:WaitForChild("FlashBg")
local BeamImage: ImageLabel = AllGuiScreenGui.Particles:WaitForChild("Beam")
local ConfettiContainer: Frame = AllGuiScreenGui.Misc:WaitForChild("ConfettiContainer")
local ConfettiParticle: Frame = AllGuiScreenGui.Particles:WaitForChild("ConfettiParticle")

local GuiBlur = Lighting:WaitForChild("GuiBlur")

local LEVEL_XP_TEXT_TEMPLATE = "CURRENT / MAX XP"
local OFFSET_PER_NOTI = 0.27
local NOTI_VISIBLE_X_POS = 0.5 -- scale value
local NOTI_HIDDEN_X_POS = 2 -- scale value

-- this cache is used to store position/size information regarding GUI in-game
local GuiCache = {}

-- this stack is used to determine how GUI should be displayed.
-- usecases include: opening GUI when another GUI instance is open, GUI history (notification popup opens and closes previous GUI, when popup is closed the previous GUI opens back up), etc
local GuiStack = Stack.new()

local GuiServices = {}

function GuiServices.StoreInCache(guiInstance)
    GuiCache[guiInstance] = {
        Position = guiInstance.Position,
        Size = guiInstance.Size
    }
end

function GuiServices.GetCachedData(guiInstance)
    local cachedData = GuiCache[guiInstance]
    if not cachedData then return nil end

    return cachedData
end

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

function GuiServices.HideHUD()
end

function GuiServices.ShowHUD()
end

function GuiServices.DefaultMainGuiStyling(guiInstance: Frame, xOffset: number, yOffset: number)
    local xPos = GuiCache[guiInstance].Position.X.Scale + (xOffset and xOffset or 0)
    local yPos = GuiCache[guiInstance].Position.Y.Scale + (yOffset and yOffset or GlobalVariables.Gui.MainGuiInvisibleYOffset)

    guiInstance.Position = UDim2.fromScale(xPos, yPos)
    guiInstance.Visible = false
end

local function showBackdrop(colour: Color3)
    local tweenInfo = TweenInfo.new(GlobalVariables.Gui.MainGuiOpenTime)

    GuiBackdropFrame.BackgroundColor3 = colour
    GuiBackdropFrame.Visible = true
    
    local guiBackdropTween = TweenService:Create(GuiBackdropFrame, tweenInfo, { BackgroundTransparency = 0.6 })
    guiBackdropTween:Play()

    local guiBlurTween = TweenService:Create(GuiBlur, tweenInfo, { Size = 20 })
    guiBlurTween:Play()
end

local function hideBackdrop()
    local tweenInfo = TweenInfo.new(GlobalVariables.Gui.MainGuiCloseTime)

    local guiBackdropTween = TweenService:Create(GuiBackdropFrame, tweenInfo, { BackgroundTransparency = 1 })
    guiBackdropTween:Play()

    guiBackdropTween.Completed:Connect(function(_playbackState) GuiBackdropFrame.Visible = false end)
end

-- switchingGui parameter only present if opening gui while another gui instance is already open
function GuiServices.HideGuiStandard(guiInstance, switchingUI: true | nil)
    GuiStack:Pop()

    local tweenInfo = TweenInfo.new(GlobalVariables.Gui.MainGuiCloseTime, Enum.EasingStyle.Linear)

    local guiPosition = GuiCache[guiInstance].Position
    local guiSize = GuiCache[guiInstance].Size

    local guiTween = TweenService:Create(guiInstance, tweenInfo, {
        Position = UDim2.fromScale(guiPosition.X.Scale + GlobalVariables.Gui.MainGuiInvisibleXOffset, guiPosition.Y.Scale + GlobalVariables.Gui.MainGuiInvisibleYOffset),
        Size = UDim2.fromScale(guiSize.X.Scale + GlobalVariables.Gui.MainGuiInvisibleXSize, guiSize.Y.Scale - GlobalVariables.Gui.MainGuiInvisibleYSize)
    })
    guiTween:Play()
    guiTween.Completed:Connect(function(_playbackState)
        guiInstance.Visible = false
    end)

    -- only hide backdrop & revert camera settings if closing gui, not if switching between gui instances
    if switchingUI then return guiTween end

    local cameraTween = TweenService:Create(camera, TweenInfo.new(GlobalVariables.Gui.GuiInvisibleCameraTime), { FieldOfView = GlobalVariables.Gui.GuiInvisibleCameraFOV })
    cameraTween:Play()

    hideBackdrop()

    local guiBlurTween = TweenService:Create(GuiBlur, tweenInfo, { Size = 0 })
    guiBlurTween:Play()

    return guiTween
end

function GuiServices.ShowGuiStandard(guiInstance, backdropColour: Color3)
    -- check if other GUI is open already
    local previousInstance = GuiStack:Peek()

    if previousInstance and previousInstance ~= "" then
        if previousInstance == guiInstance then
            GuiServices.HideGuiStandard(previousInstance)
            return
        else
            GuiServices.HideGuiStandard(previousInstance, true)
        end
    end

    -- push new visible GUI onto stack
    GuiStack:Push("")
    GuiStack:Push(guiInstance)

    guiInstance.Visible = true

    local tweenInfo = TweenInfo.new(GlobalVariables.Gui.MainGuiOpenTime, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

    local guiPosition = GuiCache[guiInstance].Position
    local guiSize = GuiCache[guiInstance].Size

    local guiTween = TweenService:Create(guiInstance, tweenInfo, {
        Position = UDim2.fromScale(guiPosition.X.Scale, guiPosition.Y.Scale),
        Size = UDim2.fromScale(guiSize.X.Scale, guiSize.Y.Scale)
    })

    local cameraTween = TweenService:Create(camera, TweenInfo.new(GlobalVariables.Gui.GuiVisibleCameraTime), { FieldOfView = GlobalVariables.Gui.GuiVisibleCameraFOV })
    cameraTween:Play()
    
    -- backdrop should be present
    if backdropColour then showBackdrop(backdropColour) end

    guiTween:Play()

    return guiTween
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

function GuiServices.CreateConfettiEffect(sparseness: number, effectLength: number)
    if effectLength < 1 then return warn("Confetti effect has to be longer than 1 second.") end

    local random = Random.new()
    local SIZE_BOUNDS = {0.001, 0.02}
    local INITIAL_X_POS_BOUNDS = {0.1, 0.9}
    local FALL_SPEED_BOUNDS = {1, 3}
    local spawnConfetti = true

    task.delay(effectLength, function() spawnConfetti = false end)

    task.spawn(function()
        while spawnConfetti do
            local confettiParticle = ConfettiParticle:Clone()
            local size = random:NextNumber(SIZE_BOUNDS[1], SIZE_BOUNDS[2])
            confettiParticle.Size = UDim2.fromScale(size, size)
            confettiParticle.Position = UDim2.fromScale(random:NextNumber(INITIAL_X_POS_BOUNDS[1], INITIAL_X_POS_BOUNDS[2]), -0.1) -- initial pos
            confettiParticle.Rotation = math.random(0, 90)
            confettiParticle.BackgroundColor3 = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
            confettiParticle.Parent = ConfettiContainer
            confettiParticle.Visible = true
    
            local fallTween = TweenService:Create(confettiParticle, TweenInfo.new(random:NextNumber(FALL_SPEED_BOUNDS[1], FALL_SPEED_BOUNDS[2])), {
                Position = UDim2.fromScale(random:NextNumber(confettiParticle.Position.X.Scale - 0.2, confettiParticle.Position.X.Scale + 0.2), 1.1),
                Rotation = math.random(confettiParticle.Rotation - 90, confettiParticle.Rotation + 90)
            })
    
            fallTween:Play()
            -- cleanup
            fallTween.Completed:Connect(function()
                confettiParticle:Destroy()
            end)
    
            task.wait(sparseness / 100)
        end
    end)
end

function GuiServices.CreateBeamEffect(beamAmt: number, parent: Instance, effectLength: number)
    if effectLength < 1 then return warn("Beam effect has to be longer than 1 second.") end

    local random = Random.new()
    local X_SIZE_BOUNDS = {0.4, 0.5}
    local Y_SIZE_BOUNDS = {0.3, 0.5}
    local TRANSPARENCY_BOUNDS = {0.4, 0.8}

    for i=0, beamAmt, 1 do
        local beam = BeamImage:Clone()
        beam.ImageTransparency = 1
        beam.Rotation = math.random(0, 180)
        beam.Size = UDim2.fromScale(random:NextNumber(X_SIZE_BOUNDS[1], X_SIZE_BOUNDS[2]), random:NextNumber(Y_SIZE_BOUNDS[1], Y_SIZE_BOUNDS[2]))
        beam.Parent = parent
        beam.Visible = true

        local showTween = TweenService:Create(beam, TweenInfo.new(0.5), { ImageTransparency = random:NextNumber(TRANSPARENCY_BOUNDS[1], TRANSPARENCY_BOUNDS[2]) })
        showTween:Play()

        local movementTween = TweenService:Create(beam, TweenInfo.new(effectLength), {
            Rotation = math.random(beam.Rotation - 40, beam.Rotation + 40),
            Size = UDim2.fromScale(random:NextNumber(beam.Size.X.Scale - 0.1, beam.Size.X.Scale + 0.1), random:NextNumber(beam.Size.Y.Scale - 0.1, beam.Size.Y.Scale + 0.1))
        })
        movementTween:Play()

        -- cleanup
        movementTween.Completed:Connect(function()
            local makeInvisibleTween = TweenService:Create(beam, TweenInfo.new(0.5), {
                ImageTransparency = 1,
                Size = UDim2.fromScale(random:NextNumber(beam.Size.X.Scale - 0.05, beam.Size.X.Scale - 0.2), random:NextNumber(beam.Size.Y.Scale - 0.05, beam.Size.Y.Scale - 0.2))
                })
            makeInvisibleTween:Play()
            makeInvisibleTween.Completed:Connect(function() beam:Destroy() end)
        end)
    end
end

function GuiServices.TriggerFlashFrame(opts: {})
    if not opts then opts = {} end
    if not opts then opts["Colour"] = Color3.fromRGB(255, 255, 255) end

    FlashFrame.Visible = true

    local fadeInTween = TweenService:Create(FlashFrame, TweenInfo.new(GlobalVariables.Gui.FlashShowTime), { BackgroundTransparency = 0 })
    local fadeOutTween = TweenService:Create(FlashFrame, TweenInfo.new(1), { BackgroundTransparency = 1 })

    fadeInTween:Play()

    -- have flash stay on-screen for a bit
    task.delay(0.75, function()
        fadeOutTween:Play()
    end)
    fadeOutTween.Completed:Connect(function() FlashFrame.Visible = false end)
end

return GuiServices