local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local Zone = require(ReplicatedStorage.Libs.Zone)
local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local Template = require(ReplicatedStorage.PlayerData.Template)
local ComputerConfig = require(ReplicatedStorage.Configs.Computer)
local RouterConfig = require(ReplicatedStorage.Configs.Router)

local Remotes = ReplicatedStorage.Remotes

local techStoreFolder = Workspace.Map.Buildings.TechStore
local teleportHitbox: Model = techStoreFolder:FindFirstChild("TeleportHitboxZone", true)
local zone = Zone.new(teleportHitbox)

local function generateProximityPrompt(parentPart: BasePart, itemType: string): ProximityPrompt
    local proxPromptOffset = 1 -- Y axis height offset
    local parentHeight = parentPart.Size.Y

    local attachment: Attachment = Instance.new("Attachment", parentPart)
    attachment.Name = "ProximityPromptAttachment"
    attachment.CFrame = CFrame.new(0, (parentHeight / 2) + proxPromptOffset, 0)

    local proxPrompt: ProximityPrompt = Instance.new("ProximityPrompt", attachment)
    proxPrompt.RequiresLineOfSight = false
    proxPrompt.ActionText = "Purchase"

    return proxPrompt
end

local function populateArea(itemType: "computers" | "routers")
    local proxPrompts = {} -- prox prompts in each displayed model

    local queryField
    if itemType == "computers" then
        queryField = "Computers"
    elseif itemType == "routers" then
        queryField = "Routers"
    end

    local placementPartsFolder = techStoreFolder.TechStoreInterior.PurchasableItems[queryField].PlacementParts
    local modelDestinationFolder = techStoreFolder.TechStoreInterior.PurchasableItems[queryField].Models
    local modelsFolder = ReplicatedFirst.Assets.Models[queryField]
    for _i, v in placementPartsFolder:GetChildren() do
        local itemNo = v.Name
        local pcModel: Model = modelsFolder:FindFirstChild(itemNo):Clone()
        local primaryPartHeight = pcModel.PrimaryPart.Size.Y

        pcModel:PivotTo(v.CFrame * CFrame.new(0, primaryPartHeight / 2, 0)) -- guarantees Y alignment
        pcModel.Parent = modelDestinationFolder
        
        local proxPrompt = generateProximityPrompt(pcModel.PrimaryPart)
        table.insert(proxPrompts, proxPrompt)
    end

    for _i, proxPrompt in proxPrompts do
        proxPrompt.Triggered:Connect(function(plr: Player)
            -- open UI
            Remotes.GUI.ChangeGuiStatusRemote:FireClient(plr, "techStoreItemShop", true, {itemsToDisplay = queryField})
        end)
    end
end
populateArea("computers")
populateArea("routers")

zone.playerEntered:Connect(function(plr: Player)
    local teleportToPart = techStoreFolder.TechStoreInterior:FindFirstChild("TeleportToPart")
    Remotes.GUI.ChangeGuiStatusRemote:FireClient(plr, "loadingBgSplash", true, { TeleportPart = teleportToPart })
end)

Remotes.Purchase.PurchaseComputer.OnServerEvent:Connect(function(plr: Player, itemIndex: number)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local plrData: Template.PlayerData = profile.Data

    local itemConfig: ComputerConfig.ComputerConfig = ComputerConfig.GetConfig(itemIndex)

    if not itemConfig then return "Item doesn't exist." end
    if plrData.GameDev.Computer + 1 ~= itemIndex then return "Buy previous computer first." end
    local itemPrice = ComputerConfig.GetItemPrice(itemIndex)
    if plrData.Cash < itemPrice then return "You need " .. tostring(itemPrice - plrData.Cash) .. " more cash!" end

    PlrDataManager.AdjustPlrCash(plr, -itemPrice)
    profile.Data.GameDev.Computer = itemIndex
    Remotes.Purchase.PurchaseComputer:FireClient(plr, itemIndex)
    return "Purchased " .. itemConfig.Name .. "!"
end)

Remotes.Purchase.PurchaseRouter.OnServerEvent:Connect(function(plr: Player, itemIndex: number)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local plrData: Template.PlayerData = profile.Data

    local itemConfig: RouterConfig.RouterConfig = RouterConfig.GetConfig(itemIndex)
    
    if not itemConfig then return "Item doesn't exist." end
    if plrData.GameDev.Router + 1 ~= itemIndex then return "Buy previous router first." end
    local itemPrice = RouterConfig.GetItemPrice(itemIndex)
    if plrData.Cash < itemPrice then return "You need " .. tostring(itemPrice - plrData.Cash) .. " more cash!" end

    PlrDataManager.AdjustPlrCash(plr, -itemPrice)
    profile.Data.GameDev.Router = itemIndex
    Remotes.Purchase.PurchaseRouter:FireClient(plr, itemIndex)
    return "Purchased " .. itemConfig.Name .. "!"
end)