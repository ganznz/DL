local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Roact = require(ReplicatedStorage.Libs:WaitForChild("Roact"))

local Remotes = ReplicatedStorage.Remotes

local PlrInfoHungerBar = Roact.Component:extend("PlrInfoHungerBar")

local HUNGER_PROG_TEXT_TEMPLATE = "CURRENT/MAX"

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential)
local barProgInstance = nil
local barTextInstance = nil

function PlrInfoHungerBar:init()
    self.barProgRef = Roact.createRef()
    self.barTextRef = Roact.createRef()

    self:setState({
        maxHunger = self.props.maxHunger
    })
end

function PlrInfoHungerBar:render()
    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = Color3.fromRGB(65, 177, 65),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(1, 0.75),
        Size = UDim2.fromScale(0.67, 0.17),
    }, {
        uICorner = Roact.createElement("UICorner"),
    
        plrHungerBarProg = Roact.createElement("Frame", {
            [Roact.Ref] = self.barProgRef,

            BackgroundColor3 = Color3.fromRGB(93, 255, 93),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(self.props.currentHunger / self.state.maxHunger, 1),
            ZIndex = 2,
        }, {
            uICorner1 = Roact.createElement("UICorner"),
        }),
    
        plrHungerBarProgText = Roact.createElement("TextLabel", {
            [Roact.Ref] = self.barTextRef,

            FontFace = Font.new(
                "rbxasset://fonts/families/SourceSansPro.json",
                Enum.FontWeight.Bold,
                Enum.FontStyle.Normal
            ),
            Text = HUNGER_PROG_TEXT_TEMPLATE:gsub("CURRENT", self.props.currentHunger):gsub("MAX", self.state.maxHunger),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextScaled = true,
            TextSize = 14,
            TextStrokeColor3 = Color3.fromRGB(57, 113, 51),
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

function PlrInfoHungerBar:didMount()
    barProgInstance = self.barProgRef:getValue()
    barTextInstance = self.barTextRef:getValue()

    Remotes.Character.AdjustPlrHunger.OnClientEvent:Connect(function(currHunger)
        local barProgTween = TweenService:Create(barProgInstance, tweenInfo, { Size = UDim2.fromScale(currHunger / self.state.maxHunger, 1) })
        barTextInstance.Text = HUNGER_PROG_TEXT_TEMPLATE:gsub("CURRENT", currHunger):gsub("MAX", self.state.maxHunger)
        barProgTween:Play()
    end)
end

return PlrInfoHungerBar