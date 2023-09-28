local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Remotes = ReplicatedStorage.Remotes

local localPlr = Players.LocalPlayer
local PlayerControls = require(localPlr.PlayerScripts.PlayerModule):GetControls()
local PlayerGui = localPlr.PlayerGui

local LoadingBgSplashScreenGui = PlayerGui:WaitForChild("LoadingBgSplash")
local LoadingBgSplash = LoadingBgSplashScreenGui.LoadingBgSplash

local TWEEN_TIME = 0.5
local tweenInfo = TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Exponential)
local loadingScreenPositionDisabled = UDim2.fromScale(0.5, -1)
local loadingScreenPositionEnabled = UDim2.fromScale(0.5, 0)

local showLoadingBgTween = TweenService:Create(LoadingBgSplash, tweenInfo, { Position = loadingScreenPositionEnabled})
local hideLoadingBgTween = TweenService:Create(LoadingBgSplash, tweenInfo, { Position = loadingScreenPositionDisabled})

local function enableLoadingTween(showGui: boolean, options)
    if showGui then
        showLoadingBgTween:Play()
        PlayerControls:Disable()
        task.delay(TWEEN_TIME, function()
            Remotes.Player.TeleportPlr:FireServer(options.TeleportPart)
        end)
    else
        hideLoadingBgTween:Play()
        PlayerControls:Enable()
    end
end

Remotes.GUI.ChangeGuiStatusRemote.OnClientEvent:Connect(function(guiName, showGui, options)
    if guiName == "loadingBgSplash" then
        enableLoadingTween(showGui, options)
    end
end)

Remotes.GUI.ChangeGuiStatusBindable.Event:Connect(function(guiName, showGui, options)
    if guiName == "loadingBgSplash" then
        enableLoadingTween(showGui, options)
    end
end)