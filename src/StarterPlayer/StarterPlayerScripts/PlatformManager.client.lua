local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local PlrPlatformManager = require(ReplicatedStorage:WaitForChild("PlrPlatformManager"))

local localPlr = Players.LocalPlayer

local pcInputValues = {0, 1, 2, 3, 4, 7, 8}
local mobileInputValues = {7, 10, 11}
local consoleInputValues = {12, 13, 14, 15, 16, 17, 18, 19}

PlrPlatformManager.CreateProfile(localPlr)

local function determinePlatform(plr: Player, lastInputType)
    
    -- plr on PC
    if table.find(pcInputValues, lastInputType.Value) and UserInputService.KeyboardEnabled then
        PlrPlatformManager.SetProfile(plr, "pc")
 
    -- plr on mobile
    elseif table.find(mobileInputValues, lastInputType.Value) and UserInputService.TouchEnabled then
        PlrPlatformManager.SetProfile(plr, "mobile")
    
    -- plr on console
    elseif table.find(consoleInputValues, lastInputType.Value) then
        PlrPlatformManager.SetProfile(plr, "console")
        
    end
end


Players.PlayerRemoving:Connect(function(plr: Player)
    PlrPlatformManager.DeleteProfile(plr)
end)

UserInputService.LastInputTypeChanged:Connect(function(lastInputType)
    determinePlatform(localPlr, lastInputType)
end)