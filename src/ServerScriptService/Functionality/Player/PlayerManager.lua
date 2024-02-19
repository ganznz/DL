local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local PlayerConfig = require(ReplicatedStorage.Configs.Player)

local Remotes = ReplicatedStorage.Remotes

local GROUP_ID = 33054213
local GROUP_ADMIN_RANK_IDS = {255, 254} -- 255: Owner, 254: Devs
local EXTRA_ADMINS = {} -- any player you want to give admin access to that isn't a dev, put their user ID in here

local PlrManager = {}

function PlrManager.AdjustPlrCoins(plr: Player, adjustBy: number)
    local profile = PlrDataManager.Profiles[plr]
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

-- opts     
-- MaxNeed -> boolean: When specified, will set the players Energy need to full, regardless of what the adjustBy parameter is
function PlrManager.AdjustPlrEnergy(plr: Player, adjustBy: number, opts: { MaxNeed: boolean })
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    opts = opts or {}

    local maxEnergy = PlayerConfig.CalcMaxNeed(profile.Data)

    if opts["MaxNeed"] then
        profile.Data.Character.Needs.CurrentEnergy = maxEnergy
    
    elseif profile.Data.Character.Needs.CurrentEnergy + adjustBy < 0 then
        profile.Data.Character.Needs.CurrentEnergy = 0

    elseif profile.Data.Character.Needs.CurrentEnergy + adjustBy > maxEnergy then
        profile.Data.Character.Needs.CurrentEnergy = maxEnergy

    else
        profile.Data.Character.Needs.CurrentEnergy += adjustBy
    end

    Remotes.Character.AdjustPlrEnergy:FireClient(plr, profile.Data.Character)

    return "Adjusted the players energy by " .. tostring(adjustBy) .. "."
end

-- opts     
-- MaxNeed -> boolean: When specified, will set the players Hunger need to full, regardless of what the adjustBy parameter is
function PlrManager.AdjustPlrHunger(plr: Player, adjustBy: number, opts: { MaxNeed: boolean })
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    opts = opts or {}

    local maxHunger = PlayerConfig.CalcMaxNeed(profile.Data)

    if opts["MaxNeed"] then
        profile.Data.Character.Needs.CurrentHunger = maxHunger
    
    elseif profile.Data.Character.Needs.CurrentHunger + adjustBy < 0 then
        profile.Data.Character.Needs.CurrentHunger = 0

    elseif profile.Data.Character.Needs.CurrentHunger + adjustBy > maxHunger then
        profile.Data.Character.Needs.CurrentHunger = maxHunger

    else
        profile.Data.Character.Needs.CurrentHunger += adjustBy
    end

    Remotes.Character.AdjustPlrHunger:FireClient(plr, profile.Data.Character)

    return "Adjusted the players hunger by " .. tostring(adjustBy) .. "."
end

-- opts     
-- MaxNeed -> boolean: When specified, will set the players Mood need to full, regardless of what the adjustBy parameter is
function PlrManager.AdjustPlrMood(plr: Player, adjustBy: number, opts: { MaxNeed: boolean })
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    opts = opts or {}

    local maxMood = PlayerConfig.CalcMaxNeed(profile.Data)

    if opts["MaxNeed"] then
        profile.Data.Character.Needs.CurrentMood = maxMood
    
    elseif profile.Data.Character.Needs.CurrentMood + adjustBy < 0 then
        profile.Data.Character.Needs.CurrentMood = 0

    elseif profile.Data.Character.Needs.CurrentMood + adjustBy > maxMood then
        profile.Data.Character.Needs.CurrentMood = maxMood

    else
        profile.Data.Character.Needs.CurrentMood += adjustBy
    end

    Remotes.Character.AdjustPlrMood:FireClient(plr, profile.Data.Character)

    return "Adjusted the players mood by " .. tostring(adjustBy) .. "."
end

function PlrManager.UnlockArea(plr: Player, areaName: string)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    profile.Data.Areas[areaName] = true
end

function PlrManager.HasAdminAccess(plr: Player)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    return profile.Data.Admin
end

function PlrManager.GiveAdminAccess(plr: Player)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    profile.Data.Admin = true
end

