local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local GlobalVariables = require(ReplicatedStorage.GlobalVariables)
local Stack = require(ReplicatedStorage.Utils.DataStructures:WaitForChild("Stack"))
local FormatNumber = require(ReplicatedStorage.Libs.FormatNumber.Simple)

local Remotes = ReplicatedStorage.Remotes
local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui

local camera = Workspace:FindFirstChild("Camera")

local AllGuiScreenGui: ScreenGui = PlayerGui:WaitForChild("AllGui")
local GuiBackdropFrame: Frame = AllGuiScreenGui.Misc.GuiBackdrop
local NotificationPanelFrame = AllGuiScreenGui.Misc.Notification.NotificationPanel
local FlashFrame: Frame = AllGuiScreenGui.Misc.FlashBg
-- border flash gui
local BorderFlashContainer: Frame = AllGuiScreenGui.Misc.BorderFlash
local BorderFlashImage: ImageLabel = BorderFlashContainer.BorderFlashImage
-- beam effect gui
local BeamImage: ImageLabel = AllGuiScreenGui.Particles.Beam
-- confetti effect gui
local ConfettiContainer: Frame = AllGuiScreenGui.Misc.ConfettiContainer
local ConfettiParticle: Frame = AllGuiScreenGui.Particles.ConfettiParticle

local HudFolder = AllGuiScreenGui.Hud
-- left HUD containers
local LeftHudFolder = HudFolder:WaitForChild("Left")
local LeftHudBtnContainer = LeftHudFolder:WaitForChild("LeftBtnContainer")
local LeftHudPlrInfoContainer = LeftHudFolder:WaitForChild("PlrInfoContainer")
-- right HUD containers
local RightHudFolder = HudFolder:WaitForChild("Right")
local RightHudBtnContainer = RightHudFolder:WaitForChild("RightBtnContainer")
-- bottom HUD containers
local BottomHudFolder = HudFolder:WaitForChild("Bottom")
local BottomHudBtns = BottomHudFolder:WaitForChild("BottomBtns")

local GuiBlur = Lighting:WaitForChild("GuiBlur")

local LEVEL_XP_TEXT_TEMPLATE = "CURRENT / MAX XP"
local OFFSET_PER_NOTI = NotificationPanelFrame.Template.Size.Y.Scale + 0.03
local NOTI_VISIBLE_X_POS = 0.5 -- scale value
local NOTI_HIDDEN_X_POS = 2.6 -- scale value

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

-- opts
-- -- PosX -> number: Scale
-- -- PosY -> number: Scale
function GuiServices.DefaultMainGuiStyling(guiInstance: Frame, opts: {}): UDim2
    local xPos = if (opts and opts["PosX"]) then opts["PosX"] else GuiCache[guiInstance].Position.X.Scale
    local yPos = if (opts and opts["PosY"]) then opts["PosY"] else GuiCache[guiInstance].Position.Y.Scale + GlobalVariables.Gui.MainGuiInvisibleYOffset

    guiInstance.Position = UDim2.fromScale(xPos, yPos)
    guiInstance.Visible = false

    return guiInstance.Position
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

-- opts
-- -- SwitchingGui -> boolean: This is enabled if the player has opened a GUI frame while another was already open.
local function hideGuiTweens(guiInstanceToClose, opts: {})
    GuiStack:Pop()

    local tweenInfo = TweenInfo.new(GlobalVariables.Gui.MainGuiCloseTime, Enum.EasingStyle.Linear)
    local guiPosition = GuiCache[guiInstanceToClose].Position
    local guiSize = GuiCache[guiInstanceToClose].Size

    local guiTween = TweenService:Create(guiInstanceToClose, tweenInfo, {
        Position = UDim2.fromScale(guiPosition.X.Scale + GlobalVariables.Gui.MainGuiInvisibleXOffset, guiPosition.Y.Scale + GlobalVariables.Gui.MainGuiInvisibleYOffset),
        Size = UDim2.fromScale(guiSize.X.Scale + GlobalVariables.Gui.MainGuiInvisibleXSize, guiSize.Y.Scale - GlobalVariables.Gui.MainGuiInvisibleYSize)
    })
    guiTween:Play()
    guiTween.Completed:Connect(function(_playbackState)
        guiInstanceToClose.Visible = false
    end)

    -- only hide backdrop & revert camera settings if closing gui, not if switching between gui instances
    if opts and opts["SwitchingGui"] then return guiTween end

    local cameraTween = TweenService:Create(camera, TweenInfo.new(GlobalVariables.Gui.GuiInvisibleCameraTime), { FieldOfView = GlobalVariables.Gui.GuiInvisibleCameraFOV })
    cameraTween:Play()

    hideBackdrop()

    local guiBlurTween = TweenService:Create(GuiBlur, tweenInfo, { Size = 0 })
    guiBlurTween:Play()

    return guiTween
