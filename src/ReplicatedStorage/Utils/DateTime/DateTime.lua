local DateTime = {}

function DateTime.ParseTimeLeft(totalSeconds: number)
    -- parse into minutes & seconds
    if totalSeconds < 3600 then
        local minutes = math.floor(totalSeconds / 60)
        local seconds = totalSeconds % 60
        return {
            Minutes = minutes,
            Seconds = seconds
        }
    
    -- parse into hours, minutes & seconds
    elseif totalSeconds < 86400 then
        local hours = math.floor(totalSeconds / 3600)
        local minutes = math.floor((totalSeconds % 3600) / 60)
        local seconds = math.floor((totalSeconds) % 60)
        return {
            Hours = hours,
            Minutes = minutes,
            Seconds = seconds
        }
    
    -- parse into days, hours, minutes, & seconds
    else
        local days = math.floor(totalSeconds / (3600 * 24));
        local hours = math.floor(totalSeconds % (3600 * 24) / 3600);
        local minutes = math.floor(totalSeconds % 3600 / 60);
        local seconds = math.floor(totalSeconds % 60);
        return {
            Days = days,
            Hours = hours,
            Minutes = minutes,
            Seconds = seconds
        }
    end
end

-- opts:
-- -- verbose: boolean (if specified, formatted string uses full words (hours, minutes, etc instead of h, m, etc)
function DateTime.FormatTimeLeft(totalSeconds: number, opts: {})
    local parsedTime = DateTime.ParseTimeLeft(totalSeconds)

    if totalSeconds < 3600 then
        return `{parsedTime.Minutes}m {parsedTime.Seconds}s`

    elseif totalSeconds < 86400 then
        return `{parsedTime.Hours}h {parsedTime.Minutes}m {parsedTime.Seconds}s`
    else
        return `{parsedTime.Days}d {parsedTime.Hours}h {parsedTime.Minutes}m {parsedTime.Seconds}s`
    end
end

return DateTime