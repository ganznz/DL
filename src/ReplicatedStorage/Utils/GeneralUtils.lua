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

return GeneralUtils