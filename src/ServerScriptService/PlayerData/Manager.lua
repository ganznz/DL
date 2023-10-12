local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- local PlrDataTemplate = require(ReplicatedStorage.PlayerData.Template)
local JobConfig = require(ReplicatedStorage.Configs.Jobs.Job)

local Remotes = ReplicatedStorage.Remotes

local Manager = {}

Manager.Profiles = {}

function Manager.AdjustPlrCash(plr: Player, adjustBy: number)
    local profile = Manager.Profiles[plr]
    if not profile then return end

    local leaderstats = plr:WaitForChild("leaderstats")
    
    if profile.Data.Cash + adjustBy < 0 then
        profile.Data.Cash = 0
        leaderstats.Cash.Value = 0
    else
        profile.Data.Cash += adjustBy
        leaderstats.Cash.Value += adjustBy
    end

    Remotes.Character.AdjustPlrCash:FireClient(plr, profile.Data.Cash)

    return "Adjusted the players cash by " .. tostring(adjustBy) .. "."
end

function Manager.AdjustPlrHunger(plr: Player, adjustBy: number)
    local profile = Manager.Profiles[plr]
    if not profile then return end

    -- DO CHECK FOR Always Satisfied GAMEPASS!!

    if profile.Data.Character.Needs.Hunger + adjustBy < 0 then
        profile.Data.Character.Needs.Hunger = 0
    elseif profile.Data.Character.Needs.Hunger + adjustBy > profile.Data.Character.Needs.MaxHunger then
        profile.Data.Character.Needs.Hunger = profile.Data.Character.Needs.MaxHunger
    else
        profile.Data.Character.Needs.Hunger += adjustBy
    end

    Remotes.Character.AdjustPlrHunger:FireClient(plr, profile.Data)

    return "Adjusted the players hunger by " .. tostring(adjustBy) .. "."
end

function Manager.AdjustPlrEnergy(plr: Player, adjustBy: number)
    local profile = Manager.Profiles[plr]
    if not profile then return end

    -- DO CHECK FOR Always Satisfied GAMEPASS!!

    if profile.Data.Character.Needs.Energy + adjustBy < 0 then
        profile.Data.Character.Needs.Energy = 0
    elseif profile.Data.Character.Needs.Energy + adjustBy > profile.Data.Character.Needs.MaxEnergy then
        profile.Data.Character.Needs.Energy = profile.Data.Character.Needs.MaxEnergy
    else
        profile.Data.Character.Needs.Energy += adjustBy
    end

    Remotes.Character.AdjustPlrEnergy:FireClient(plr, profile.Data)

    return "Adjusted the players energy by " .. tostring(adjustBy) .. "."
end

function Manager.AdjustPlrJobXp(plr: Player, jobType: string, adjustBy: number): number
    local profile = Manager.Profiles[plr]
    if not profile then return end

    local jobInstance
    local jobName
    if jobType == "cashierJob" then
        jobInstance = profile.Data.Jobs.Cashier.CashierInstance
        jobName = "Cashier"
    end

    local preAdjustLvl = JobConfig.GetLevel(jobInstance)
    local preAdjustmentXp = JobConfig.GetXp(jobInstance) -- 0
    local xpLvlRequirement = JobConfig.CalcLevelUpXpRequirement(jobInstance) -- 100

    -- adjust xp and/or level
    if preAdjustmentXp + adjustBy >= xpLvlRequirement then

        local leftOverXp = preAdjustmentXp + adjustBy - xpLvlRequirement --240
        -- while plr job can continue to level up more than once
        while leftOverXp >= 0 do
            jobInstance.Level += 1
            xpLvlRequirement = JobConfig.CalcLevelUpXpRequirement(jobInstance)
            jobInstance.Exp = leftOverXp
            leftOverXp -= xpLvlRequirement -- 40
        end
    else -- no level up, only xp adjustment
        jobInstance.Exp += adjustBy
    end

    local postAdjustLvl = JobConfig.GetLevel(jobInstance)
    Remotes.Jobs.AdjustJobXp:FireClient(plr, "cashierJob", jobInstance, preAdjustLvl, postAdjustLvl, JobConfig.GetXp(jobInstance))

    return "Adjusted the players " .. jobName .. " job XP by " .. tostring(adjustBy) .. "."
end


local function GetData(plr: Player, directory: string)
    -- ensure function doesn't return a nil value
	-- most importantly for when the function gets invoked upon player joining and player profile data may load slower than the function running
    repeat task.wait() until Manager.Profiles[plr] ~= nil

    local profile = Manager.Profiles[plr]
    return profile.Data[directory]
end

local function GetAllData(plr: Player)
    repeat task.wait() until Manager.Profiles[plr] ~= nil

    local profile = Manager.Profiles[plr]
    return profile.Data
end

Remotes.Data.GetData.OnServerInvoke = GetData
Remotes.Data.GetAllData.OnServerInvoke = GetAllData

return Manager