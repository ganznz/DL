local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Roact = require(ReplicatedStorage.Libs:WaitForChild("Roact"))

local Remotes = ReplicatedStorage.Remotes

local PlrInfoLevelBar = Roact.Component:extend("PlrInfoLevelBar")

function PlrInfoLevelBar:init()
end

function PlrInfoLevelBar:render()
    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = Color3.fromRGB(255, 190, 39),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(1, 1),
        Size = UDim2.fromScale(0.8, 0.25),
    }, {
        uICorner = Roact.createElement("UICorner"),
    
        plrLevelBarProgText = Roact.createElement("TextLabel", {
            FontFace = Font.new(
                "rbxasset://fonts/families/SourceSansPro.json",
                Enum.FontWeight.Bold,
                Enum.FontStyle.Normal
            ),
            Text = "75/100",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextScaled = true,
            TextSize = 14,
            TextStrokeColor3 = Color3.fromRGB(113, 93, 53),
            TextStrokeTransparency = 0,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Right,
            AnchorPoint = Vector2.new(1, 1),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.98, 1),
            Size = UDim2.fromScale(0.4, 0.7),
            ZIndex = 3,
        }),
    
        plrLevelBarProg = Roact.createElement("Frame", {
            BackgroundColor3 = Color3.fromRGB(255, 236, 29),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(0.7, 1),
            ZIndex = 2,
        }, {
            uICorner1 = Roact.createElement("UICorner"),
        }),
    })
end

function PlrInfoLevelBar:didMount()
end

return PlrInfoLevelBar