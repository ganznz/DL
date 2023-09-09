local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Libs:WaitForChild("Roact"))

local Remotes = ReplicatedStorage.Remotes

local PlrInfoPlrLevel = Roact.Component:extend("PlrInfoPlrLevel")

function PlrInfoPlrLevel:init()
end

function PlrInfoPlrLevel:render()
    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = Color3.fromRGB(255, 199, 56),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.fromScale(0.3, 0.3),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        ZIndex = 4,
    }, {
        uICorner = Roact.createElement("UICorner", {
            CornerRadius = UDim.new(1, 0),
        }),
    
        plrLevelText = Roact.createElement("TextLabel", {
            FontFace = Font.new(
                "rbxasset://fonts/families/SourceSansPro.json",
                Enum.FontWeight.Bold,
                Enum.FontStyle.Normal
            ),
            Text = "1",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextScaled = true,
            TextSize = 14,
            TextWrapped = true,
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(1, 1),
            ZIndex = 5,
        }),
    })
end

function PlrInfoPlrLevel:didMount()
end

return PlrInfoPlrLevel