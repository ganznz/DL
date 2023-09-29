local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Job = require(ReplicatedStorage.Configs.Jobs:WaitForChild("Job"))

local Cashier = {}
Cashier.__index = Cashier
setmetatable(Cashier, Job)

function Cashier.new()
    local newJob = Job.new()
    setmetatable(newJob, Cashier)

    newJob.Skill = "Focus"
    return newJob
end

function Cashier.CalcActualSkillPoints(jobInstance, shiftDetails): number
    -- MAXPOINTS - (BAD_ORDERS / GOOD_ORDERS)(MAXPOINTS/2)
    local totalOrders = shiftDetails.goodOrders + shiftDetails.badOrders
    local badOrders = shiftDetails.badOrders

    local maxSkillPts = Job.CalcPotentialSkillPoints(jobInstance)
    local actualSkillPts
    if totalOrders == 0 then
        actualSkillPts = 0
    else
        actualSkillPts = math.floor(maxSkillPts - (badOrders / totalOrders) * (maxSkillPts / 2))
    end

    return actualSkillPts
end

return Cashier