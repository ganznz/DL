local Job = {}
Job.__index = Job

Job.PaycheckBaseRate = 100
Job.PaycheckMultiplier = 1.2
Job.SkillPointsBaseRate = 4
Job.SkillPointsMultiplier = 1.2
Job.XpPerLevel = 100

function Job.new()
    local newJob = {}
    setmetatable(newJob, Job)

    newJob.Level = 1
    newJob.Exp = 0

    return newJob
end

function Job.CalcPaycheck(jobInstance): number
    return math.floor(Job.PaycheckBaseRate * math.pow(Job.PaycheckMultiplier, jobInstance.Level))
end

function Job.CalcPotentialSkillPoints(jobInstance): number
    return math.floor(Job.SkillPointsBaseRate * math.pow(Job.SkillPointsMultiplier, jobInstance.Level))
end

function Job.CalcLevelUpXpRequirement(jobInstance): number
    return if jobInstance.Level == 1 then Job.XpPerLevel else Job.XpPerLevel * jobInstance.Level
end

function Job.GetLevel(jobInstance): number
    return jobInstance.Level
end

function Job.GetXp(jobInstance): number
    return jobInstance.Exp
end

function Job.GetSkillType(jobInstance): string
    return jobInstance.Skill
end

return Job