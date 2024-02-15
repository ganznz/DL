local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

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
GlobalVariables.Gui.FlashShowTime = 0.2 -- time it takes for the flash

-- general gui colours
GlobalVariables.Gui.StandardBlue = Color3.fromRGB(130, 186, 255)
GlobalVariables.Gui.ValidGreenColour = Color3.fromRGB(93, 217, 91)
GlobalVariables.Gui.InvalidGreyColour = Color3.fromRGB(168, 168, 168)
GlobalVariables.Gui.CantAffordColour = Color3.fromRGB(241, 170, 63)
GlobalVariables.Gui.InvalidRedColour = Color3.fromRGB(255, 106, 108)
GlobalVariables.Gui.GuiBackdropColourDefault = Color3.fromRGB(0, 0, 0)
GlobalVariables.Gui.GuiBackdropColourGreen = Color3.fromRGB(18, 111, 11)

-- rarity colours
GlobalVariables.Gui.Rarity1Colour = Color3.fromRGB(168, 168, 168)
GlobalVariables.Gui.Rarity2Colour = Color3.fromRGB(79, 214, 70)
GlobalVariables.Gui.Rarity3Colour = Color3.fromRGB(70, 156, 214)
GlobalVariables.Gui.Rarity4Colour = Color3.fromRGB(255, 177, 94)
GlobalVariables.Gui.Rarity5Colour = Color3.fromRGB(255, 80, 80)
GlobalVariables.Gui.Rarity6Colour = Color3.fromRGB(158, 88, 255)
GlobalVariables.Gui.Rarity7Colour = Color3.fromRGB(255, 88, 216)

-- text colours
GlobalVariables.Gui.GuiHeaderTextColour = Color3.fromRGB(66, 66, 66)
GlobalVariables.Gui.GuiSecondaryTextColour = Color3.fromRGB(126, 126, 126)

-- notification colours
GlobalVariables.Gui.NotificationStandard = Color3.fromRGB(130, 186, 255)
GlobalVariables.Gui.NotificationGood = Color3.fromRGB(130, 229, 115)
GlobalVariables.Gui.NotificationWarning = Color3.fromRGB(255, 106, 108)


-- border flash colours
GlobalVariables.Gui.BorderFlashDmgTaken = Color3.fromRGB(172, 48, 48)


-- SOUND --
local LocalSounds = SoundService.LocalSounds
GlobalVariables.Sound = {}
GlobalVariables.Sound.Sfx = {}

-- general sfx
-- -- Variables hold sound ID's, not actual Sound instance
GlobalVariables.Sound.Sfx.PhoneOpenNormal = LocalSounds.Sfx:FindFirstChild("PhoneOpenNormal").SoundId
GlobalVariables.Sound.Sfx.PhoneOpenRare = LocalSounds.Sfx:FindFirstChild("PhoneOpenRare").SoundId
GlobalVariables.Sound.Sfx.PowerupStandard = LocalSounds.Sfx:FindFirstChild("PowerupStandard").SoundId
GlobalVariables.Sound.Sfx.PowerupSpecial = LocalSounds.Sfx:FindFirstChild("PowerupSpecial").SoundId
GlobalVariables.Sound.Sfx.NotificationStandard = LocalSounds.Sfx:FindFirstChild("NotificationStandard").SoundId
GlobalVariables.Sound.Sfx.LevelUp = LocalSounds.Sfx:FindFirstChild("LevelUp").SoundId
GlobalVariables.Sound.Sfx.CountdownLoop = LocalSounds.Sfx:FindFirstChild("CountdownLoop").SoundId
GlobalVariables.Sound.Sfx.CountdownEnd = LocalSounds.Sfx:FindFirstChild("CountdownEnd").SoundId
GlobalVariables.Sound.Sfx.SwooshFast = LocalSounds.Sfx:FindFirstChild("SwooshFast").SoundId
GlobalVariables.Sound.Sfx.SwooshSlow = LocalSounds.Sfx:FindFirstChild("SwooshSlow").SoundId

-- gui sound effects
GlobalVariables.Sound.Sfx.GuiOpen = LocalSounds.Sfx:FindFirstChild("GuiOpen").SoundId
GlobalVariables.Sound.Sfx.GuiMouseHover = LocalSounds.Sfx:FindFirstChild("GuiMouseHover").SoundId


