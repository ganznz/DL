-- // The functionality in this file are used only for operations on StaffMember class objects // --
-- general staff member functionality (e.g. unlocking staff member, deleting staff member) in StaffServer.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes

local StaffMember = require(ReplicatedStorage.Configs.Staff.StaffMember)

function StaffMember:AdjustEnergy(amt: number)
    local newAmt = self.CurrentEnergy + amt
    return newAmt
end

-- function StaffMember

return StaffMember