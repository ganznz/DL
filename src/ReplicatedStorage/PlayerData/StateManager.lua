local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlrDataTemplate = require(ReplicatedStorage.PlayerData.Template)

local Remotes = ReplicatedStorage.Remotes

local isDataLoaded = false

local plrData: PlrDataTemplate.PlayerData

local function loadData()
    if isDataLoaded then return end

    while not plrData do
        plrData = Remotes.Data.GetAllData:InvokeServer()
        task.wait(1)
    end

    isDataLoaded = true
end

loadData()

local StateManager = {}

function StateManager.GetData(): PlrDataTemplate.PlayerData
    while not isDataLoaded do task.wait(0.5) end

    return plrData
end

return StateManager