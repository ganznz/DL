local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local GeneralUtils = require(ReplicatedStorage.Utils:WaitForChild("GeneralUtils"))
local CameraControls = require(ReplicatedStorage.Utils.Camera:WaitForChild("CameraControls"))
local PhoneConfig = require(ReplicatedStorage.Configs.Phones:WaitForChild("Phones"))

local Remotes = ReplicatedStorage.Remotes

local localPlr = Players.LocalPlayer
local camera = Workspace:WaitForChild("Camera")
local PlayerGui = localPlr.PlayerGui

-- GUI VARIABLES --
local AllGuiScreenGui = PlayerGui:WaitForChild("AllGui")
local PhoneOpeningBg = AllGuiScreenGui.Phones.PhoneUnlockContainer:WaitForChild("Background")
local PhoneIcon: ImageButton = AllGuiScreenGui.Phones.PhoneUnlockContainer:WaitForChild("PhoneIcon")

local allPhoneFolders = CollectionService:GetTagged("Phone")

-- STATE VARIABLES --
local currentlyOpeningPhone = false
local phoneAppearTween = nil
local phoneMovementTween = nil
local phoneIconMouseClickTween = nil
local phoneIconClickResetTween = nil

-- CONSTANT VARIABLES --
local TWEEN_INTERMISSION = 1 -- seconds. The wait between up-down tweens
local PHONE_OPENING_BG_TRANSPARENCY = 0.5
local PHONE_ICON_SCALE = UDim2.fromScale(0.35, 0.35)
local PHONE_ICON_HOVERED_SCALE = UDim2.fromScale(0.45, 0.45)
local PHONE_ICON_CLICKED_SCALE = UDim2.fromScale(0.25, 0.25)
local PHONE_TWEEN_ROTATION = 7 -- when the phone icon rotation tween plays, this is the rotation

PhoneIcon.Rotation = -PHONE_TWEEN_ROTATION

local function enableAllProxPrompts()
    for _i, phoneFolder in allPhoneFolders do
        local proxPrompt: ProximityPrompt = phoneFolder:FindFirstChild("ProximityPrompt", true)
        proxPrompt.Enabled = true
    end
end

local function disableAllProxPrompts()
    for _i, phoneFolder in allPhoneFolders do
        local proxPrompt: ProximityPrompt = phoneFolder:FindFirstChild("ProximityPrompt", true)
        proxPrompt.Enabled = false
    end
end

