local Job = {}
Job.__index = Job

Job.PaycheckBaseRate = 100
Job.PaycheckMultiplier = 1.2
Job.TraitPointsBaseRate = 4
Job.TraitPointsMultiplier = 1.2
Job.XpPerLevel = 100

function Job.new()
    local newJob = {}
    setmetatable(newJob, Job)

    newJob.Level = 1
    newJob.Exp = 0

    return newJob
end

function Job:CalcPaycheck(): number
    return math.floor(Job.PaycheckBaseRate * math.pow(Job.PaycheckMultiplier, self.Level))
end

function Job:CalcTraitPoints(): number
    return math.floor(Job.TraitPointsBaseRate * math.pow(Job.TraitPointsMultiplier, self.Level))
end

function Job:CalcLevelUpXpRequirement(): number
    return if self.Level == 1 then Job.XpPerLevel else Job.XpPerLevel * self.Level
end

function Job:GetLevel(): number
    return self.Level
end

function Job:GetXp(): number
    return self.Exp
end

return Job