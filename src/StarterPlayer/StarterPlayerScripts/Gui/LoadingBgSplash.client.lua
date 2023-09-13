local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Remotes = ReplicatedStorage.Remotes

local localPlr = Players.LocalPlayer
local PlayerControls = require(localPlr.PlayerScripts.PlayerModule):GetControls()
local PlayerGui = localPlr.PlayerGui

local LoadingBgSplashScreenGui = PlayerGui:WaitForChild("LoadingBgSplash")
local LoadingBgSplash = LoadingBgSplashScreenGui.LoadingBgSplash

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential)
local loadingScreenPositionDisabled = UDim2.fromScale(0.5, -1)
local loadingScreenPositionEnabled = UDim2.fromScale(0.5, 0)

local showLoadingBgTween = TweenService:Create(LoadingBgSplash, tweenInfo, { Position = loadingScreenPositionEnabled})
local hideLoadingBgTween = TweenService:Create(LoadingBgSplash, tweenInfo, { Position = loadingScreenPositionDisabled})

Remotes.GUI.ChangeGuiStatusRemote.OnClientEvent:Connect(function(guiName, showGui)
    if guiName == "loadingBgSplash" then
        if showGui then
            showLoadingBgTween:Play()
            PlayerControls:Disable()
            showLoadingBgTween.Completed:Connect(function()
                Remotes.Player.TeleportPlr:FireServer("furnitureStore")
            end)
        else
            hideLoadingBgTween:Play()
            PlayerControls:Enable()
        end
    end
end)