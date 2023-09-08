local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Roact = require(ReplicatedStorage.Libs:WaitForChild("Roact"))

-- gui components
local LoadingBgSplashScreenGui = require(StarterGui.GuiConstructors.LoadingBgSplash:WaitForChild("LoadingBgSplashScreenGui"))

local Remotes = ReplicatedStorage.Remotes
local PlayerGui = Players.LocalPlayer.PlayerGui

local AllGui = Roact.Component:extend("AllGui")

function AllGui:init()
    self:setState({
        visibleWindow = Roact.None
    })
end

function AllGui:render()
    return Roact.createElement("ScreenGui", {
        ResetOnSpawn = false;
    }, {
        -- all gui goes here
        Roact.createElement(LoadingBgSplashScreenGui, {
            visibleWindow = self.state.visibleWindow,
            setVisibleWindow = function(window)
                self:setState({ visibleWindow = window })
            end
        }),
    })
end

function AllGui:didMount()
    Remotes.GUI.ChangeGuiStatusRemote.OnClientEvent:Connect(function(guiName)
        self:setState({ visibleWindow = guiName })
    end)
end

local handle = Roact.mount(Roact.createElement(AllGui), PlayerGui, "AllGui")