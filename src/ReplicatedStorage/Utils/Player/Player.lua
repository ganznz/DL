local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Remotes = ReplicatedStorage.Remotes

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

-- used to seat player when a seat has been replicated to client-side and no longer works
function Player.SeatPlayer(plr: Player, seat: Seat)
    local char = plr.Character or plr.CharacterAdded:Wait()
    local humanoid: Humanoid = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    hrp.Anchored = true

    local weldConstraint: WeldConstraint = Instance.new("WeldConstraint", hrp)
    weldConstraint.Name = "SeatWeldConstraint"

    local CFrameToSitAt: CFrame = seat.CFrame * CFrame.new(0, 1.4, 0)
    plr.Character:PivotTo(CFrameToSitAt)
    humanoid.Sit = true

    weldConstraint.Part0 = hrp
    weldConstraint.Part1 = seat

    Remotes.Player.ReplicateSeatPlr:FireServer(CFrameToSitAt)
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

Remotes.Player.ReplicateSeatPlr.OnClientEvent:Connect(function(plrToSit: Player, CFrameToSitAt: CFrame)
    local plrChar = plrToSit.Character or plrToSit.CharacterAdded:Wait()
    local hrp = plrChar:FindFirstChild("HumanoidRootPart")
    hrp.Anchored = true
    plrChar:PivotTo(CFrameToSitAt)
end)

return Player