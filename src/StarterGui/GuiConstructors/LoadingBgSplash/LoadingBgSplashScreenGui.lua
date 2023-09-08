local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Roact = require(ReplicatedStorage.Libs:WaitForChild("Roact"))

local Remotes = ReplicatedStorage.Remotes
local localPlayer = Players.LocalPlayer
local PlayerControls = require(localPlayer.PlayerScripts.PlayerModule):GetControls()



local LoadingBgSplashScreenGui = Roact.Component:extend("LoadingBgSplashScreenGui")

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential)
local openGuiTweenEnabled
local openGuiTweenDisabled

local loadingScreenInstance = nil

local loadingScreenPositionDisabled = UDim2.fromScale(0.5, -1)
local loadingScreenPositionEnabled = UDim2.fromScale(0.5, 0)

function LoadingBgSplashScreenGui:init()
    self.loadingScreenRef = Roact.createRef()
end

function LoadingBgSplashScreenGui:render()
    return Roact.createElement("ScreenGui", {
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    }, {
        loadingScreenSplash = Roact.createElement("Frame", {
            [Roact.Ref] = self.loadingScreenRef,
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundColor3 = Color3.fromRGB(56, 56, 56),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.5, -1),
            Size = UDim2.fromScale(1, 1),
            Visible = false,
        })
    })
end

function LoadingBgSplashScreenGui:didMount()
    loadingScreenInstance = self.loadingScreenRef:getValue()

    openGuiTweenEnabled = TweenService:Create(loadingScreenInstance, tweenInfo, { Position = loadingScreenPositionEnabled})
    openGuiTweenDisabled = TweenService:Create(loadingScreenInstance, tweenInfo, { Position = loadingScreenPositionDisabled})
end

function LoadingBgSplashScreenGui:didUpdate(prevProps, _prevState)
    if prevProps.visibleWindow ~= "loadingScreen" and self.props.visibleWindow == "loadingScreen" then
        print("show furniture store gui")
        loadingScreenInstance.Visible = true
        openGuiTweenEnabled:Play()
        PlayerControls:Disable()
        openGuiTweenEnabled.Completed:Connect(function()
            Remotes.Player.TeleportPlr:FireServer("furnitureStore")
        end)

    elseif prevProps.visibleWindow == "loadingScreen" and self.props.visibleWindow ~= "loadingScreen" then
        print("hide furniture store gui")
        openGuiTweenDisabled:Play()
        openGuiTweenDisabled.Completed:Connect(function()
            loadingScreenInstance.Visible = false
            PlayerControls:Enable()
        end)
    end
end

return LoadingBgSplashScreenGui