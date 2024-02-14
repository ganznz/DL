local Genre = {}
Genre.__index = Genre

export type GenreConfig = {
    ImageIcon: string,
    ImageSplash: string
}

export type GenreInstance = {
    Name: string,
    Level: number,
    XP: number,
    CompatibleWith: string,
    IncompatibleWith: string
}

local config: { [string]: GenreConfig } = {
    ["Action"] = { ImageIcon = "", ImageSplash = "" },
    ["Casual"] = { ImageIcon = "", ImageSplash = "" },
    ["Strategy"] = { ImageIcon = "", ImageSplash = "" },
    ["Rythm"] = { ImageIcon = "", ImageSplash = "" },
    ["Simulation"] = { ImageIcon = "", ImageSplash = "" },
    ["Adventure"] = { ImageIcon = "", ImageSplash = "" },
    ["Platformer"] = { ImageIcon = "", ImageSplash = "" },
    ["Sports"] = { ImageIcon = "", ImageSplash = "" },
    ["Fighting"] = { ImageIcon = "", ImageSplash = "" },
    ["Roleplay"] = { ImageIcon = "", ImageSplash = "" },
    ["Racing"] = { ImageIcon = "", ImageSplash = "" },
    ["Arcade"] = { ImageIcon = "", ImageSplash = "" },
    ["Roguelite"] = { ImageIcon = "", ImageSplash = "" },
    ["Puzzle"] = { ImageIcon = "", ImageSplash = "" },
    ["Tower Defense"] = { ImageIcon = "", ImageSplash = "" },
}

Genre.Config = config

function Genre.GetAllGenres()
    local allGenres = {}
    for name, _info in Genre.Config do table.insert(allGenres, name) end

    return allGenres
end

function Genre.GetConfig(name: string): GenreConfig | nil
    return Genre.Config[name]
end

function Genre.new(genreName: string, genreData: {}): GenreInstance
    local genreConfig = Genre.GetConfig(genreName)
    if not genreConfig then return nil end

    local newGenre = {}
    setmetatable(newGenre, Genre)

    newGenre.Name = genreName
    newGenre.Level = genreData.Level
    newGenre.XP = genreData.XP
    newGenre.CompatibleWith = genreData.CompatibleWith
    newGenre.IncompatibleWith = genreData.IncompatibleWith

    return newGenre
end

return Genre