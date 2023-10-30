local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))

local Remotes = ReplicatedStorage.Remotes

local function createNotification(type: "standard" | "good" | "warning", msg: string)
    GuiServices.CreateNotification(msg, type)
end

Remotes.GUI.DisplayNotification.OnClientEvent:Connect(createNotification)