local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Remotes = ReplicatedStorage.Remotes
local localPlr = Players.LocalPlayer

local pcInputValues = {0, 1, 2, 3, 4, 7, 8}
local mobileInputValues = {7, 10, 11}
local consoleInputValues = {12, 13, 14, 15, 16, 17, 18, 19}
local invalidInputValues = {20, 21, 22}

local function determinePlatform(lastInputType): "pc" | "mobile" | "console"
    if table.find(invalidInputValues, lastInputType.Value) then return nil end

    -- plr on PC
    if table.find(pcInputValues, lastInputType.Value) and UserInputService.KeyboardEnabled then
        return "pc"

    -- plr on mobile
    elseif table.find(mobileInputValues, lastInputType.Value) and UserInputService.TouchEnabled then
        return "mobile"

    -- plr on console
    elseif table.find(consoleInputValues, lastInputType.Value) then
        return "console"
    end
end

UserInputService.LastInputTypeChanged:Connect(function(lastInputType)
    local newPlatform = determinePlatform(lastInputType)
    if not newPlatform then return end

    Remotes.Player.PlatformChanged:FireServer(newPlatform)
end)