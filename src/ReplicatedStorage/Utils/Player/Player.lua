local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Player = {}

function Player.HidePlayer(plr: Player, tween: boolean)
    local tweenInfo = TweenInfo.new(0.3)

    for _i, v in plr.Character:GetDescendants() do
        local _succ, _err = pcall(function()
            if tween then
                TweenService:Create(v, tweenInfo, { Transparency = 1 }):Play()
            else
                v.Transparency = 1
            end
        end)
    end
end

function Player.ShowPlayer(plr: Player, tween: boolean)
    local tweenInfo = TweenInfo.new(0.3)

    for _i, v in plr.Character:GetDescendants() do
        if v.Name == "HumanoidRootPart" then continue end
        
        local _succ, _err = pcall(function()
            if tween then
                TweenService:Create(v, tweenInfo, { Transparency = 0 }):Play()
            else
                v.Transparency = 0
            end
        end)
    end
end

function Player.GetPlrNameFromUserId(userId: number)
    local username = nil
    local success, errorMsg = pcall(function()
        username = Players:GetNameFromUserIdAsync(userId)
    end)
    return username
end

function Player.GetPlrIconImage(userId: number, thumbType: Enum.ThumbnailType, thumbSize: Enum.ThumbnailSize)
    local iconImg = nil
    local success, errorMsg = pcall(function()
        iconImg = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
    end)
    return iconImg
end

return Player