local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local PhonesConfig = require(ReplicatedStorage.Configs.Phones.Phones)
local PhonesServerConfig = require(ServerScriptService.Functionality.Phones.PhonesConfigServer)
local StaffConfigServer = require(ServerScriptService.Functionality.Staff.StaffConfigServer)
local StaffFoodConfigServer = require(ServerScriptService.Functionality.Staff.StaffFoodConfigServer)
local MaterialsConfigServer = require(ServerScriptService.Functionality.Materials.MaterialsConfigServer)

local Remotes = ReplicatedStorage.Remotes

-- STATE VARIABLES --
-- { [plr.UserId] = { PhoneName: string, ClicksPerformed: number } | false }
local plrHatchingInfo = {} -- tracks how many clicks a player has performed while clicking a phone to open it
local clickCooldown = {} -- tracks which players are on cooldown after clicking to open a phone. Holds user ID's

-- CONSTANT VARIABLES --
local CLICKS_TO_OPEN = 4
local CLICK_COOLDOWN = 0.3

local function inCooldownTable(plr: Player)
    local index = table.find(clickCooldown, plr.UserId)
    if index then return true else return false end
end

local function removeFromClickCooldownTable(plr: Player)
    local index = table.find(clickCooldown, plr.UserId)
    if index then table.remove(clickCooldown, index) end
end

local function addToClickCooldownTable(plr: Player)
    table.insert(clickCooldown, plr.UserId)
    task.delay(CLICK_COOLDOWN, function()
        removeFromClickCooldownTable(plr)
    end)
end

local function purchasePhone(plr: Player, phoneName: string)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local phoneConfig: PhonesConfig.PhoneConfig = PhonesConfig.GetConfig(phoneName)
    if not phoneConfig then return end

    local phoneCurrency = phoneConfig.Currency
    local canAfford = profile.Data[phoneCurrency] - phoneConfig.Price >= 0
    if not canAfford then return end

    -- CAN BUY PHONE
    profile.Data[phoneCurrency] -= phoneConfig.Price
    plrHatchingInfo[plr.UserId] = { PhoneName = phoneName, ClicksPerformed = 0 }

    -- display phone for opening
    Remotes.Phones.PurchasePhone:FireClient(plr, phoneName)
end

local function giveReward(plr: Player)
    local rewardInfo = PhonesServerConfig.GetRewardInfo(plr, plrHatchingInfo[plr.UserId].PhoneName)
    local rewardCategory = rewardInfo[1] -- e.g. staff, staff food, materials
    local rewardName = rewardInfo[2]

    if rewardCategory == "Staff" then
        StaffConfigServer.GiveStaffMember(plr, rewardName)
    elseif rewardCategory == "Staff Food" then
        StaffFoodConfigServer.GiveFood(plr, rewardName)
    elseif rewardCategory == "Materials" then
        MaterialsConfigServer.GiveMaterial(plr, rewardName)
    end

    local rarestItemInPhone: string = PhonesConfig.GetRarestItem(plrHatchingInfo[plr.UserId].PhoneName)
    local isRarestItem: boolean = rarestItemInPhone == rewardName

    plrHatchingInfo[plr.UserId] = false

    Remotes.Phones.OpenPhone:FireClient(plr, rewardInfo, isRarestItem)
end

-- REMOTES --
Remotes.Phones.PurchasePhone.OnServerEvent:Connect(purchasePhone)

Remotes.Phones.PerformOpenClick.OnServerEvent:Connect(function(plr: Player)
    if plrHatchingInfo[plr.UserId] then
        if inCooldownTable(plr) then return end
        
        addToClickCooldownTable(plr)
        plrHatchingInfo[plr.UserId].ClicksPerformed += 1

        -- open phone, give reward
        if plrHatchingInfo[plr.UserId].ClicksPerformed >= CLICKS_TO_OPEN then giveReward(plr) end
    end
end)

Players.PlayerAdded:Connect(function(plr: Player)
    plrHatchingInfo[plr.UserId] = false
end)

Players.PlayerRemoving:Connect(function(plr: Player)
    plrHatchingInfo[plr.UserId] = nil
end)
