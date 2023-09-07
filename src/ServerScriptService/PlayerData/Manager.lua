local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- local PlrDataTemplate = require(ReplicatedStorage.PlayerData.Template)

local Remotes = ReplicatedStorage.Remotes

local Manager = {}

Manager.Profiles = {}

function Manager.AdjustPlrHunger(plr: Player, adjustBy: number)
    local profile = Manager.Profiles[plr]
    if not profile then return end

    -- DO CHECK FOR Always Satisfied GAMEPASS!!

    if profile.Data.CharacterNeeds.Hunger + adjustBy < 0 then
        profile.Data.CharacterNeeds.Hunger = 0
    else
        profile.Data.CharacterNeeds.Hunger += adjustBy
    end

    Remotes.Character.AdjustPlrHunger:FireClient(plr, profile.Data.CharacterNeeds.Hunger)
end

function Manager.AdjustPlrEnergy(plr: Player, adjustBy: number)
    local profile = Manager.Profiles[plr]
    if not profile then return end

    -- DO CHECK FOR Always Satisfied GAMEPASS!!

    if profile.Data.CharacterNeeds.Energy + adjustBy < 0 then
        profile.Data.CharacterNeeds.Energy = 0
    else
        profile.Data.CharacterNeeds.Energy += adjustBy
    end

    Remotes.Character.AdjustPlrEnergy:FireClient(plr, profile.Data.CharacterNeeds.Energy)
end


local function GetData(plr: Player, directory: string)
    -- ensure function doesn't return a nil value
	-- most importantly for when the function gets invoked upon player joining and player profile data may load slower than the function running
    repeat task.wait() until Manager.Profiles[plr] ~= nil

    local profile = Manager.Profiles[plr]
    return profile.Data[directory]
end

local function GetAllData(plr: Player, directory: string)
    repeat task.wait() until Manager.Profiles[plr] ~= nil

    local profile = Manager.Profiles[plr]
    return profile.Data
end

Remotes.Data.GetData.OnServerInvoke = GetData
Remotes.Data.GetAllData.OnServerInvoke = GetAllData

return Manager