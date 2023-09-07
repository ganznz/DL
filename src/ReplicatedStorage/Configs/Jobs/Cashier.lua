local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Job = require(ReplicatedStorage.Configs.Jobs:WaitForChild("Job"))

local Cashier = {}
Cashier.__index = Cashier
setmetatable(Cashier, Job)

function Cashier.new()
    local newJob = Job.new()
    setmetatable(newJob, Cashier)

    newJob.Trait = "Focus"
end

return Cashier