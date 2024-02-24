local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GlobalVariables = require(ReplicatedStorage.GlobalVariables)
local GeneralUtils = require(ReplicatedStorage.Utils.GeneralUtils)
local GuiServices = require(ReplicatedStorage.Utils.Gui.GuiServices)
local GuiTemplates = require(ReplicatedStorage.Utils.Gui.GuiTemplates)
local PlayerConfig = require(ReplicatedStorage.Configs.Player)

local Remotes = ReplicatedStorage.Remotes

local localPlr = Players.LocalPlayer

local PlayerGui = localPlr.PlayerGui

-- GUI REFERENCE VARIABLES --
local AllGuiScreenGui = PlayerGui:WaitForChild("AllGui")
-- COMPUTER UPGRADE GUI
-- -- general
local LevelUpContainer: Frame = AllGuiScreenGui.Player:WaitForChild("LevelUpContainer")
local LevelUpContainerInner: Frame = LevelUpContainer.LevelUpContainerInner
local Header: TextLabel = LevelUpContainer.Header
local ConfirmBtn: TextButton = LevelUpContainer.ConfirmBtn
-- -- left
local LeftContainer: Frame = LevelUpContainerInner.Left
local LevelInformation: TextLabel = LeftContainer.LevelInformation
-- -- -- plr level bar
local LevelBarContainer: Frame = LeftContainer.PlrLevelContainer.LevelBarContainer
local LevelBarProg: Frame = LevelBarContainer.LevelBar.LevelProg
local LevelXp: TextLabel = LevelBarContainer.LevelXP
local LevelText: TextLabel = LevelBarContainer.LevelIcon.LevelText
-- -- right
local RightContainer: Frame = LevelUpContainerInner.Right
local UnlockablesScrollingFrame: ScrollingFrame = RightContainer.ScrollingFrame
local UnlockedFeatureTemplate: Frame = UnlockablesScrollingFrame.Template

-- STATE VARIABLES --
local PlrLevelInfo = nil

GuiServices.StoreInCache(LevelUpContainer)

GuiServices.DefaultMainGuiStyling(LevelUpContainer)

GuiTemplates.HeaderText(Header)
GuiTemplates.CreateButton(ConfirmBtn, { Rotates = true })

local function resetVariables()
    PlrLevelInfo = nil
end

local function clearUnlockedFeatures()
    local instancesToIgnore = { "UIListLayout", "Template" }

    for _i, v in UnlockablesScrollingFrame:GetChildren() do
        if table.find(instancesToIgnore, v.Name) then continue end

        v:Destroy()
    end
end

local function populateLevelUpContainer()
    local preAdjLevel: number = PlrLevelInfo.PreAdjustmentLevel
    local postAdjLevel: number = PlrLevelInfo.PostAdjustmentLevel

    LevelInformation.Text = `<font color="#c9e6f2"><stroke color="#4090b3" thickness="2">Level {preAdjLevel}</stroke></font><font color="#a5ffa8"><stroke color="#52ab64" thickness="2"> >> Level {postAdjLevel}</stroke></font>`

    GuiServices.SetLevelBar(LevelBarProg, LevelText, LevelXp, PlrLevelInfo.PreAdjustmentLevel, PlrLevelInfo.PreAdjustmentXP, PlrLevelInfo.PreAdjustmentMaxXP)

    -- populate unlocked features scrolling frame
    clearUnlockedFeatures()
    for i = preAdjLevel + 1, postAdjLevel, 1 do
        local levelInfo = PlayerConfig.LevelUpInformation[tostring(i)]
        if not levelInfo then continue end
        if not levelInfo["Rewards"] then continue end
        if not levelInfo.Rewards["UnlockedFeatures"] then continue end

        for featureName, featureInfo in levelInfo.Rewards.UnlockedFeatures do
            local unlockedFeatureTemplate = UnlockedFeatureTemplate:Clone()
            local icon: ImageLabel = unlockedFeatureTemplate.UnlockedFeatureIcon
            local iconDropshadow: ImageLabel = icon.UnlockedFeatureIconDropshadow
            local desc: TextLabel = unlockedFeatureTemplate.UnlockedFeatureDescription

            icon.Image = GeneralUtils.GetDecalUrl(featureInfo.Icon)
            iconDropshadow.Image = GeneralUtils.GetDecalUrl(featureInfo.IconDropshadow)
            desc.Text = featureInfo.Description

            unlockedFeatureTemplate.Name = featureName
            unlockedFeatureTemplate.Parent = UnlockablesScrollingFrame
            unlockedFeatureTemplate.Visible = true
        end
    end
end

local function displayLevelUpRewards()
    local preAdjLevel: number = PlrLevelInfo.PreAdjustmentLevel
    local postAdjLevel: number = PlrLevelInfo.PostAdjustmentLevel

    -- display individual rewards in RewardsContainer
    for i = preAdjLevel + 1, postAdjLevel, 1 do
        local levelInfo = PlayerConfig.LevelUpInformation[tostring(i)]
        if not levelInfo then continue end
        if not levelInfo["Rewards"] then continue end

        local currencyRewards = levelInfo.Rewards["Currencies"]
        if currencyRewards then
            for currencyName: string, currencyAmt: number in currencyRewards do
                GuiServices.CreateRewardDisplay("Currency", currencyName, currencyAmt)
                task.wait(GlobalVariables.Gui.IntervalBetweenRewardDisplay)
            end
        end

        local otherRewards = levelInfo.Rewards["OtherRewards"]
        if otherRewards then
            for rewardName: string, rewardInfo in otherRewards do
                GuiServices.CreateRewardDisplay(rewardInfo.Type, rewardName, rewardInfo.Amount)
                task.wait(GlobalVariables.Gui.IntervalBetweenRewardDisplay)
            end
        end
    end
end

-- BTN ACTIVATIONS --
ConfirmBtn.Activated:Connect(function()
    Remotes.Studio.General.EnableInteractionBtns:Fire()
    GuiServices.ShowHUD()
    GuiServices.HideGuiStandard(LevelUpContainer)

    task.delay(0.5, function()
        displayLevelUpRewards()
        resetVariables()
    end)
end)

-- REMOTES --
Remotes.Character.PlayerLevelUp.OnClientEvent:Connect(function(plrLevelInfo)
    PlrLevelInfo = plrLevelInfo
    populateLevelUpContainer()

    Remotes.Studio.General.DisableInteractionBtns:Fire()
    GuiServices.HideHUD()
    GuiServices.ShowGuiStandard(LevelUpContainer, Color3.fromRGB(245, 167, 0))

    -- tween level bar
    GuiServices.TweenProgBar(LevelBarProg, LevelText, LevelXp, PlrLevelInfo.PreAdjustmentLevel, PlrLevelInfo.PostAdjustmentLevel, PlrLevelInfo.PostAdjustmentXP, PlrLevelInfo.PostAdjustmentMaxXP)
end)

local function characterAdded(char: Model)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        -- check if player reset before a non-instrusive level up could be displayed.
        -- if they did, then level up GUI & rewards in RewardsContainer will be displayed on reset
        Remotes.Character.PlayerLevelUp:FireServer()
    end)
end

if localPlr.Character then characterAdded(localPlr.Character) end

localPlr.CharacterAdded:Connect(characterAdded)
