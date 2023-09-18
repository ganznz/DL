local Time = {}

function Time.ParseTime(seconds: number)
    if seconds < 3600 then -- parse into minutes & seconds
        return { Minutes = math.floor(seconds / 60), Seconds = seconds % 60 }
    end
end

return Time