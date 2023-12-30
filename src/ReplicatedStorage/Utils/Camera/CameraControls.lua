-- module required client-side only

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local GeneralUtils = require(ReplicatedStorage.Utils:WaitForChild("GeneralUtils"))

local CameraControls = {}

-- Default camera settings. Sets camera back on player
function CameraControls.SetDefault(plr: Player, camera: Camera, transition: boolean)
    local humanoid = plr.Character:FindFirstAncestorWhichIsA("Humanoid")

    -- default camera values
    camera.CameraType = Enum.CameraType.Custom
    camera.HeadLocked = true
    camera.CameraSubject = humanoid
    camera.DiagonalFieldOfView = 123.053
    camera.FieldOfView = 70
    camera.FieldOfViewMode = Enum.FieldOfViewMode.Vertical
    camera.MaxAxisFieldOfView = 98.639

    camera.Focus = CFrame.new(plr.Character.PrimaryPart.Position)
    local orientation = GeneralUtils.GetCFrameOrientation(camera.CFrame)
    camera.CFrame = camera.CFrame * CFrame.Angles(orientation.X, orientation.Y, orientation.Z)

    -- enable character movement
    local PlrControls = require(plr.PlayerScripts.PlayerModule):GetControls()
    PlrControls:Enable()
end

-- cameraCFrame: cframe of camera
-- cameraSubject: what the camera is looking at
-- disableChar: disable plr character movement.
-- transition: smooth camera movement
function CameraControls.FocusOnObject(plr: Player, camera: Camera, cameraPos: Vector3, cameraLookAt: Vector3, disableChar: boolean, transition: boolean): Tween | nil
    if disableChar then
        local PlrControls = require(plr.PlayerScripts.PlayerModule):GetControls()
        PlrControls:Disable()
    end
    camera.CameraType = Enum.CameraType.Scriptable

    if transition then
        local tween = TweenService:Create(camera, TweenInfo.new(0.3), { CFrame =  CFrame.lookAt(cameraPos, cameraLookAt) })
        tween:Play()
        return tween
    else
        camera.CFrame = CFrame.lookAt(cameraPos, cameraLookAt)
    end
end

return CameraControls