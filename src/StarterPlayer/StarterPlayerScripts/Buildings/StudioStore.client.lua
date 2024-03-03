local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Remotes = ReplicatedStorage.Remotes

local CameraControls = require(ReplicatedStorage.Utils.Camera.CameraControls)
local PlayerUtils = require(ReplicatedStorage.Utils.Player.Player)

local localPlr = Players.LocalPlayer
local camera = Workspace:FindFirstChild("Camera")

-- STATE VARIABLES --
local storeNpc: Model = nil
local storeNpcProxPrompt: ProximityPrompt = nil
local triggerProxPromptConnection: RBXScriptConnection = nil

-- function sets variables when player enters the studio store
local function setStateVariables(buildingName: string)
    local buildingInteriorFolder = Workspace.TempAssets.Buildings:WaitForChild(buildingName)
    storeNpc = buildingInteriorFolder.Interior:WaitForChild("StoreNPC")
    storeNpcProxPrompt = storeNpc:WaitForChild("HumanoidRootPart"):FindFirstChild("ProximityPrompt", true)
end

local function resetStateVariables()
    storeNpc = nil
    if triggerProxPromptConnection then triggerProxPromptConnection:Disconnect() end
    triggerProxPromptConnection = nil
end


Remotes.General.EnterBuilding.OnClientEvent:Connect(function(buildingName: string)
    if buildingName ~= "StudioStore" then return end

    setStateVariables(buildingName)

    triggerProxPromptConnection = storeNpcProxPrompt.Triggered:Connect(function(_plr: Player)
        Remotes.NPC.Dialogue.GetDialogue:FireServer("StudioStoreNPC")
    end)
end)

Remotes.General.ExitBuilding.OnClientEvent:Connect(function(plr, buildingPlrIsIn)
    resetStateVariables()
end)

Remotes.NPC.Dialogue.GetDialogue.OnClientEvent:Connect(function(dialogueInfo: {})
    if dialogueInfo.DialogueName ~= "StudioStoreNPC" then return end

    local storeNpcHead = storeNpc:FindFirstChild("Head")
    local cameraPosCFrame: CFrame = storeNpcHead.CFrame + (storeNpcHead.CFrame.LookVector * 3)

    -- focus camera on NPC
    CameraControls.FocusOnObject(localPlr, camera, cameraPosCFrame, storeNpcHead.CFrame, true, true)
    -- hide plr
    PlayerUtils.HidePlayer(localPlr, true)
end)
