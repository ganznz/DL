local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local Remotes = ReplicatedStorage.Remotes

local allPhoneFolders = CollectionService:GetTagged("Phone")

-- Constant variables
local TWEEN_INTERMISSION = 1 -- seconds. The wait between up-down tweens

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