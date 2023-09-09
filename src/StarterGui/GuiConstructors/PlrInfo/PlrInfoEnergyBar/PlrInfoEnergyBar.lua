local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Roact = require(ReplicatedStorage.Libs:WaitForChild("Roact"))

local Remotes = ReplicatedStorage.Remotes

local PlrInfoEnergyBar = Roact.Component:extend("PlrInfoEnergyBar")

local ENERGY_PROG_TEXT_TEMPLATE = "CURRENT/MAX"

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential)
local barProgInstance = nil
local barTextInstance = nil

function PlrInfoEnergyBar:init()
    self.barProgRef = Roact.createRef()
    self.barTextRef = Roact.createRef()

    self:setState({
        maxEnergy = self.props.maxEnergy
    })
end

function PlrInfoEnergyBar:render()
    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = Color3.fromRGB(60, 171, 255),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(1, 0.58),
        Size = UDim2.fromScale(0.67, 0.17),
    }, {
        uICorner = Roact.createElement("UICorner"),
    
        plrEnergyBarProg = Roact.createElement("Frame", {
            [Roact.Ref] = self.barProgRef,

            BackgroundColor3 = Color3.fromRGB(64, 223, 255),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(self.props.currentEnergy / self.state.maxEnergy, 1),
            ZIndex = 2,
        }, {
            uICorner1 = Roact.createElement("UICorner"),
        }),
    
        plrEnergyBarProgText = Roact.createElement("TextLabel", {
            [Roact.Ref] = self.barTextRef,

            FontFace = Font.new(
                "rbxasset://fonts/families/SourceSansPro.json",
                Enum.FontWeight.Bold,
                Enum.FontStyle.Normal
            ),
            Text = ENERGY_PROG_TEXT_TEMPLATE:gsub("CURRENT", self.props.currentEnergy):gsub("MAX", self.state.maxEnergy),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextScaled = true,
            TextSize = 14,
            TextStrokeColor3 = Color3.fromRGB(63, 106, 192),
            TextStrokeTransparency = 0,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Right,
            AnchorPoint = Vector2.new(1, 1),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.98, 1),
            Size = UDim2.fromScale(0.4, 0.8),
            ZIndex = 3,
        }),
    })
end

function PlrInfoEnergyBar:didMount()
    barProgInstance = self.barProgRef:getValue()
    barTextInstance = self.barTextRef:getValue()

    Remotes.Character.AdjustPlrEnergy.OnClientEvent:Connect(function(currEnergy)
        local barProgTween = TweenService:Create(barProgInstance, tweenInfo, { Size = UDim2.fromScale(currEnergy / self.state.maxEnergy, 1) })
        barTextInstance.Text = ENERGY_PROG_TEXT_TEMPLATE:gsub("CURRENT", currEnergy):gsub("MAX", self.state.maxEnergy)
        barProgTween:Play()
    end)
end

return PlrInfoEnergyBar