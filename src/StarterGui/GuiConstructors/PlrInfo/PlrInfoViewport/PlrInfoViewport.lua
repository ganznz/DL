local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Libs:WaitForChild("Roact"))

local Remotes = ReplicatedStorage.Remotes
local localPlr = Players.LocalPlayer
local char = localPlr.Character or localPlr.CharacterAdded:Wait()
local upperTorso = char:WaitForChild("UpperTorso")

local viewportCam = Instance.new("Camera", upperTorso)
viewportCam.Name = "ViewportCam"
local viewportCamAttachment = Instance.new("Attachment", upperTorso)
viewportCamAttachment.CFrame = CFrame.new(upperTorso.CFrame.Position, upperTorso.Position)

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
    localPlr.CharacterAdded:Connect(function(char: Model)
        
    end)
end

return PlrInfoViewport