local function tweenPhone(phoneModel: Model)
    local rotValue = 0 -- used to determine if tween is moving up or down AND linear or exponential
    local tweenUpIteration = 0
    local tweenDownIteration = 0

    local createTweenDown -- declared var to 'hoist' createTweenDown function

    local function createTweenUp()
        rotValue += 120
        tweenUpIteration += 1
        local tweenInfo = rotValue % 360 == 0 and TweenInfo.new(1, Enum.EasingStyle.Exponential) or TweenInfo.new(0.2, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(phoneModel.PrimaryPart, tweenInfo, { CFrame = phoneModel.PrimaryPart.CFrame * CFrame.new(0, 1, 0) * CFrame.Angles(0, math.rad(120), 0) })
        tween:Play()
        tween.Completed:Connect(function()
            if tweenUpIteration < 3 then
                createTweenUp()
            else
                tweenUpIteration = 0
                task.wait(TWEEN_INTERMISSION)
                createTweenDown()
            end
        end)
    end
    createTweenDown = function()
        rotValue += 120
        tweenDownIteration += 1
        local tweenInfo = rotValue % 360 == 0 and TweenInfo.new(1, Enum.EasingStyle.Exponential) or TweenInfo.new(0.2, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(phoneModel.PrimaryPart, tweenInfo, { CFrame = phoneModel.PrimaryPart.CFrame * CFrame.new(0, -1, 0) * CFrame.Angles(0, math.rad(120), 0) })
        tween:Play()
        tween.Completed:Connect(function()
            if tweenDownIteration < 3 then
                createTweenDown()
            else
                tweenDownIteration = 0
                task.wait(TWEEN_INTERMISSION)
                createTweenUp()
            end
        end)
    end
    -- start tween loop
    createTweenUp()
end

for _i, phoneFolder in allPhoneFolders do
    local phoneName = phoneFolder.Name
    local phoneModel = phoneFolder:FindFirstChild("Phone")
    local proxPrompt: ProximityPrompt = phoneFolder:FindFirstChild("ProximityPrompt", true)

    -- tween phone
    tweenPhone(phoneModel)

    -- activate proximity prompt
    proxPrompt.Triggered:Connect(function(_plr: Player)
        -- open phone popup GUI
        Remotes.GUI.Phones.PhonePopup:Fire(phoneName)
    end)
end

local function preparePhoneIcon(phoneName: string)
    local phoneConfig = PhoneConfig.GetConfig(phoneName)
    PhoneIcon.Image = GeneralUtils.GetDecalUrl(phoneConfig.ImagePerspective)
    PhoneOpeningBg.Visible = true
    PhoneIcon.Visible = true

    phoneAppearTween = TweenService:Create(PhoneIcon, TweenInfo.new(1, Enum.EasingStyle.Bounce), { Size = PHONE_ICON_SCALE })
    phoneMovementTween = TweenService:Create(PhoneIcon, TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut, -1, true), { Rotation = PHONE_TWEEN_ROTATION })
    phoneAppearTween:Play()
    phoneMovementTween:Play()

    phoneIconMouseClickTween = TweenService:Create(PhoneIcon, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), { Size = PHONE_ICON_CLICKED_SCALE })
    phoneIconClickResetTween = TweenService:Create(PhoneIcon, TweenInfo.new(0.2, Enum.EasingStyle.Bounce), { Size = PHONE_ICON_SCALE })

    PhoneIcon.Activated:Connect(function()
        Remotes.Phones.PerformOpenClick:FireServer()
        phoneIconMouseClickTween:Play()
        phoneIconMouseClickTween.Completed:Connect(function() phoneIconClickResetTween:Play() end) -- after clicking tween completed, reset phone to normal size
    end)
end

local function preparePhoneForOpening(phoneName: string)
    local phoneFolder = Workspace.Map.Phones:FindFirstChild(phoneName)
    local cameraPosition: BasePart = phoneFolder:FindFirstChild("CameraPosPart").Position
    local cameraLookAtPosition: BasePart = phoneFolder:FindFirstChild("CameraLookAtPart").Position

    local bgTween = TweenService:Create(PhoneOpeningBg, TweenInfo.new(1), { BackgroundTransparency = PHONE_OPENING_BG_TRANSPARENCY })
    bgTween:Play()
    local cameraTween = CameraControls.FocusOnObject(localPlr, camera, cameraPosition, cameraLookAtPosition, true, true)
    cameraTween.Completed:Connect(function()
        preparePhoneIcon(phoneName)
    end)
end

-- enable all proximity prompts by default. Should already be enabled but just a safe measure
enableAllProxPrompts()

local function resetPhoneOpeningGui()
    PhoneOpeningBg.BackgroundTransparency = 1
    PhoneOpeningBg.Visible = false
    PhoneIcon.Image = ""
    PhoneIcon.Visible = false
    PhoneIcon.Size = UDim2.fromScale(0, 0)
    phoneAppearTween = nil
    phoneIconMouseClickTween = nil
    phoneIconClickResetTween = nil
    if phoneMovementTween then phoneMovementTween:Cancel() end
    phoneMovementTween = nil
end

Remotes.Phones.PurchasePhone.OnClientEvent:Connect(function(phoneName: string)
    resetPhoneOpeningGui()
    currentlyOpeningPhone = true
    disableAllProxPrompts()
    preparePhoneForOpening(phoneName)
end)