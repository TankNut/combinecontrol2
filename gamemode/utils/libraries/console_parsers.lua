local boolValues = {
	f = false
}

console.Parser("Bool", function(ply, args, last, options)
	local val = console.ReadArg(args, last)
	local bool = boolValues[val]

	if bool == nil then
		bool = tobool(val)
	end

	return true, bool
end)

console.Parser("String", function(ply, args, last, options)
	local val = console.ReadArg(args, last)
	local ok, err = validate.Value(val, options)

	return ok, ok and val or err
end)

console.Parser("Number", function(ply, args, last, options)
	local val = tonumber(console.ReadArg(args, last))
	local ok, err = validate.Value(val, table.Add({
		validate.Number()
	}, options))

	return ok, ok and val or err
end)

console.Parser("Duration", function(ply, args, last, options)
	local val = console.ReadArg(args, last)

	if options.AllowZero and string.lower(val) == "now" then
		return true, 0
	end

	local duration = util.Duration(val, options.Format)

	if not duration then
		return false, "Invalid duration"
	end

	if duration == 0 then
		if options.AllowZero then
			return true, 0
		else
			return false, "Invalid duration"
		end
	end

	if options.Min and duration < util.Duration(options.Min, options.Format) then
		return false, "Must be at least " .. options.Min
	end

	if options.Max and duration > util.Duration(options.Max, options.Format) then
		return false, "Can't be longer than " .. options.Max
	end

	return true, duration
end)
