local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))
local CameraControls = require(ReplicatedStorage.Utils.Camera:WaitForChild("CameraControls"))

local localPlr = Players.LocalPlayer
local camera = Workspace:WaitForChild("Camera")

-- attributes that are commonly used globally in scripts are declared here
local function characterAdded(char: Model)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        GuiServices.HideGuiStandard()
        GuiServices.ShowHUD()
        CameraControls.SetDefault(localPlr, camera, false)
    end)
end

if localPlr.Character then characterAdded(localPlr.Character) end

localPlr.CharacterAdded:Connect(characterAdded)