local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- various methods for NPC character and humanoids
local Npc = {}

function Npc.WeldNpcModel(npcModel: Model)
    local Part1 = npcModel.PrimaryPart

    for _, Part0 in pairs(npcModel:GetChildren()) do
        if Part0:IsA("BasePart") and not (Part0 == Part1) then
            local WeldConstraint = Instance.new("WeldConstraint")
            WeldConstraint.Part0 = Part0
            WeldConstraint.Part1 = Part1
            WeldConstraint.Parent = WeldConstraint.Part0
            
            Part0.Anchored = false
        end
    end
    
    Part1.Anchored = true
    Part1.CanCollide = false
end

function Npc.TweenTransparency(npcModel: Model, colour: Color3 | nil)
    -- local tweenInfo = TweenInfo.new(0.2)

    for _i, v in npcModel:GetDescendants() do
        
        if v:IsA("MeshPart") then
            local tween = TweenService:Create(v, TweenInfo.new(0.2), { Color = colour })
            tween:Play()
            local tween2 = TweenService:Create(v, TweenInfo.new(2), { Transparency = 1})
            tween2:Play()
        elseif v:IsA("Decal") then
            local tween = TweenService:Create(v, TweenInfo.new(0.2), { Transparency = 1 })
            tween:Play()
        end
    end
end

function Npc.RemoveNpcStandard(npcModel: Model, colour: Color3 | nil)
    local modelPrimaryPart = npcModel.PrimaryPart
    Npc.WeldNpcModel(npcModel)
    
    local tweenTime = 1
    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
    local tween = TweenService:Create(modelPrimaryPart, tweenInfo, {
        CFrame = modelPrimaryPart.CFrame * CFrame.new(0, 5, 0)
    })
    tween:Play()
    Npc.TweenTransparency(npcModel, colour)
    task.delay(tweenTime, function() npcModel:Destroy() end)
end

return Npc

