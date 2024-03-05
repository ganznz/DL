local MarketplaceService = game:GetService("MarketplaceService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local GeneralUtils = require(ReplicatedStorage.Utils.GeneralUtils)
local CameraControls = require(ReplicatedStorage.Utils.Camera.CameraControls)
local PlayerUtils = require(ReplicatedStorage.Utils.Player.Player)
local GuiServices = require(ReplicatedStorage.Utils.Gui.GuiServices)
local GuiTemplates = require(ReplicatedStorage.Utils.Gui.GuiTemplates)
local StudioConfig = require(ReplicatedStorage.Configs.Studio.Studio)

local Remotes = ReplicatedStorage.Remotes

local localPlr = Players.LocalPlayer
local camera = Workspace:FindFirstChild("Camera")
local PlayerGui = localPlr.PlayerGui

-- GUI VARIABLES --
local AllGuiScreenGui = PlayerGui:WaitForChild("AllGui")
local StudioStoreContainer: Frame = AllGuiScreenGui.Studio:WaitForChild("StudioStoreContainer")
local StudioStoreContainerInner: Frame = StudioStoreContainer.StudioStoreContainerInner
-- -- buy btn
local BuyBtn: TextButton = StudioStoreContainer.BuyBtn
local BuyBtnCurrencyImage: ImageLabel = BuyBtn.CurrencyImage
local BuyBtnCurrencyImageDropshadow: ImageLabel = BuyBtnCurrencyImage.CurrencyImageDropshadow
local BuyBtnCostText: TextLabel = BuyBtn.CostText
-- -- studio name
local StudioNameContainer: Frame = StudioStoreContainer.StudioNameContainer
local StudioNameText: TextLabel = StudioNameContainer.StudioName
-- -- main container content
local GridSizeText: TextLabel = StudioStoreContainerInner.BuildGridSize.TextLabel
local BuyPrevStudioText: TextLabel = StudioStoreContainerInner.BuyPreviousStudio

-- STATIC VARIABLES --
local GRID_SIZE_TEXT = "X x Z"

-- STATE VARIABLES --
local plrData = nil
local plrHighestStudioIndex: string = nil -- only taking into account Standard studios, not Premium studios

local studioInteriorFolders = ReplicatedStorage.Assets.Models.Studio.Studios

local cameraLookAtCFrames = {}
local studioPlotSizes = {}
for _i, exteriorFolder: Folder in CollectionService:GetTagged("Studio") do
    local lookAtPart: Part = exteriorFolder:WaitForChild("InteriorTeleportPart")
    if not lookAtPart then continue end

    local studioInteriorModel: Model = studioInteriorFolders[exteriorFolder.Name]:WaitForChild("Interior")
    if not studioInteriorModel then continue end
    local studioInteriorPlot = studioInteriorModel:FindFirstChild("Plot")

    cameraLookAtCFrames[exteriorFolder.Name] = lookAtPart.CFrame
    studioPlotSizes[exteriorFolder.Name] = studioInteriorPlot.Size
end

-- FUNCTIONS --

-- local BuyBtn: TextButton = StudioStoreContainer.BuyBtn
-- local BuyBtnCurrencyImage: ImageLabel = BuyBtn.CurrencyImage
-- local BuyBtnCurrencyImageDropshadow: ImageLabel = BuyBtnCurrencyImage.CurrencyImageDropshadow
-- local BuyBtnCostText: TextLabel = BuyBtn.CostText
-- -- -- main container content
-- local GridSizeText: TextLabel = StudioStoreContainerInner.BuildGridSize.TextLabel
-- local BuyPrevStudioText: TextLabel = StudioStoreContainerInner.BuyPreviousStudio
local function populateStudioStoreGui(studioIndex: string)
    local studioConfig: StudioConfig.StudioConfig = StudioConfig.GetConfig(studioIndex)
    local studioType = studioConfig.StudioType

    local plrStudiosData = plrData.Studio.Studios
    local plrOwnsStudio: boolean = if plrStudiosData[studioType][studioIndex] then true else false
    local plrOwnsPreviousStudio: boolean = 

    -- general studio info
    StudioNameText.Text = studioConfig.Name
    local studioGridSizeInfo = studioPlotSizes[studioIndex]
    GridSizeText.Text = GRID_SIZE_TEXT:gsub("X", studioGridSizeInfo.X):gsub("Z", studioGridSizeInfo.Z)

    -- style buy btn
    local styleBuyBtn
end

local function setupStudioStore()
    local plrStudioData = plrData.Studio.Studios
    -- get highest plr studio level/index, this is what will be viewed first in GUI

    populateStudioStoreGui(plrHighestStudioIndex)
    GuiServices.TriggerFlashFrame()

end

Remotes.Studio.General.ViewStudioStore.OnClientEvent:Connect(function(playerData: {})
    plrData = playerData
    plrHighestStudioIndex = tostring(StudioConfig.GetPlrStudioLevel(plrData))

    setupStudioStore()
end)