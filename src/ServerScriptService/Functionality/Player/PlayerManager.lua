local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local PlayerConfig = require(ReplicatedStorage.Configs.Player)
local StaffFoodConfigServer = require(ServerScriptService.Functionality.Staff.StaffFoodConfigServer)

local Remotes = ReplicatedStorage.Remotes

local GROUP_ID = 33054213
local GROUP_ADMIN_RANK_IDS = {255, 254} -- 255: Owner, 254: Devs
local EXTRA_ADMINS = {} -- any player you want to give admin access to that isn't a dev, put their user ID in here

local PlrManager = {}

-- when players level up, level up information is stored here to display, whether that's at the time of level up or not (depending on level-up context)
-- PreAdjustmentLevel -> number: The level of a plr before they xp-adjustment in one context (e.g. after developing a game)
-- PostAdjustmentLevel -> number: The level a player after they levelled up in one context (usually just 1 level increase, but can be more)
PlrManager.PlrLevelUps = {
    --[[ [Player.UserId] = {
        PreAdjustmentLevel: number,
        PostAdjustmentLevel: number,
        PreAdjustmentXP: number,
        PostAdjustmentXP: number,
        PreAdjustmentMaxXP: number
        PostAdjustmentMaxXP: number
    } | false
    ]]
}

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

function PlrManager.AdjustPlrGems(plr: Player, adjustBy: number)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local leaderstats = plr:WaitForChild("leaderstats")
    
    if profile.Data.Gems + adjustBy < 0 then
        profile.Data.Gems = 0
    else
        profile.Data.Gems += adjustBy
    end
    leaderstats.Gems.Value = profile.Data.Gems

    Remotes.Character.AdjustPlrGems:FireClient(plr, profile.Data.Gems)

    return "Adjusted the players gems by " .. tostring(adjustBy) .. "."
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

local function givePlrLevelUpRewards(plr: Player, level: number)
    local levelInfo: PlayerConfig.LevelUpInformation = PlayerConfig.LevelUpInformation[tostring(level)]
    if not levelInfo then return end
    if not levelInfo["Rewards"] then return end

    if levelInfo.Rewards["Currencies"] then
        for currencyName: string, amt: number in levelInfo.Rewards["Currencies"] do
            if currencyName == "Coins" then PlrManager.AdjustPlrCoins(plr, amt) end
            if currencyName == "Gems" then PlrManager.AdjustPlrGems(plr, amt) end
        end
    end

    if levelInfo.Rewards["OtherRewards"] then
        for itemName: string, itemInfo: {} in levelInfo.Rewards["OtherRewards"] do
            if itemInfo.Type == "Staff Food" then
                StaffFoodConfigServer.GiveFood(plr, itemName, itemInfo.Amount)
            end
        end
    end
end

-- args     
-- instrusiveLevelUp -> boolean: Indicates whether level up GUI should appear right after PlayerLevelUp remote is fired or not
function PlrManager.AdjustXP(plr: Player, adjustBy: number, intrusiveLevelUp: boolean)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    -- if argument is not passed, make levelup GUI instrusive by default
    intrusiveLevelUp = if intrusiveLevelUp == nil then true else intrusiveLevelUp

    -- holds the plr character data
    local plrCharData = profile.Data.Character

    local preAdjustmentLevel = plrCharData.Level
    local preAdjustmentXp = plrCharData.Exp
    local xpLvlRequirement: number = PlayerConfig.CalcLevelUpXpRequirement(profile.Data)
    local preAdjustmentMaxXp = xpLvlRequirement

    -- plr has earned enough XP to level up at least once
    if preAdjustmentXp + adjustBy >= xpLvlRequirement then
        PlrManager.PlrLevelUps[plr.UserId] = {}
        PlrManager.PlrLevelUps[plr.UserId]["PreAdjustmentLevel"] = preAdjustmentLevel
        PlrManager.PlrLevelUps[plr.UserId]["PreAdjustmentXP"] = preAdjustmentXp
        PlrManager.PlrLevelUps[plr.UserId]["PreAdjustmentMaxXP"] = preAdjustmentMaxXp

        local leftOverXp = preAdjustmentXp + adjustBy - xpLvlRequirement
        -- while plr can continue to level up more than once
        while leftOverXp >= 0 do
            profile.Data.Character.Level += 1
            xpLvlRequirement = PlayerConfig.CalcLevelUpXpRequirement(profile.Data)
            profile.Data.Character.Exp = leftOverXp
            leftOverXp -= xpLvlRequirement

            local newPlrLevel = profile.Data.Character.Level
            PlrManager.PlrLevelUps[plr.UserId]["PostAdjustmentLevel"] = newPlrLevel
            PlrManager.PlrLevelUps[plr.UserId]["PostAdjustmentXP"] = profile.Data.Character.Exp
            PlrManager.PlrLevelUps[plr.UserId]["PostAdjustmentMaxXP"] = xpLvlRequirement
            
            -- refresh plr mood, hunger & energy levels so they're full again after level up
            PlrManager.AdjustPlrMood(plr, 0, { MaxNeed = true })
            PlrManager.AdjustPlrHunger(plr, 0, { MaxNeed = true })
            PlrManager.AdjustPlrEnergy(plr, 0, { MaxNeed = true })
        end

        -- give rewards to plr
        for i = PlrManager.PlrLevelUps[plr.UserId].PreAdjustmentLevel + 1, PlrManager.PlrLevelUps[plr.UserId].PostAdjustmentLevel, 1 do
            givePlrLevelUpRewards(plr, i)
        end

        if intrusiveLevelUp then Remotes.Character.PlayerLevelUp:FireClient(plr, PlrManager.PlrLevelUps[plr.UserId]) end
    
    -- no level up, only xp adjustment
    else
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
    PlrManager.PlrLevelUps[plr.UserId] = false

    if PlrManager.IsAdminEligible(plr) then
        PlrManager.GiveAdminAccess(plr)
    end
end)

Players.PlayerRemoving:Connect(function(plr: Player)
    PlrManager.PlrLevelUps[plr.UserId] = nil
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

-- remote connection from client only occurs when a player levelling up is non-intrusive
-- meaning their level up information gets displayed soon after actual time of level-up, not AT time of level up
Remotes.Character.PlayerLevelUp.OnServerEvent:Connect(function(plr: Player)
    if not PlrManager.PlrLevelUps[plr.UserId] then return end

    -- display plr level up GUI
    Remotes.Character.PlayerLevelUp:FireClient(plr, PlrManager.PlrLevelUps[plr.UserId])

    PlrManager.PlrLevelUps[plr.UserId] = false

end)

return PlrManager