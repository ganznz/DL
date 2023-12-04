local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes

local StaffMember = require(ReplicatedStorage.Configs.GameDev.StaffMember)

function StaffMember:AdjustEnergy(amt: number)
    local newAmt = self.CurrentEnergy + amt
    return newAmt
end

-- function StaffMember

return StaffMember