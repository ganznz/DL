local Job = {}
Job.__index = Job

Job.PaycheckBaseRate = 100
Job.PaycheckMultiplier = 1.2
Job.TraitPointsBaseRate = 4
Job.TraitPointsMultiplier = 1.2

function Job.new()
    local newJob = {}
    setmetatable(newJob, Job)

    newJob.Level = 1
    newJob.Exp = 0

    return newJob
end

function Job:CalculatePaycheck(): number
    return math.floor(Job.PaycheckBaseRate * math.pow(Job.PaycheckMultiplier, self.Level))
end

function Job:CalculateTraitPoints(): number
    return math.floor(Job.TraitPointsBaseRate * math.pow(Job.TraitPointsMultiplier, self.Level))
end

return Job