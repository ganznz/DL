local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Roact = require(ReplicatedStorage.Libs:WaitForChild("Roact"))

local Remotes = ReplicatedStorage.Remotes

local PlrInfoEnergyBar = Roact.Component:extend("PlrInfoEnergyBar")

function PlrInfoEnergyBar:init()
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
            BackgroundColor3 = Color3.fromRGB(64, 223, 255),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(0.7, 1),
            ZIndex = 2,
        }, {
            uICorner1 = Roact.createElement("UICorner"),
        }),
    
        plrEnergyBarProgText = Roact.createElement("TextLabel", {
            FontFace = Font.new(
                "rbxasset://fonts/families/SourceSansPro.json",
                Enum.FontWeight.Bold,
                Enum.FontStyle.Normal
            ),
            Text = "75/100",
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

function PlrInfoEnergyBar:didMount()
end

return PlrInfoEnergyBar