end

-- opts
-- -- GuiToOpen -> Instance: This is enabled if the player has opened a GUI frame while another was already open.
function GuiServices.HideGuiStandard(guiInstanceToClose, opts: {}): Tween
    -- re-enable players sprint again, as they no longer have GUI open
    Remotes.Player.SprintEnable:FireServer()

    -- if no args are passed, then hide whatever GUI screen is open, if any
    -- use cases include features in-game that when interacted with, require any visible GUI frame to no longer be visible (e.g. entering studio build mode)
    if not guiInstanceToClose then
        local previousInstance = GuiStack:Peek()
        if previousInstance and previousInstance ~= "" then
            local guiTween = hideGuiTweens(previousInstance)
            Remotes.GUI.ToggleBottomHUD:Fire(nil)

            -- arg is the guiInstance that is being opened
            Remotes.GUI.ToggleBottomHUD:Fire(previousInstance)
            return guiTween
        end
        return
    end

    local guiToOpen = if opts then opts["GuiToOpen"] else nil

    local switchingUI = false
    if guiInstanceToClose and guiToOpen then
        -- UI about to be opened is different to UI that is currently opened
        if guiInstanceToClose ~= guiToOpen then
            switchingUI = true
        end
    end

    local guiTween = hideGuiTweens(guiInstanceToClose, { SwitchingGui = switchingUI })

    return guiTween
end

function GuiServices.ShowGuiStandard(guiInstance, backdropColour: Color3)
    -- hide any potential open UI
    local previousInstance = GuiStack:Peek()
    if previousInstance and previousInstance ~= "" then
        GuiServices.HideGuiStandard(previousInstance, { GuiToOpen = guiInstance })
        
        if previousInstance == guiInstance then return end
    end

    -- disable plr sprint (mostly because of camera FOV effect) when GUI is open
    Remotes.Player.SprintDisable:FireServer()

    -- arg is the guiInstance that is being opened
    Remotes.GUI.ToggleBottomHUD:Fire(guiInstance)

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

-- opts:
-- ----> HideGuiFrames: When this option is declared, close any gui frame that may be open
function GuiServices.HideHUD(opts: {})
    -- hide any window that may be open
    if opts and opts["HideGuiFrames"] then
        GuiServices.HideGuiStandard()
    end

    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

    -- left-side HUD items
    for _i, guiInstance in { LeftHudBtnContainer, LeftHudPlrInfoContainer } do
        local cachedData = GuiServices.GetCachedData(guiInstance)
        local tween = TweenService:Create(guiInstance, tweenInfo, { Position = UDim2.fromScale(0 - cachedData.Size.X.Scale, cachedData.Position.Y.Scale) })
        tween:Play()
        tween.Completed:Connect(function() guiInstance.Visible = false end)
    end
    -- right-side HUD items
    for _i, guiInstance in { RightHudBtnContainer } do
        local cachedData = GuiServices.GetCachedData(guiInstance)
        local tween = TweenService:Create(guiInstance, tweenInfo, { Position = UDim2.fromScale(1 + cachedData.Size.X.Scale, cachedData.Position.Y.Scale) })
        tween:Play()
        tween.Completed:Connect(function() guiInstance.Visible = false end)
    end
    -- bottom HUD items
    for _i, guiInstance in { BottomHudBtns } do
        local cachedData = GuiServices.GetCachedData(guiInstance)
        local tween = TweenService:Create(guiInstance, tweenInfo, { Position = UDim2.fromScale(cachedData.Position.X.Scale, 1 + cachedData.Size.Y.Scale) })
        tween:Play()
        tween.Completed:Connect(function() guiInstance.Visible = false end)
    end
