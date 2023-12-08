local Players = game:GetService("Players")

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
    localPlr:SetAttribute("InStudio", false)
    localPlr:SetAttribute("InBuildMode", false)
    localPlr:SetAttribute("InPlaceMode", false)
end)

localPlr.CharacterAdded:Connect(function(character: Model)
    localPlr:SetAttribute("IsAlive", true)
    char = character
    humanoid = char:WaitForChild("Humanoid")

    humanoid.Died:Connect(function()
        localPlr:SetAttribute("IsAlive", false)
        localPlr:SetAttribute("InStudio", false)
        localPlr:SetAttribute("InBuildMode", false)
        localPlr:SetAttribute("InPlaceMode", false)
    end)
end)
