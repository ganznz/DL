local PathfindingService = game:GetService("PathfindingService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GeneralUtils = require(ReplicatedStorage.Utils:WaitForChild("GeneralUtils"))
local GeneralConfig = require(ReplicatedStorage.Configs:WaitForChild("General"))
local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))
local GuiTemplates = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiTemplates"))
local PlayerServices = require(ReplicatedStorage.Utils.Player:WaitForChild("Player"))
local CameraControls = require(ReplicatedStorage.Utils.Camera:WaitForChild("CameraControls"))
local GenreConfig = require(ReplicatedStorage.Configs.GameDev:WaitForChild("Genre"))
local TopicConfig = require(ReplicatedStorage.Configs.GameDev:WaitForChild("Topic"))
local StudioConfig = require(ReplicatedStorage.Configs.Studio:WaitForChild("Studio"))
local StaffMemberConfig = require(ReplicatedStorage.Configs.Staff:WaitForChild("StaffMember"))
local PlayerConfig = require(ReplicatedStorage.Configs:WaitForChild("Player"))
local PlayerUtils = require(ReplicatedStorage.Utils.Player:WaitForChild("Player"))
local ComputerConfig = require(ReplicatedStorage.Configs.GameDev:WaitForChild("Computer"))
local FormatNumber = require(ReplicatedStorage.Libs:WaitForChild("FormatNumber").Simple)

local Remotes = ReplicatedStorage.Remotes

local localPlr = Players.LocalPlayer

local PlayerGui = localPlr.PlayerGui
local camera = Workspace:WaitForChild("Camera")

-- GUI REFERENCE VARIABLES --
local AllGuiScreenGui = PlayerGui:WaitForChild("AllGui")

-- STATIC VARIABLES --

-- STATE VARIABLES --
local plrData = nil
local studioPcSetup: Model = nil
local pcSetupSeat: Seat = nil

local function setupPhaseOne()
    studioPcSetup = Workspace.TempAssets.Studios:FindFirstChild("Computer", true)
    pcSetupSeat = studioPcSetup:FindFirstChild("Seat", true)
    local cameraPosPart = studioPcSetup:FindFirstChild("CameraPosPartDev")
    local cameraLookAtPart = studioPcSetup:FindFirstChild("CameraLookAtPartDev")

    CameraControls.FocusOnObject(localPlr, camera, cameraPosPart.Position, cameraLookAtPart.Position, true, true)
    GeneralUtils.HideModel(studioPcSetup:FindFirstChild("Pc"), { Tween = true })
    PlayerServices.ShowPlayer(localPlr, true)
    PlayerUtils.SeatPlayer(localPlr, pcSetupSeat)
end

-- REMOTES --
Remotes.GameDev.DevelopGame.OnClientEvent:Connect(function(developmentPhase: string)
    if developmentPhase == 1 then
        plrData = Remotes.Data.GetAllData:InvokeServer()
        setupPhaseOne()
        return
    end
end)