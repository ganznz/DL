local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes

local Manager = {}

Manager.Profiles = {}

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