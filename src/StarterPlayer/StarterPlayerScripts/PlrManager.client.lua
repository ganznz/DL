local Players = game:GetService("Players")

local localPlr = Players.LocalPlayer

local char = localPlr.Character or localPlr.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

-- this attribute is used in other scripts primarily for functionality that shouldn't be triggered while the player is respawning (e.g. after resetting)
localPlr:SetAttribute("IsAlive", true)

humanoid.Died:Connect(function()
    localPlr:SetAttribute("IsAlive", false)
end)

localPlr.CharacterAdded:Connect(function(character: Model)
    localPlr:SetAttribute("IsAlive", true)
    char = character
    humanoid = char:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        localPlr:SetAttribute("IsAlive", false)
    end)
end)
