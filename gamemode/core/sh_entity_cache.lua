module("EntityCache", package.seeall)

Defines = Defines or {}
List = List or {}

function Add(name, func)
	Defines[name] = func

	if not List[name] then
		List[name] = {}
	end
end

function Get(name)
	local cache = assert(List[name], "No entity cache with name '" .. name .. "' exists")

	return cache
end

function Iterator(name)
	return pairs(Get(name))
end

function Contains(name, ent)
	local cache = assert(List[name], "No entity cache with name '" .. name .. "' exists")

	return tobool(cache[ent])
end

function OnCreated(ent)
	for name, func in pairs(Defines) do
		if func(ent) then
			List[name][ent] = true
		end
	end
end

function OnRemoved(ent)
	for _, entities in pairs(List) do
		entities[ent] = nil
	end
end
