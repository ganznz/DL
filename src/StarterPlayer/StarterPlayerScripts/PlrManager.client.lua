local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))

local localPlr = Players.LocalPlayer

local char = localPlr.Character or localPlr.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

-- ATTRIBUTES
-- these attributes are commonly used globally in scripts
localPlr:SetAttribute("IsAlive", true)
localPlr:SetAttribute("InStudio", false)
localPlr:SetAttribute("InBuildMode", false)
localPlr:SetAttribute("InPlaceMode", false)

humanoid.Died:Connect(function()
    localPlr:SetAttribute("IsAlive", false)
    localPlr:SetAttribute("InBuildMode", false)
    localPlr:SetAttribute("InPlaceMode", false)
    GuiServices.ShowHUD()
end)

localPlr.CharacterAdded:Connect(function(character: Model)
    localPlr:SetAttribute("IsAlive", true)
    char = character
    humanoid = char:WaitForChild("Humanoid")

    humanoid.Died:Connect(function()
        localPlr:SetAttribute("IsAlive", false)
        localPlr:SetAttribute("InBuildMode", false)
        localPlr:SetAttribute("InPlaceMode", false)
        GuiServices.ShowHUD()
    end)
end)
