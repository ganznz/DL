local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

local GlobalVariables = require(ReplicatedStorage.GlobalVariables)

-- // this file contains methods that can be used anywhere without dependancy on gameplay code // --

local GeneralUtils = {}

function GeneralUtils.HasProperty(object, propertyName)
    local success, _ = pcall(function() 
        object[propertyName] = object[propertyName]
    end)
    return success
end

function GeneralUtils.ShallowCopy(original)
    local copy = {}
    for k, v in original do
        copy[k] = v
    end
    return copy
end

function GeneralUtils.ShallowCopyNested(original)
    local copy = {}

    for k, v in original do
        if type(v) == "table" then
            v = GeneralUtils.ShallowCopyNested(v)
        end

        copy[k] = v
    end

    return copy
end

function GeneralUtils.LengthOfDict(dict)
	local counter = 0
	for _, v in dict do
		counter += 1
	end
	return counter
end

function GeneralUtils.GetDecalUrl(imageID: string)
    if (imageID == "" or not imageID) then imageID = GlobalVariables.Images.PlaceholderImage end

    return string.format("http://www.roblox.com/asset/?id=%s", imageID)
end

function GeneralUtils.GetCFrameOrientation(cframe: CFrame): {}
    local sx, sy, sz, m00, m01, m02, m10, m11, m12, m20, m21, m22 = cframe:GetComponents()
    local orientation = {}
    
    local x = math.atan2(-m12, m22)
    local y = math.asin(m02)
    local z = math.atan2(-m01, m00)
    
    orientation["X"] = x
    orientation["Y"] = y
    orientation["Z"] = z

    return orientation
end

-- opts:
-- -- Tween -> boolean. Tweens transparency
function GeneralUtils.HideModel(model: Model, opts: {})
    for _i, v in model:GetDescendants() do
        local success, _ = pcall(function()
            if opts and opts["Tween"] then
                TweenService:Create(v, TweenInfo.new(0.3), { Transparency = 1 }):Play()
            else
                v.Transparency = 1
            end
        end)
    end
end

-- opts:
-- -- Tween -> boolean. Tweens transparency
function GeneralUtils.ShowModel(model: Model, opts: {})
    for _i, v in model:GetDescendants() do
        local success, _ = pcall(function()
            if opts and opts["Tween"] then
                TweenService:Create(v, TweenInfo.new(0.3), { Transparency = 0 }):Play()
            else
                v.Transparency = 0
            end
        end)
    end
end

function GeneralUtils.RoundToDp(num, dp)
    local increment = "0."
    for i=1, dp do increment = increment .. "0" end
    increment = increment .. "1"
    increment = tonumber(increment)
    return math.floor(num / increment + 0.5) * increment
end


-- function returns a NEW table with values in tb1 that are not in tb2
function GeneralUtils.UniqueTable(tb1: {}, tb2: {})
    local newTable = {}

    for _i, v in tb1 do
        if table.find(tb2, v) then continue end
        table.insert(newTable, v)
    end

    return newTable
end

function GeneralUtils.PlaySfx(soundId: string): Sound
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    SoundService:PlayLocalSound(sound)
    sound.Ended:Connect(function() sound:Destroy() end)

    return sound
end

function GeneralUtils.GetVectorBetweenUDim2s(UDim2A: UDim2, UDim2B: UDim2): Vector2
    local vectorX = UDim2B.X.Scale - UDim2A.X.Scale
    local vectorY = UDim2B.Y.Scale - UDim2A.Y.Scale
    return Vector2.new(vectorX, vectorY)
end

-- opts     
-- LowerBound: "closed" | "open" (default: "closed")        
-- UpperBound: "closed" | "open" (default: "closed")        
function GeneralUtils.IsInRange(range: NumberRange, num: number, opts: {})
    opts = opts or { LowerBound = "closed", UpperBound = "closed" }

    local lowerClosed = opts.LowerBound == "closed"
    local upperClosed = opts.UpperBound == "closed"

    return (if lowerClosed then num >= range.Min else num > range.Min) and (if upperClosed then num <= range.Max else num < range.Max)
end

-- args     
---- filterMethodToUse:     
------ "1": GetChatForUserAsync(toUserId: number): string     
------ "2": GetNonChatStringForBroadcastAsync(): string       
------ "3": GetNonChatStringForUserAsync(toUserId: number): string      
--
-- -> { Text->String: The post-filtered text, Censored->Boolean: Indicates if text is censored }
function GeneralUtils.FilterText(plr: Player, textToFilter: string, filterMethodToUse: "1" | "2" | "3"): { Text: string, Censored: boolean }
    local textFilterResult = ""
    local success, errorMessage = pcall(function()
        textFilterResult = TextService:FilterStringAsync(textToFilter, plr.UserId, Enum.TextFilterContext.PublicChat)
    end)
    if not success then
        warn(`Error filtering text: {textToFilter}, :, {errorMessage}`)
        return { Text = "", Censored = false }
    end

    local stringToReturn = textToFilter

    local filteredText = ""
    local success2, errorMessage2 = pcall(function()
        if filterMethodToUse == "1" then
            filteredText = textFilterResult:GetChatForUserAsync(plr.UserId)
        elseif filterMethodToUse == "2" then
            filteredText = textFilterResult:GetNonChatStringForBroadcastAsync()
        elseif filterMethodToUse == "3" then
            filteredText = textFilterResult:GetNonChatStringForUserAsync(plr.UserId)
        else
            warn("Filter method not selected")
        end
    end)
    if not success2 then return { Text = "", Censored = false } end

    return {
        Text = filteredText,
        Censored = filteredText ~= textToFilter -- if original text and post-filtered text aren't the same, then the text was censored
    }
end


return GeneralUtils