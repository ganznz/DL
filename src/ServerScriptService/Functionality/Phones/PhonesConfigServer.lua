local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local PhonesConfig = require(ReplicatedStorage.Configs.Phones:WaitForChild("Phones"))

local Phones = {}

function Phones.GetReward(plr: Player, phoneName: string): {}
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local MIN_RANGE = 0
    local MAX_RANGE = 100

    -- check if plr has luck gamepasses

    local chanceTable = PhonesConfig.GetChanceTable(phoneName)
    if not chanceTable then return end

    local random = Random.new()
    local randomNum = random:NextNumber(MIN_RANGE, MAX_RANGE)
    local reward

    for itemName, itemInfo in chanceTable do
        local itemBounds = itemInfo.Bounds
        if randomNum >= itemBounds[1] and randomNum <= itemBounds[2] then
            reward = {itemInfo.UnlockableType, itemName}
            break
        end
    end

    return reward
end

return Phones