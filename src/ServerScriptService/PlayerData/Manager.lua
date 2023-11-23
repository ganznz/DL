local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

function Manager.UnlockArea(plr: Player, areaName: string)
    local profile = Manager.Profiles[plr]
    if not profile then return end

    profile.Data.Areas[areaName] = true
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