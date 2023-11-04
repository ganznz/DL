local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))

local Remotes = ReplicatedStorage.Remotes

local function createNotification(msgType: "standard" | "good" | "warning", msg: string)
    GuiServices.CreateNotification(msg, msgType)
end

Remotes.GUI.DisplayNotification.OnClientEvent:Connect(createNotification)