function PlrManager.IsAdminEligible(plr: Player): boolean
    -- plr has role in group w/ admin powers
    if table.find(GROUP_ADMIN_RANK_IDS, plr:GetRankInGroup(GROUP_ID)) then return true end

    -- plr is an extra admin that isn't a dev/admin in group
    if table.find(EXTRA_ADMINS, plr.UserId) then return true end

    return false
end

-- args     
-- instrusiveLevelUp -> boolean: Indicates whether level up GUI should appear right after PlayerLevelUp remote is fired or not
function PlrManager.AdjustXP(plr: Player, adjustBy: number, intrusiveLevelUp: boolean)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    -- if argument is not passed, make levelup GUI instrusive by default
    intrusiveLevelUp = intrusiveLevelUp or true

    -- holds the plr character data
    local plrCharData = profile.Data.Character

    local preAdjustmentLevel = plrCharData.Level
    local preAdjustmentXp = plrCharData.Exp
    local xpLvlRequirement: number = PlayerConfig.CalcLevelUpXpRequirement(profile.Data)
    local preAdjustmentMaxXp = xpLvlRequirement

    -- adjust xp and/or level
    if preAdjustmentXp + adjustBy >= xpLvlRequirement then

        local leftOverXp = preAdjustmentXp + adjustBy - xpLvlRequirement
        -- while plr can continue to level up more than once
        while leftOverXp >= 0 do
            profile.Data.Character.Level += 1
            xpLvlRequirement = PlayerConfig.CalcLevelUpXpRequirement(profile.Data)
            profile.Data.Character.Exp = leftOverXp
            leftOverXp -= xpLvlRequirement

            local newPlrLevel = profile.Data.Character.Level
            Remotes.Character.PlayerLevelUp:FireClient(plr, newPlrLevel, intrusiveLevelUp)
            
            -- refresh plr mood, hunger & energy levels so they're full again after level up
            PlrManager.AdjustPlrMood(plr, 0, { MaxNeed = true })
            PlrManager.AdjustPlrHunger(plr, 0, { MaxNeed = true })
            PlrManager.AdjustPlrEnergy(plr, 0, { MaxNeed = true })
        end
    else -- no level up, only xp adjustment
        profile.Data.Character.Exp += adjustBy
    end

    Remotes.Character.AdjustPlrXP:FireClient(plr, plrCharData, {
        PreAdjustmentLevel = preAdjustmentLevel,
        PreAdjustmentXP = preAdjustmentXp,
        PreAdjustmentMaxXP = preAdjustmentMaxXp,
        PostAdjustmentLevel = plrCharData.Level,
        PostAdjustmentXP = plrCharData.Exp,
        PostAdjustmentMaxXP = PlayerConfig.CalcLevelUpXpRequirement(profile.Data)
    })
end

Players.PlayerAdded:Connect(function(plr: Player)
    if PlrManager.IsAdminEligible(plr) then
        PlrManager.GiveAdminAccess(plr)
    end
end)


-- attributes that are commonly used globally in scripts are declared here
local function characterAdded(char: Model, plr: Player)
    plr:SetAttribute("IsAlive", true)
    plr:SetAttribute("CanSprint", true)
    plr:SetAttribute("InStudio", false)
    plr:SetAttribute("InBuildMode", false)
    plr:SetAttribute("InPlaceMode", false)
    plr:SetAttribute("CurrentlyDevelopingGame", false)

    local humanoid = char:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        plr:SetAttribute("IsAlive", false)
        plr:SetAttribute("CanSprint", false)
    end)
end

Players.PlayerAdded:Connect(function(plr: Player)
    local char = plr.Character or plr.CharacterAdded:Wait()
    characterAdded(char, plr)

    plr.CharacterAdded:Connect(function(newChar: Model)
        characterAdded(newChar, plr)
    end)
end)

task.spawn(function()
    for _i, plr: Player in Players:GetPlayers() do
        -- check for admin-privilege updates every 10 seconds
        if not PlrManager.HasAdminAccess(plr) and PlrManager.IsAdminEligible(plr) then
            PlrManager.GiveAdminAccess(plr)
        end
    end
    
    task.wait(10)
end)

-- toggling plr sprint remotes
Remotes.Player.SprintDisable.OnServerEvent:Connect(function(plr: Player)
    plr:SetAttribute("CanSprint", false)
end)
Remotes.Player.SprintEnable.OnServerEvent:Connect(function(plr: Player)
    plr:SetAttribute("CanSprint", true)
end)

return PlrManager