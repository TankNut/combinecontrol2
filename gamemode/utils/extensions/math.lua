function math.Sign(value)
	if value > 0 then
		return 1
	elseif value < 0 then
		return -1
	end

	return 0
end

function math.InRange(value, min, max)
	return value >= min and value <= max
end

function math.ClampedRemap(value, inMin, inMax, outMin, outMax)
	return math.Clamp(
		math.Remap(value, inMin, inMax, outMin, outMax),
		math.min(outMin, outMax),
		math.max(outMin, outMax)
	)
end

function math.Maybe(percentage)
	return percentage >= math.Rand(0, 100)
end

function math.ApproachSpeed(start, dest, speed)
	local dist = math.max(math.abs(start - dest), 0.0001)

	return math.Approach(start, dest, dist / speed)
end

function math.Snap(value, multiple)
	return math.Round(value / multiple) * multiple
end

function math.Distance(a, b)
	return math.max(a, b) - math.min(a, b)
end

function math.Guard(num)
	if num != num then
		return 0
	end

	return num
end
