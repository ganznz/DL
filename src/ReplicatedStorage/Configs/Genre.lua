local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlrDataTemplate = require(ReplicatedStorage.PlayerData:WaitForChild("Template"))

local Genre = {}

function Genre.new(name)
    local genre = {}
    genre.Name = name
    genre.compatibleWith = {}
    genre.incompatibleWith = {}

    return genre
end

function Genre.CalculateGenreCost(plrData: PlrDataTemplate.PlayerData)
    local amtOfGenres = #plrData.GameDev.Genres
    -- come up with cost formula
end

return Genre