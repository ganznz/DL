local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Libs:WaitForChild("Roact"))

local Container = require(StarterGui.GuiConstructors.PlrInfo:WaitForChild("PlrInfoContainer"))

local Remotes = ReplicatedStorage.Remotes

local PlrInfoScreenGui = Roact.Component:extend("PlrInfoScreenGui")

function PlrInfoScreenGui:init()
end

function PlrInfoScreenGui:render()
    return Roact.createElement("ScreenGui", {
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
    }, {
        Container = Roact.createElement(Container)
    })
end

function PlrInfoScreenGui:didMount()
end

return PlrInfoScreenGui