end

function GuiServices.ShowHUD()
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

    -- left-side HUD items
    for _i, guiInstance in { LeftHudBtnContainer, LeftHudPlrInfoContainer } do
        local cachedData = GuiServices.GetCachedData(guiInstance)
        guiInstance.Visible = true
        TweenService:Create(guiInstance, tweenInfo, { Position = cachedData.Position }):Play()
    end
    -- right-side HUD items
    for _i, guiInstance in { RightHudBtnContainer } do
        local cachedData = GuiServices.GetCachedData(guiInstance)
        guiInstance.Visible = true
        TweenService:Create(guiInstance, tweenInfo, { Position = cachedData.Position }):Play()
    end
    -- bottom HUD items
    for _i, guiInstance in { BottomHudBtns } do
        local cachedData = GuiServices.GetCachedData(guiInstance)
        guiInstance.Visible = true
        TweenService:Create(guiInstance, tweenInfo, { Position = cachedData.Position }):Play()
    end
end

-- IMPORTANT: Only recommended to use call this method on an instance who's transparency will not be adjusted back to normal later on unless the instance children by default have the same transparency values
-- ^^ ADD LATER: to make the previous point obsolete, add cached transparency data for instances&children to easily revert transparency values
-- opts
---- opts["IgnoreProperties"]: { [instanceType]: { string } } - The properties to ignore, e.g. { ["TextButton"] = { BackgroundTransparency } }
function GuiServices.ChangeTransparency(guiInstance, transparencyValue, tweenTime, opts: {})
    opts = opts or {}

    local tweenInfo: TweenInfo = TweenInfo.new(tweenTime or 0)
    local tween = nil
    local iterateOver = guiInstance:GetDescendants()
    table.insert(iterateOver, guiInstance)

    for _i, v in iterateOver do
        local success, _ = pcall(function()
            local tweenGoal: {}

            if v:IsA("Frame") then
                if opts["IgnoreProperties"] and opts["IgnoreProperties"]["Frame"] then
                    local propertiesToIgnore: {} = opts["IgnoreProperties"]["Frame"]
                    tweenGoal = { BackgroundTransparency = table.find(propertiesToIgnore, "BackgroundTransparency") and v.BackgroundTransparency or transparencyValue }
                else
                    tweenGoal = { BackgroundTransparency = transparencyValue }
                end

            elseif v:IsA("ScrollingFrame") then
                if opts["IgnoreProperties"] and opts["IgnoreProperties"]["ScrollingFrame"] then
                    local propertiesToIgnore: {} = opts["IgnoreProperties"]["ScrollingFrame"]
                    tweenGoal = { BackgroundTransparency = table.find(propertiesToIgnore, "BackgroundTransparency") and v.BackgroundTransparency or transparencyValue }
                else
                    tweenGoal = { BackgroundTransparency = transparencyValue }
                end

            elseif v:IsA("ImageLabel") then
                if opts["IgnoreProperties"] and opts["IgnoreProperties"]["ImageLabel"] then
                    local propertiesToIgnore: {} = opts["IgnoreProperties"]["ImageLabel"]
                    tweenGoal = {
                        BackgroundTransparency = table.find(propertiesToIgnore, "BackgroundTransparency") and v.BackgroundTransparency or transparencyValue,
                        ImageTransparency = table.find(propertiesToIgnore, "ImageTransparency") and v.ImageTransparency or transparencyValue
                    }
                else
                    tweenGoal = { BackgroundTransparency = transparencyValue, ImageTransparency = transparencyValue }
                end

            elseif v:IsA("ImageButton") then
                if opts["IgnoreProperties"] and opts["IgnoreProperties"]["ImageButton"] then
                    local propertiesToIgnore: {} = opts["IgnoreProperties"]["ImageButton"]
                    tweenGoal = {
                        BackgroundTransparency = table.find(propertiesToIgnore, "BackgroundTransparency") and v.BackgroundTransparency or transparencyValue,
                        ImageTransparency = table.find(propertiesToIgnore, "ImageTransparency") and v.ImageTransparency or transparencyValue
                    }
                else
                    tweenGoal = { BackgroundTransparency = transparencyValue, ImageTransparency = transparencyValue }
                end

            elseif v:IsA("TextLabel") then
                if opts["IgnoreProperties"] and opts["IgnoreProperties"]["TextLabel"] then
                    local propertiesToIgnore: {} = opts["IgnoreProperties"]["TextLabel"]
                    table.find(propertiesToIgnore, "BackgroundTransparency")
                    table.find(propertiesToIgnore, "TextTransparency")
                    tweenGoal = {
                        BackgroundTransparency = table.find(propertiesToIgnore, "BackgroundTransparency") and v.BackgroundTransparency or transparencyValue,
                        TextTransparency = table.find(propertiesToIgnore, "TextTransparency") and v.TextTransparency or transparencyValue
                    }
                else
                    tweenGoal = { BackgroundTransparency = transparencyValue, TextTransparency = transparencyValue }
                end

            elseif v:IsA("TextButton") then
                if opts["IgnoreProperties"] and opts["IgnoreProperties"]["TextButton"] then
                    local propertiesToIgnore: {} = opts["IgnoreProperties"]["TextButton"]
                    tweenGoal = {
                        BackgroundTransparency = table.find(propertiesToIgnore, "BackgroundTransparency") and v.BackgroundTransparency or transparencyValue,
                        TextTransparency = table.find(propertiesToIgnore, "TextTransparency") and v.TextTransparency or transparencyValue,
                        TextStrokeTransparency = table.find(propertiesToIgnore, "TextStrokeTransparency") and v.TextStrokeTransparency or transparencyValue
                    }
                else
                    tweenGoal = { BackgroundTransparency = transparencyValue, TextTransparency = transparencyValue, TextStrokeTransparency = transparencyValue }
                end
            
            elseif v:IsA("TextBox") then
                if opts["IgnoreProperties"] and opts["IgnoreProperties"]["TextBox"] then
                    local propertiesToIgnore: {} = opts["IgnoreProperties"]["TextBox"]
                    tweenGoal = {
                        BackgroundTransparency = table.find(propertiesToIgnore, "BackgroundTransparency") and v.BackgroundTransparency or transparencyValue,
                        TextTransparency = table.find(propertiesToIgnore, "TextTransparency") and v.TextTransparency or transparencyValue,
                        TextStrokeTransparency = table.find(propertiesToIgnore, "TextStrokeTransparency") and v.TextStrokeTransparency or transparencyValue
                    }
                else
                    tweenGoal = { BackgroundTransparency = transparencyValue, TextTransparency = transparencyValue, TextStrokeTransparency = transparencyValue }
                end

            elseif v:IsA("UIStroke") then
                if opts["IgnoreProperties"] and opts["IgnoreProperties"]["UIStroke"] then
                    local propertiesToIgnore: {} = opts["IgnoreProperties"]["UIStroke"]
                    tweenGoal = { Transparency = table.find(propertiesToIgnore, "Transparency") and v.Transparency or transparencyValue }
                else
                    tweenGoal = { Transparency = transparencyValue }
                end
            end

            tween = TweenService:Create(v, tweenInfo, tweenGoal)
            tween:Play()
        end)
    end
