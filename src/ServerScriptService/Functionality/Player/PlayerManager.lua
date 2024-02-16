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

function PlrManager.AdjustXP(plr: Player, adjustBy: number)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

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

for _i, plr: Player in Players:GetPlayers() do
    -- check for admin-privilege updates every sec
    if not PlrManager.HasAdminAccess(plr) and PlrManager.IsAdminEligible(plr) then
        PlrManager.GiveAdminAccess(plr)
    end
end

-- toggling plr sprint remotes
Remotes.Player.SprintDisable.OnServerEvent:Connect(function(plr: Player)
    plr:SetAttribute("CanSprint", false)
end)
Remotes.Player.SprintEnable.OnServerEvent:Connect(function(plr: Player)
    plr:SetAttribute("CanSprint", true)
end)

return PlrManager