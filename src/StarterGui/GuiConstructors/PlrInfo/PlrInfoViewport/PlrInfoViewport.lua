local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Libs:WaitForChild("Roact"))

local Remotes = ReplicatedStorage.Remotes

local PlrInfoViewport = Roact.Component:extend("PlrInfoViewport")

function PlrInfoViewport:init()
end

function PlrInfoViewport:render()
    return Roact.createElement("ViewportFrame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.fromScale(1, 1),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        ZIndex = 3,
    }, {
        uICorner = Roact.createElement("UICorner", {
            CornerRadius = UDim.new(1, 0),
        }),
    })
end

function PlrInfoViewport:didMount()
end

return PlrInfoViewport