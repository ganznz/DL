local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerConfig = require(ReplicatedStorage.Configs:WaitForChild("Player"))

local Remotes = ReplicatedStorage.Remotes

local Manager = {}

Manager.Profiles = {}

function Manager.AdjustPlrCoins(plr: Player, adjustBy: number)
    local profile = Manager.Profiles[plr]
    if not profile then return end

    local leaderstats = plr:WaitForChild("leaderstats")
    
    if profile.Data.Coins + adjustBy < 0 then
        profile.Data.Coins = 0
    else
        profile.Data.Coins += adjustBy
    end
    leaderstats.Coins.Value = profile.Data.Coins

    Remotes.Character.AdjustPlrCoins:FireClient(plr, profile.Data.Coins)

    return "Adjusted the players coins by " .. tostring(adjustBy) .. "."
end

function Manager.AdjustPlrEnergy(plr: Player, adjustBy: number)
    local profile = Manager.Profiles[plr]
    if not profile then return end

    local maxEnergy = PlayerConfig.CalcMaxNeed(profile.Data)

    if profile.Data.Character.Needs.CurrentEnergy + adjustBy < 0 then
        profile.Data.Character.Needs.CurrentEnergy = 0
    elseif profile.Data.Character.Needs.CurrentEnergy + adjustBy > maxEnergy then
        profile.Data.Character.Needs.CurrentEnergy = maxEnergy
    else
        profile.Data.Character.Needs.CurrentEnergy += adjustBy
    end

    Remotes.Character.AdjustPlrEnergy:FireClient(plr, profile.Data.Character)

    return "Adjusted the players energy by " .. tostring(adjustBy) .. "."
end

function Manager.AdjustPlrHunger(plr: Player, adjustBy: number)
    local profile = Manager.Profiles[plr]
    if not profile then return end

    local maxHunger = PlayerConfig.CalcMaxNeed(profile.Data)

    if profile.Data.Character.Needs.CurrentHunger + adjustBy < 0 then
        profile.Data.Character.Needs.CurrentHunger = 0
    elseif profile.Data.Character.Needs.CurrentHunger + adjustBy > maxHunger then
        profile.Data.Character.Needs.CurrentHunger = maxHunger
    else
        profile.Data.Character.Needs.CurrentHunger += adjustBy
    end

    Remotes.Character.AdjustPlrHunger:FireClient(plr, profile.Data.Character)

    return "Adjusted the players hunger by " .. tostring(adjustBy) .. "."
end

function Manager.AdjustPlrMood(plr: Player, adjustBy: number)
    local profile = Manager.Profiles[plr]
    if not profile then return end

    local maxMood = PlayerConfig.CalcMaxNeed(profile.Data)

    if profile.Data.Character.Needs.CurrentMood + adjustBy < 0 then
        profile.Data.Character.Needs.CurrentMood = 0
    elseif profile.Data.Character.Needs.CurrentMood + adjustBy > maxMood then
        profile.Data.Character.Needs.CurrentMood = maxMood
    else
        profile.Data.Character.Needs.CurrentMood += adjustBy
    end

    Remotes.Character.AdjustPlrMood:FireClient(plr, profile.Data.Character)

    return "Adjusted the players mood by " .. tostring(adjustBy) .. "."
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

-- plrToAdjust parameter for cases when caller wants to retrieve data of another plr
local function GetAllData(plr: Player, plrToFetch: Player)
    if plrToFetch then
        repeat task.wait() until Manager.Profiles[plrToFetch] ~= nil
    else
        repeat task.wait() until Manager.Profiles[plr] ~= nil
    end

    local profile = Manager.Profiles[plrToFetch and plrToFetch or plr]
    return profile.Data
end

Remotes.Data.GetData.OnServerInvoke = GetData
Remotes.Data.GetAllData.OnServerInvoke = GetAllData

return Manager