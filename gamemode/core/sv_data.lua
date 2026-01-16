module("Data", package.seeall)

function Unpack(data, vars, defaultValues)
	local fields = {}

	for _, var in pairs(vars) do
		if not var.Persist then
			continue
		end

		local val = data[var.Field]

		if val == nil and defaultValues then
			val = util.SafeCopy(var.Default)
		elseif var.Decode then
			val = var.Decode(val)
		end

		fields[var.Name] = val
	end

	return fields
end

function Pack(data, vars)
	local fields = {}

	for name, value in pairs(data) do
		local var = vars[name]

		if not var.Persist then
			continue
		end

		if var.Validate and value != NULL and not var.Validate(value) then
			error(string.format("Data.Pack value '%s' doesn't match database type %s", value, var.DataType), 2)
		end

		if (not istable(value) and value == var.Default) or value == NULL then
			value = nil
		elseif var.Encode then
			value = var.Encode(value)
		end

		table.insert(fields, {var.Field, value})
	end

	return fields
end
