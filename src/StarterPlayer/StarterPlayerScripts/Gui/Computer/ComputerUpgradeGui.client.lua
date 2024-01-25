-- local TweenService = game:GetService("TweenService")
-- local Workspace = game:GetService("Workspace")
-- local Players = game:GetService("Players")
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- local GeneralUtils = require(ReplicatedStorage.Utils:WaitForChild("GeneralUtils"))
-- local GeneralConfig = require(ReplicatedStorage.Configs:WaitForChild("General"))
-- local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))
-- local GuiTemplates = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiTemplates"))
-- local PlayerServices = require(ReplicatedStorage.Utils.Player:WaitForChild("Player"))
-- local CameraControls = require(ReplicatedStorage.Utils.Camera:WaitForChild("CameraControls"))
-- local GenreConfig = require(ReplicatedStorage.Configs.GameDev:WaitForChild("Genre"))
-- local TopicConfig = require(ReplicatedStorage.Configs.GameDev:WaitForChild("Topic"))
-- local StudioConfig = require(ReplicatedStorage.Configs.Studio:WaitForChild("Studio"))
-- local StaffMemberConfig = require(ReplicatedStorage.Configs.Staff:WaitForChild("StaffMember"))
-- local PlayerConfig = require(ReplicatedStorage.Configs:WaitForChild("Player"))
-- local ComputerConfig = require(ReplicatedStorage.Configs.GameDev:WaitForChild("Computer"))
-- local FormatNumber = require(ReplicatedStorage.Libs:WaitForChild("FormatNumber").Simple)

-- local Remotes = ReplicatedStorage.Remotes

-- local localPlr = Players.LocalPlayer

-- local PlayerGui = localPlr.PlayerGui
-- local camera = Workspace:WaitForChild("Camera")

-- -- GUI REFERENCE VARIABLES --
-- local AllGuiScreenGui = PlayerGui:WaitForChild("AllGui")
-- -- general
-- local ComputerUpgradeContainer = AllGuiScreenGui.Computer:WaitForChild("ComputerUpgradeContainer")
-- local ContainerInner = ComputerUpgradeContainer.ComputerUpgradeContainerInner
-- local HeaderText = ComputerUpgradeContainer.Header
-- local ExitBtn = ComputerUpgradeContainer.ExitBtn
-- -- stats container
-- local StatsContainer = ContainerInner.StatsContainer
-- local CoinsBuffText = StatsContainer:FindFirstChild("Coins", true)
-- local CodePtsBuffText = StatsContainer:FindFirstChild("CodePts", true)
-- local SoundPtsBuffText = StatsContainer:FindFirstChild("SoundPts", true)
-- local ArtPtsBuffText = StatsContainer:FindFirstChild("ArtPts", true)
-- -- scrolling frame
-- local ScrollingFrame = ContainerInner.ScrollingFrame
-- local CompletedTemplate = ScrollingFrame.CompletedTemplate
-- local LockedTemplate = ScrollingFrame.LockedTemplate
-- -- -- inprogress template
-- local InprogressTemplate = ScrollingFrame.InProgressTemplate
-- -- -- -- requirements view
-- local RequirementsView = InprogressTemplate.Info.RequirementsView
-- local InProgComputerIcon = RequirementsView.ComputerIcon
-- local InProgComputerName = RequirementsView.ComputerName
-- local MaterialsContainer = RequirementsView.MaterialsContainer
-- local MaterialsContainerTemplate = MaterialsContainer.Template
-- local UpgradesContainer = RequirementsView.UpgradesContainer
-- local UpgradesContainerTemplate = UpgradesContainer.Template
-- -- -- -- upgrade view
-- local UpgradeView = InprogressTemplate.Info.UpgradeView
-- local UpgradeName = UpgradeView.UpgradeName
-- local UpgradeDesc = UpgradeView.UpgradeDesc
-- local UpgradeViewSelectBtn = UpgradeView.SelectBtn
-- local UpgradeViewBackBtn = UpgradeView.BackBtn
-- local UpgradeViewProgBar = UpgradeView.ProgressContainer.ProgressBar.ProgressBarProg
-- local UpgradeViewProgText = UpgradeView.ProgressContainer.Progress


-- -- STATIC VARIABLES --

-- -- STATE VARIABLES --