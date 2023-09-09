local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Libs:WaitForChild("Roact"))

local Viewport = require(StarterGui.GuiConstructors.PlrInfo.PlrInfoViewport:WaitForChild("PlrInfoViewport"))
local Level = require(StarterGui.GuiConstructors.PlrInfo.PlrInfoPlrLevel:WaitForChild("PlrInfoPlrLevel"))
local LevelBar = require(StarterGui.GuiConstructors.PlrInfo.PlrInfoLevelBar:WaitForChild("PlrInfoLevelBar"))
local EnergyBar = require(StarterGui.GuiConstructors.PlrInfo.PlrInfoEnergyBar:WaitForChild("PlrInfoEnergyBar"))
local HungerBar = require(StarterGui.GuiConstructors.PlrInfo.PlrInfoHungerBar:WaitForChild("PlrInfoHungerBar"))

local Remotes = ReplicatedStorage.Remotes

local PlrInfoContainer = Roact.Component:extend("PlrInfoContainer")

function PlrInfoContainer:init()
end

function PlrInfoContainer:render()
    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.005, 0.99),
        Size = UDim2.fromScale(0.2, 0.15),
    }, {
        uIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
            AspectRatio = 2.71,
        }),

        Viewport = Roact.createElement(Viewport),

        Level = Roact.createElement(Level),

        LevelBar = Roact.createElement(LevelBar),

        EnergyBar = Roact.createElement(EnergyBar),

        HungerBar = Roact.createElement(HungerBar),
    })
end

function PlrInfoContainer:didMount()
end

return PlrInfoContainer