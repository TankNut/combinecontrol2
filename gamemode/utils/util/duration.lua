local formats = {}

local function addFormat(ratio, ...)
	for _, format in ipairs({...}) do
		formats[string.lower(format)] = ratio
	end
end

addFormat(1 / 1000, "ms", "milisecond", "miliseconds")
addFormat(1, "", "s", "sec", "secs", "second", "seconds")
addFormat(60, "m", "min", "mins", "minute", "minutes")
addFormat(formats.m * 60, "h", "hr", "hrs", "hour", "hours")
addFormat(formats.h * 24, "d", "day", "days")
addFormat(formats.d * 7, "w", "wk", "wks", "week", "weeks")
addFormat(formats.d * (365 / 12), "mon", "mons", "month", "months")
addFormat(formats.d * 365, "y", "yr", "yrs", "year", "years")

function util.Duration(str, outputFormat)
	outputFormat = outputFormat and string.lower(outputFormat) or ""

	local outputRatio = formats[outputFormat]

	if not outputRatio then
		return
	end

	local result

	for num, unit in string.gmatch(str, "(%-?%d*%.?%d*) ?(%a*)") do
		num = tonumber(num)
		unit = string.lower(unit)

		if num == nil then
			continue
		end

		local ratio = formats[unit]

		if not ratio then
			continue
		end

		if not result then
			result = 0
		end

		result = result + num * ratio
	end

	if result != nil then
		return result / outputRatio
	end
end
