local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlobalVariables = require(ReplicatedStorage:WaitForChild("GlobalVariables"))

local GuiTemplates = {}

function GuiTemplates.CreateButton(btn: Instance, opts: {})
    opts = opts or {}

    local originalRotation = btn.Rotation
    local tweenMouseEnter = TweenService:Create(btn, TweenInfo.new(0.2), { Rotation = 5 })
    local tweenMouseLeave = TweenService:Create(btn, TweenInfo.new(0.2), { Rotation = originalRotation })

    btn.MouseEnter:Connect(function()
        if opts["Rotates"] then tweenMouseEnter:Play() end
        GlobalVariables.Sound.Sfx.GuiMouseHover:Play()
    end)

    btn.MouseLeave:Connect(function()
        if opts["Rotates"] then tweenMouseLeave:Play() end
    end)

    btn.Activated:Connect(function()
        GlobalVariables.Sound.Sfx.GuiOpen:Play()
    end)
end

function GuiTemplates.HeaderText(header: Instance, opts: {})
    local tweenGoal

    -- if no specification for opts Movement option, then apply default movement (rotate)
    if not opts then
        tweenGoal = { Rotation = 4 }
    end

    TweenService:Create(header, TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut, 99999999999999, true), tweenGoal):Play()
end

return GuiTemplates