local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Roact = require(ReplicatedStorage.Libs:WaitForChild("Roact"))

local Remotes = ReplicatedStorage.Remotes
local localPlayer = Players.LocalPlayer
local PlayerControls = require(localPlayer.PlayerScripts.PlayerModule):GetControls()



local LoadingBgSplashScreenGui = Roact.Component:extend("LoadingBgSplashScreenGui")

local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Exponential)
local openGuiTweenTopEnabled
local openGuiTweenBottomEnabled
local openGuiTweenTopDisabled
local openGuiTweenBottomDisabled

local loadingScreenInstance = nil
local loadingScreenTopInstance = nil
local loadingScreenBottomInstance = nil

local loadingScreenTopPositionDisabled = UDim2.fromScale(0, -1)
local loadingScreenBottomPositionDisabled = UDim2.fromScale(0, 1)
local loadingScreenTopPositionEnabled = UDim2.fromScale(0, 0)
local loadingScreenBottomPositionEnabled = UDim2.fromScale(0, 0)

function LoadingBgSplashScreenGui:init()
    self.loadingScreenRef = Roact.createRef()
    self.loadingScreenTopRef = Roact.createRef()
    self.loadingScreenBottomRef = Roact.createRef()
end

function LoadingBgSplashScreenGui:render()
    return Roact.createElement("ScreenGui", {
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    }, {
        loadingScreenSplash = Roact.createElement("Frame", {
            [Roact.Ref] = self.loadingScreenRef,
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.5, 0),
            Size = UDim2.fromScale(1, 1),
            Visible = false
        }, {
            loadingScreenSplashTop = Roact.createElement("ImageLabel", {
                [Roact.Ref] = self.loadingScreenTopRef,
                Image = "rbxassetid://14714008315",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                Position = loadingScreenTopPositionDisabled
            }),
    
            loadingScreenSplashBottom = Roact.createElement("ImageLabel", {
                [Roact.Ref] = self.loadingScreenBottomRef,
                Image = "rbxassetid://14714012201",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                Position = loadingScreenBottomPositionDisabled
            }),
        }),
    })
end

function LoadingBgSplashScreenGui:didMount()
    loadingScreenInstance = self.loadingScreenRef:getValue()
    loadingScreenTopInstance = self.loadingScreenTopRef:getValue()
    loadingScreenBottomInstance = self.loadingScreenBottomRef:getValue()

    openGuiTweenTopEnabled = TweenService:Create(loadingScreenTopInstance, tweenInfo, { Position = loadingScreenTopPositionEnabled})
    openGuiTweenBottomEnabled = TweenService:Create(loadingScreenBottomInstance, tweenInfo, { Position = loadingScreenBottomPositionEnabled})
    openGuiTweenTopDisabled = TweenService:Create(loadingScreenTopInstance, tweenInfo, { Position = loadingScreenTopPositionDisabled})
    openGuiTweenBottomDisabled = TweenService:Create(loadingScreenBottomInstance, tweenInfo, { Position = loadingScreenBottomPositionDisabled})
end

function LoadingBgSplashScreenGui:didUpdate(prevProps, _prevState)
    if prevProps.visibleWindow ~= "loadingScreen" and self.props.visibleWindow == "loadingScreen" then
        print("show furniture store gui")
        loadingScreenInstance.Visible = true
        openGuiTweenTopEnabled:Play()
        openGuiTweenBottomEnabled:Play()
        PlayerControls:Disable()
        openGuiTweenBottomEnabled.Completed:Connect(function()
            Remotes.Player.TeleportPlr:FireServer("furnitureStore")
        end)

    elseif prevProps.visibleWindow == "loadingScreen" and self.props.visibleWindow ~= "loadingScreen" then
        print("hide furniture store gui")
        openGuiTweenTopDisabled:Play()
        openGuiTweenBottomDisabled:Play()
        openGuiTweenTopDisabled.Completed:Connect(function()
            loadingScreenInstance.Visible = false
            PlayerControls:Enable()
        end)
    end
end

return LoadingBgSplashScreenGui