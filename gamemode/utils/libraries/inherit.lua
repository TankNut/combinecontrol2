module("inherit", package.seeall)

Classes = Classes or {}

function Register(group, name, data, parent)
	if not Classes[group] then
		Classes[group] = {}
	end

	local classes = Classes[group]

	if parent and not classes[parent] then
		Register(group, parent, {})
	end

	data.ClassGroup = group
	data.ClassName = name

	if classes[name] then
		table.Empty(classes[name])
		table.Merge(classes[name], data, true)
	else
		classes[name] = data
	end

	return setmetatable(classes[name], {
		__index = classes[parent]
	})
end

function Exists(group, name)
	if not Classes[group] then
		return false
	end

	return tobool(Classes[group][name])
end

function Get(group, name)
	if not Classes[group] or not Classes[group][name] then
		return Register(group, name, {})
	end

	return Classes[group][name]
end

function Instance(group, name, data)
	local classes = assert(Classes[group], "Attempt to instance unknown group: " .. group)
	local class = assert(classes[name], "Attempt to instance unknown class: " .. name)

	return setmetatable(data or {}, {
		__index = class,
		__tostring = class.__tostring
	})
end

function IsType(instance, group, name)
	if not istable(instance) or not instance.ClassGroup or not instance.ClassName then
		return false
	end

	if instance.ClassGroup != group then
		return false
	end

	if name then
		if instance.ClassName == name then
			return true
		end

		local class = getmetatable(instance).__index

		while class do
			if class.ClassName == name then
				return true
			end

			class = getmetatable(class).__index
		end

		return false
	end

	return true
end