-- IMAGES --
GlobalVariables.Images = {}
GlobalVariables.Images.Icons = {}

-- currency icons
GlobalVariables.Images.Icons.Coin = "16372999263"
GlobalVariables.Images.Icons.CoinStroke = "16373001596"
GlobalVariables.Images.Icons.CoinDropshadow = "16372999994"
GlobalVariables.Images.Icons.Gem = "16373002493"
GlobalVariables.Images.Icons.GemStroke = "16373003659"
GlobalVariables.Images.Icons.GemDropshadow = "16373004138"
GlobalVariables.Images.Icons.CoinBundleSmall = "16373005101"
GlobalVariables.Images.Icons.CoinBundleSmallStroke = "16373005562"
GlobalVariables.Images.Icons.CoinBundleSmallDropshadow = "16373006490"
GlobalVariables.Images.Icons.CoinBundleMedium = "16373007309"
GlobalVariables.Images.Icons.CoinBundleMediumStroke = "16373008189"
GlobalVariables.Images.Icons.CoinBundleMediumDropshadow = "16373009012"
GlobalVariables.Images.Icons.CoinBundleLarge = "16373009919"
GlobalVariables.Images.Icons.CoinBundleLargeStroke = "16373010420"
GlobalVariables.Images.Icons.CoinBundleLargeDropshadow = "16373010778"
GlobalVariables.Images.Icons.GemBundleSmall = "16373011745"
GlobalVariables.Images.Icons.GemBundleSmallStroke = "16373012132"
GlobalVariables.Images.Icons.GemBundleSmallDropshadow = "16373012628"
GlobalVariables.Images.Icons.GemBundleMedium = "16373013351"
GlobalVariables.Images.Icons.GemBundleMediumStroke = "16373013990"
GlobalVariables.Images.Icons.GemBundleMediumDropshadow = "16373014368"
GlobalVariables.Images.Icons.GemBundleLarge = "16373015338"
GlobalVariables.Images.Icons.GemBundleLargeStroke = "16373016039"
GlobalVariables.Images.Icons.GemBundleLargeDropshadow = "16373016600"
GlobalVariables.Images.Icons.GemBundleExtraLarge = "16373017598"
GlobalVariables.Images.Icons.GemBundleExtraLargeStroke = "16373018109"
GlobalVariables.Images.Icons.GemBundleExtraLargeDropshadow = "16373018665"
GlobalVariables.Images.Icons.GemBundleMassive = "16373019351"
GlobalVariables.Images.Icons.GemBundleMassiveStroke = "16373019828"
GlobalVariables.Images.Icons.GemBundleMassiveDropshadow = "16373020344"
GlobalVariables.Images.Icons.CoinGemBundle = "16373021185"
GlobalVariables.Images.Icons.CoinGemBundleStroke = "16373021613"
GlobalVariables.Images.Icons.CoinGemBundleDropshadow = "16373022234"

-- plr icons
GlobalVariables.Images.Icons.PlrLevelIcon = "15998286348"
GlobalVariables.Images.Icons.PlrLevelStrokeIcon = "1599828"
GlobalVariables.Images.Icons.PlrLevelDropshadowIcon = "15998288304"
GlobalVariables.Images.Icons.PlrEnergyIcon = "15998270577"
GlobalVariables.Images.Icons.PlrEnergyStrokeIcon = "15998271911"
GlobalVariables.Images.Icons.PlrEnergyDropshadowIcon = "15991548869"
GlobalVariables.Images.Icons.PlrEnergyGrayscaleIcon = "16073650701"
GlobalVariables.Images.Icons.PlrHungerIcon = "15998275495"
GlobalVariables.Images.Icons.PlrHungerStrokeIcon = "15998279544"
GlobalVariables.Images.Icons.PlrHungerDropshadowIcon = "15998277391"
GlobalVariables.Images.Icons.PlrMoodIcon = "15998280893"
GlobalVariables.Images.Icons.PlrMoodStrokeIcon = "15998283439"
GlobalVariables.Images.Icons.PlrMoodDropshadowIcon = "15998284746"



return GlobalVariables