local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local camera = Workspace:WaitForChild("Camera")

local WALK_SPEED = 16
local RUNNING_SPEED = 32
local WALK_FOV = 70
local RUNNING_FOV = 80

local tweenInfo = TweenInfo.new(0.2)

local function ChangeWalkspeed(newSpeed: number)
    local FOV = newSpeed == WALK_SPEED and WALK_FOV or RUNNING_FOV
    local tween = TweenService:Create(camera, tweenInfo, { FieldOfView = FOV })
    tween:Play()

    local humanoid: Humanoid = char:FindFirstChildOfClass("Humanoid")
    humanoid.WalkSpeed = newSpeed
end

UserInputService.InputBegan:Connect(function(input, _gameProcessed)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.LeftShift then
        ChangeWalkspeed(RUNNING_SPEED)
    end
end)

UserInputService.InputEnded:Connect(function(input, _gameProcessed)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.LeftShift then
        ChangeWalkspeed(WALK_SPEED)
    end
end)

plr.CharacterAdded:Connect(function(newChar)
    char = newChar
end)