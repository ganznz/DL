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

return GeneralUtils