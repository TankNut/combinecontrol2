module("validate", package.seeall)

Rules = Rules or {}

function AddRule(name, callback, checkNil)
	Rules[name] = setmetatable({
		Callback = callback,
		CheckNil = checkNil
	}, {
		__call = function(_, ...)
			return {
				Name = name,
				Args = {...}
			}
		end
	})

	validate[name] = Rules[name]
end

function Value(val, rules, name)
	name = name or "Value"

	if rules.Name then
		rules = {rules}
	end

	for k, v in ipairs(rules) do
		local rule = Rules[v.Name]

		if val == nil and not rule.CheckNil then
			continue
		end

		local ok, err = rule.Callback(val, unpack(v.Args))

		if not ok then
			return false, name .. " " .. err
		end
	end

	return true, val
end

function Multi(tab, rules)
	Cache = tab

	local ret = {}

	for k, v in pairs(tab) do
		local rule = rules[k] or rules["*"]

		if not rule then
			continue
		end

		local ok, err = Value(v, rule)

		if not ok then
			Cache = nil

			return false, k, k .. " " .. err
		end

		ret[k] = v
	end

	-- Check for missing keys
	for k, v in pairs(rules) do
		if k != "*" and not ret[k] then
			local ok, err = Value(nil, v)

			if not ok then
				Cache = nil

				return false, k, err
			end
		end
	end

	Cache = nil

	return true, ret
end

AddRule("Required", function(val)
	return val != nil, "is required"
end, true)

AddRule("Is", function(val, types)
	local id = TypeID(val)

	if istable(types) then
		for _, v in ipairs(types) do
			if id == v then
				return true
			end
		end

		return false, string.format("is not the right type (Expected %s)", table.concat(table.Map(types, util.TypeIDToString), ", "))
	else
		return id == types, string.format("is not the right type (Expected %s)", util.TypeIDToString(types))
	end
end, true)

AddRule("Number", function(val) return isnumber(val), "has to be a number" end)
AddRule("String", function(val) return isstring(val), "has to be a string" end)
AddRule("Bool", function(val) return isbool(val), "has to be a boolean" end)
AddRule("Color", function(val) return IsColor(val), "has to be a color" end)

AddRule("Min", function(val, min)
	if isstring(val) then
		return #val >= min, string.format("has to be at least %s characters long", min)
	else
		return val >= min, "can't be less than " .. min
	end
end)

AddRule("Max", function(val, max)
	if isstring(val) then
		return #val <= max, string.format("can't be more than %s characters long", max)
	else
		return val <= max, "can't be more than " .. max
	end
end)

AddRule("AllowedCharacters", function(val, characters)
	local lookup = table.Lookup(string.Explode("", characters))
	local bad = {}

	for _, v in ipairs(string.Explode("", val)) do
		if not lookup[v] then
			bad[v] = true
		end
	end

	if table.Count(bad) > 0 then
		local badCharacters = table.GetKeys(bad)

		table.sort(badCharacters)

		return false, "cannot contain the following characters: " .. table.concat(badCharacters)
	end

	return true
end)

AddRule("Callback", function(val, callback)
	return callback(val)
end)

AddRule("InList", function(val, tab)
	local concat = {}

	for k, v in pairs(tab) do
		concat[k] = tostring(v)
	end

	return table.HasValue(tab, val), "must be one of the following: " .. table.concat(concat, ", ")
end)

AddRule("InLookup", function(val, tab)
	return tobool(tab[val]), "must be one of the following: " .. table.concat(table.GetKeys(tab), ", ")
end)

local function getProperty(val, index, ...)
	if index == nil then
		return val
	end

	if index == "#" then
		return #val
	end

	local property = val[index]

	if isfunction(property) then
		return property(val, ...)
	end

	return property
end

local function getPropertyName(val, index, ...)
	if index == nil then
		return ""
	end

	if index == "#" then
		return "length "
	end

	local property = val[index]

	if isfunction(property) then
		return string.format(":%s() ", index)
	end

	return string.format(".%s ", index)
end

AddRule("True", function(val, property, ...) return tobool(getProperty(val, property, ...)), string.format("%shas to be true", getPropertyName(val, property, ...)) end)
AddRule("False", function(val, property, ...) return not tobool(getProperty(val, property, ...)), string.format("%shas to be false", getPropertyName(val, property, ...)) end)

AddRule("Equals", function(val, other, property, ...) return getProperty(val, property, ...) == other, string.format("%shas to be equal to %s", getPropertyName(val, property, ...), other) end)
AddRule("Differs", function(val, other, property, ...) return getProperty(val, property, ...) != other, string.format("%shas to not be equal to %s", getPropertyName(val, property, ...), other) end)

AddRule("LessThan", function(val, other, property, ...) return getProperty(val, property, ...) < other, string.format("%shas to be less than %s", getPropertyName(val, property, ...), other) end)
AddRule("LessThanEquals", function(val, other, property, ...) return getProperty(val, property, ...) <= other, string.format("%shas to be less than or equal to %s", getPropertyName(val, property, ...), other) end)

AddRule("GreaterThan", function(val, other, property, ...) return getProperty(val, property, ...) > other, string.format("%shas to be greater than", getPropertyName(val, property, ...), other) end)
AddRule("GreaterThanEquals", function(val, other, property, ...) return getProperty(val, property, ...) >= other, string.format("%shas to be equal to or greater than %s", getPropertyName(val, property, ...), other) end)
