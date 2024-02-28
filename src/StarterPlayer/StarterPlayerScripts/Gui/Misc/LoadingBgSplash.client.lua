local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local GlobalVariables = require(ReplicatedStorage:WaitForChild("GlobalVariables"))

local Remotes = ReplicatedStorage.Remotes

local localPlr = Players.LocalPlayer
local PlayerControls = require(localPlr.PlayerScripts.PlayerModule):GetControls()
local PlayerGui = localPlr.PlayerGui

local LoadingBgSplash = PlayerGui:WaitForChild("AllGui").Misc:WaitForChild("LoadingBgSplash")

local tweenInfo = TweenInfo.new(GlobalVariables.Gui.LoadingBgTweenTime, Enum.EasingStyle.Exponential)
local loadingScreenPositionDisabled = UDim2.fromScale(0.5, -1)
local loadingScreenPositionEnabled = UDim2.fromScale(0.5, 0)

local showLoadingBgTween = TweenService:Create(LoadingBgSplash, tweenInfo, { Position = loadingScreenPositionEnabled})
local hideLoadingBgTween = TweenService:Create(LoadingBgSplash, tweenInfo, { Position = loadingScreenPositionDisabled})

local function enableLoadingTween()
    showLoadingBgTween:Play()
    PlayerControls:Disable()
    task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
        hideLoadingBgTween:Play()
        PlayerControls:Enable()
    end)
end

Remotes.GUI.ChangeGuiStatusRemote.OnClientEvent:Connect(function(guiName)
    if guiName == "loadingBgSplash" then
        enableLoadingTween()
    end
end)

Remotes.GUI.ChangeGuiStatusBindable.Event:Connect(function(guiName)
    if guiName == "loadingBgSplash" then
        enableLoadingTween()
    end
end)