local TweenService = game:GetService("TweenService")
-- module required client-side only

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

    -- enable character movement
    local PlrControls = require(plr.PlayerScripts.PlayerModule):GetControls()
    PlrControls:Enable()
end

-- cameraCFrame: cframe of camera
-- cameraSubject: what the camera is looking at
-- disableChar: disable plr character movement.
-- transition: smooth camera movement
function CameraControls.FocusOnObject(plr: Player, camera: Camera, cameraPos: Vector3, cameraLookAt: Vector3, disableChar: boolean, transition: boolean)
    if disableChar then
        local PlrControls = require(plr.PlayerScripts.PlayerModule):GetControls()
        PlrControls:Disable()
    end
    camera.CameraType = Enum.CameraType.Scriptable

    if transition then
        TweenService:Create(camera, TweenInfo.new(0.3), { CFrame =  CFrame.lookAt(cameraPos, cameraLookAt) }):Play()
    else
        camera.CFrame = CFrame.lookAt(cameraPos, cameraLookAt)
    end
end

return CameraControls