local ReplicatedFirst = game:GetService("ReplicatedFirst")

local Studio = {}

export type StudioConfig = {
    Name: string,
    Price: number,
    FurnishingCapacity: number,
    NewEmployee: boolean
}

local Config: { [number]: StudioConfig } = {
    [1] = {
        Name = "1",
        Price = 0,
        FurnishingCapacity = 5,
        NewEmployee = false,
    },
    [2]  = {
        Name = "2",
        Price = 50,000,
        FurnishingCapacity = 10,
        NewEmployee = false,
    },
    [3]  = {
        Name = "3",
        Price = 250,000,
        FurnishingCapacity = 15,
        NewEmployee = true,
    },
    [4]  = {
        Name = "4",
        Price = 1,000,000,
        FurnishingCapacity = 20,
        NewEmployee = false,
    }
}

Studio.Config = Config

function Studio.GetConfig(studioIndex: number): StudioConfig
    return Studio.Config[studioIndex]
end

function Studio.GetStudioPrice(studioIndex: number): number
    return Studio.GetConfig(studioIndex).Price
end

function Studio.GetPlrStudioLevel(plrData)
    return #(plrData.Studio.Studios)
end

function Studio.OwnsStudio(plrData, studioIndex: number): boolean
    local numberOfStudiosOwned = #(plrData.Studio.Studios)
    return numberOfStudiosOwned >= studioIndex
end

function Studio.HasLastStudio(plrData): boolean
    return #(plrData.Studio.Studios) == #(Studio.Config)
end

function Studio.CurrentFurnishingAmount(plrData, studioIndex: number): number
    local studioData = plrData.Studio.Studios[studioIndex]
    if not studioData then
        return 0
    else
        return #(studioData.Furnishings)
    end
end

function Studio.FurnishingCapacity(studioIndex: number): number
    local config = Studio.GetConfig(studioIndex)
    return config.FurnishingCapacity
end

function Studio.ReachedFurnishingCapacity(plrData, studioIndex: number): number
    local studioData = plrData.Studio.Studios[studioIndex]
    if not studioData then
        return false
    else
        return Studio.CurrentFurnishingAmount(plrData, studioIndex) >= Studio.FurnishingCapacity(studioIndex)
    end
end

function Studio.CanPurchaseNextStudio(plrData): boolean
    local currentStudioLevel = #(plrData.Studios)
    if Studio.HasLastItem(plrData) then return false end

    local nextStudioConfig = Studio.GetConfig(currentStudioLevel + 1)
    local plrCash = plrData.Cash
    return plrCash >= nextStudioConfig.Price
end


return Studio