end

-- function allows quickly setting a levelup bar
function GuiServices.SetLevelBar(progBarInstance, progBarLvlTxt, progBarXpText, level, xp, maxXp)
    progBarLvlTxt.Text = level
    progBarXpText.Text = LEVEL_XP_TEXT_TEMPLATE:gsub("CURRENT", FormatNumber.FormatCompact(xp)):gsub("MAX", FormatNumber.FormatCompact(maxXp))
    progBarInstance.Size = UDim2.fromScale(xp / maxXp, 1)
end

-- args     
---- progBarInstance -> The progress bit of the bar.        
---- progBarLvlText -> Displays the level of the respective instance.       
---- progBarXpText -> Displays the XP of the respective instances level.        
---- preAdjustmentLevel -> The level **before** XP adjustment of the respective instance being levelled.        
---- postAdjustmentXp -> The level **after** XP adjustment of the respective instance being levelled.       
---- postAdjustmentLevel -> The XP **after** XP adjustment of the respective instance being levelled.       
---- postAdjustmentMaxXp -> The max XP **after** XP adjustment of the respective instance being levelled.       
function GuiServices.TweenProgBar(progBarInstance, progBarLvlTxt, progBarXpText, preAdjustmentLevel, postAdjustmentLevel, postAdjustmentXp, postAdjustmentMaxXp): Tween
    local TWEEN_TIME = 1 -- seconds

    local tweenInfoSameLvl = TweenInfo.new((postAdjustmentXp/postAdjustmentMaxXp) * TWEEN_TIME, Enum.EasingStyle.Linear)
    local tweenInfoNewLvl = TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Linear)

    progBarLvlTxt.Text = preAdjustmentLevel

    -- while prog bar is tweening, hide xp text
    local propertiesToIgnore = { ["TextLabel"] = {"BackgroundTransparency"} }
    GuiServices.ChangeTransparency(progBarXpText, 1, 0.1, { IgnoreProperties = propertiesToIgnore })

    local tween
    if preAdjustmentLevel ~= postAdjustmentLevel then
        tween = TweenService:Create(progBarInstance, tweenInfoNewLvl, { Size = UDim2.fromScale(1, 1) })
        tween:Play()
        tween.Completed:Connect(function(_playbackState)
            progBarInstance.Size = UDim2.fromScale(0, 1)
            GuiServices.TweenProgBar(progBarInstance, progBarLvlTxt, progBarXpText, preAdjustmentLevel + 1, postAdjustmentLevel, postAdjustmentXp, postAdjustmentMaxXp)
        end)
    else
        tween = TweenService:Create(progBarInstance, tweenInfoSameLvl, { Size = UDim2.fromScale(postAdjustmentXp / postAdjustmentMaxXp, 1) })
        tween:Play()

        -- update xp text
        tween.Completed:Connect(function(_playbackState)
            progBarXpText.Text = LEVEL_XP_TEXT_TEMPLATE:gsub("CURRENT", FormatNumber.FormatCompact(postAdjustmentXp)):gsub("MAX", FormatNumber.FormatCompact(postAdjustmentMaxXp))
            GuiServices.ChangeTransparency(progBarXpText, 0, 0.2, { IgnoreProperties = propertiesToIgnore })
        end)
    end

    return tween
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

    local tweenShow = TweenService:Create(template, TweenInfo.new(1, Enum.EasingStyle.Elastic), { Position = UDim2.fromScale(NOTI_VISIBLE_X_POS, 0) })
    local progBarTweenInfo = TweenInfo.new(5, Enum.EasingStyle.Linear)
    local progBarTween = TweenService:Create(progBar, progBarTweenInfo, { Size = UDim2.fromScale(1, 0.1) })
    
    tweenShow:Play()

    -- start prog bar tween
    tweenShow.Completed:Connect(function(_playbackState) progBarTween:Play() end)

    -- hide noti
    progBarTween.Completed:Connect(function(_playbackState)
        local currentYpos = template.Position.Y.Scale
        local tweenHide = TweenService:Create(template, TweenInfo.new(0.4), { Position = UDim2.fromScale(NOTI_HIDDEN_X_POS, currentYpos) })
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

-- opts     
-- Colour -> Color3: the colour of the flash frame
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

local borderFlashTween = TweenService:Create(BorderFlashImage, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true), { ImageTransparency = 0 })
local flashTweenCompletedConnection: RBXScriptConnection | nil = nil
function GuiServices.TriggerBorderFlash(colour: Color3)
    borderFlashTween:Cancel()
    BorderFlashContainer.Visible = true
    BorderFlashImage.ImageTransparency = 1
    BorderFlashImage.ImageColor3 = colour
    borderFlashTween:Play()
    flashTweenCompletedConnection = borderFlashTween.Completed:Connect(function()
        if flashTweenCompletedConnection then flashTweenCompletedConnection:Disconnect() end
        flashTweenCompletedConnection = nil
        BorderFlashContainer.Visible = false
    end)
end

return GuiServices