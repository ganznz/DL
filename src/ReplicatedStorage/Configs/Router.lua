local ReplicatedFirst = game:GetService("ReplicatedFirst")

local Router = {}

export type RouterConfig = {
    Name: string,
    AddOns: number,
    Price: number,
}

local Config: { [number]: RouterConfig } = {
    [1] = {
        Name = "1",
        UploadSpeed = 1,
        Price = 0
    },
    [2]  = {
        Name = "2",
        UploadSpeed = 3,
        Price = 999,
    },
    [3]  = {
        Name = "3",
        UploadSpeed = 5,
        Price = 999,
    },
    [4]  = {
        Name = "4",
        UploadSpeed = 10,
        Price = 999,
    },
    [5]  = {
        Name = "5",
        UploadSpeed = 20,
        Price = 999,
    },
    [6]  = {
        Name = "6",
        UploadSpeed = 40,
        Price = 999,
    },
    [7]  = {
        Name = "7",
        UploadSpeed = 80,
        Price = 999,
    },
}

Router.Config = Config

function Router.GetConfig(itemIndex: number): RouterConfig
    return Router.Config[itemIndex]
end

function Router.GetItemPrice(itemIndex: number): number
    return Router.GetConfig(itemIndex).Price
end

function Router.GetModel(itemIndex: number): Model | nil
    local RoutersFolder = ReplicatedFirst.Assets.Models.Routers
    local model = RoutersFolder:FindFirstChild(tostring(itemIndex)):Clone()
    return model
end

function Router.HasLastItem(plrData): boolean
    return plrData.GameDev.Router == #(Router.Config)
end

function Router.CanUpgrade(plrData): boolean
    local currentRouterLevel = plrData.GameDev.Router
    if Router.HasLastItem(plrData) then return false end

    local nextRouterConfig = Router.GetConfig(currentRouterLevel + 1)
    local plrCash = plrData.Cash
    -- print(plrCash)
    -- print(nextRouterConfig.Price)
    -- print(plrCash >= nextRouterConfig.Price)
    return plrCash >= nextRouterConfig.Price
end

return Router