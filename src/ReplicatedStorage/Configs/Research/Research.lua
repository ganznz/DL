local AllResearch = require(script.Parent:WaitForChild("AllResearch"))

type ResearchType = "Genre" | "Topic" | "GameSize" | "Technology"

type ResearchConfig = {
    Type: ResearchType,
    Name: string,
    Description: string,
    Currency: string,
    Price: number,
    Requirements: {
        PlrLevel: number,
        Fans: number?,
        Employees: number?,
    },
}

local Config: { string: ResearchConfig } = AllResearch

local Research = {}

Research.Config = Config


-- { [plr level required]: {research name} }
local researchForEachLevel: { [number]: {string} } = {}

for researchName, config: ResearchConfig in Research.Config do
    if not researchForEachLevel[config.Requirements.PlrLevel] then
        researchForEachLevel[config.Requirements.PlrLevel] = {}
    end

    table.insert(researchForEachLevel[config.Requirements.PlrLevel], researchName)
end

Research.ResearchForEachLevel = researchForEachLevel

function Research.GetConfig(researchName: string): ResearchConfig | nil
    return Research.Config[researchName]
end

return Research