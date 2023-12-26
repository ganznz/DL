local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlobalVariables = {}

-- GUI --
GlobalVariables.Gui = {}

-- gui position variables
GlobalVariables.Gui.MainGuiInvisibleXOffset = 0  -- the increase in pos when hiding a GUI instance
GlobalVariables.Gui.MainGuiInvisibleYOffset = 0.3

-- gui sizing variables
GlobalVariables.Gui.MainGuiInvisibleXSize = 0 -- the decrease in size when hiding a GUI instance
GlobalVariables.Gui.MainGuiInvisibleYSize = 0

-- gui camera variables
GlobalVariables.Gui.GuiVisibleCameraFOV = 77 -- FOV of camera when showing a GUI instance
GlobalVariables.Gui.GuiInvisibleCameraFOV = 70 -- default camera FOV

-- gui tween variables
GlobalVariables.Gui.MainGuiOpenTime = 0.4 -- seconds
GlobalVariables.Gui.MainGuiCloseTime = 0.1
GlobalVariables.Gui.GuiVisibleCameraTime = 0.1
GlobalVariables.Gui.GuiInvisibleCameraTime = 0.1
GlobalVariables.Gui.MainGuiCloseTime = 0.1
GlobalVariables.Gui.LoadingBgTweenTime = 0.5

-- general gui colours
GlobalVariables.Gui.StandardBlue = Color3.fromRGB(130, 186, 255)
GlobalVariables.Gui.ValidGreenColour = Color3.fromRGB(93, 217, 91)
GlobalVariables.Gui.InvalidGreyColour = Color3.fromRGB(168, 168, 168)
GlobalVariables.Gui.CantAffordColour = Color3.fromRGB(241, 170, 63)
GlobalVariables.Gui.InvalidRedColour = Color3.fromRGB(255, 106, 108)
GlobalVariables.Gui.GuiBackdropColourDefault = Color3.fromRGB(0, 0, 0)
GlobalVariables.Gui.GuiBackdropColourGreen = Color3.fromRGB(18, 111, 11)

-- rarity colours
GlobalVariables.Gui.CommonRarityColour = Color3.fromRGB(168, 168, 168) -- unskilled
GlobalVariables.Gui.UncommonRarityColour = Color3.fromRGB(79, 214, 70) -- trainee
GlobalVariables.Gui.RareRarityColour = Color3.fromRGB(70, 156, 214) -- regular
GlobalVariables.Gui.VeryRareRarityColour = Color3.fromRGB(255, 117, 117) -- skilled
GlobalVariables.Gui.LegendaryRarityColour = Color3.fromRGB(255, 177, 94) -- seasoned
GlobalVariables.Gui.UltraRarityColour = Color3.fromRGB(216, 184, 255) -- elite
GlobalVariables.Gui.MythicalRarityColour = Color3.fromRGB(255, 186, 255) -- prodigy

-- text colours
GlobalVariables.Gui.GuiHeaderTextColour = Color3.fromRGB(66, 66, 66)
GlobalVariables.Gui.GuiSecondaryTextColour = Color3.fromRGB(126, 126, 126)

-- notification colours
GlobalVariables.Gui.NotificationStandard = Color3.fromRGB(130, 186, 255)
GlobalVariables.Gui.NotificationGood = Color3.fromRGB(130, 229, 115)
GlobalVariables.Gui.NotificationWarning = Color3.fromRGB(255, 106, 108)


-- SOUND --
local SoundsFolder = ReplicatedStorage.Assets.Sounds
GlobalVariables.Sound = {}
GlobalVariables.Sound.Sfx = {}

-- gui sound effects
GlobalVariables.Sound.Sfx.GuiOpen = SoundsFolder.Sfx:FindFirstChild("GuiOpen")
GlobalVariables.Sound.Sfx.GuiMouseHover = SoundsFolder.Sfx:FindFirstChild("GuiMouseHover")


-- IMAGES --
GlobalVariables.Images = {}
GlobalVariables.Images.Icons = {}

-- main icons
GlobalVariables.Images.Icons.CoinIcon = "15695993944"
GlobalVariables.Images.Icons.GemIcon = "15762047580"

-- stroke icons

-- dropshadow icons
GlobalVariables.Images.Icons.CoinIconDropshadow = "15762115765"
GlobalVariables.Images.Icons.GemIconDropshadow = "15762118382"

return GlobalVariables