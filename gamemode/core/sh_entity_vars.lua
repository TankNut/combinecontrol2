local emeta = FindMetaTable("Entity")

module("EntityVar", package.seeall)

Vars = Vars or {}
Store = Store or {}

function Add(metatable, name, data)
	if data == nil then
		data = name
		name = metatable
		metatable = "Entity"
	end

	local meta = FindMetaTable(metatable)

	if not meta or (meta != emeta and meta.MetaBaseClass != emeta) then
		error("Metatable doesn't exist or isn't derived from Entity")
	end

	data = {
		Name = name,
		Index = "e_" .. name,
		Default = data.Default,
		ServerOnly = tobool(data.ServerOnly)
	}

	Store[name] = Store[name] or {}
	Vars[name] = Vars[name] or {}

	local index = data.Index
	local default = data.Default
	local serverOnly = data.ServerOnly

	if serverOnly and CLIENT then
		return
	end

	local cache = Store[name]
	local hookName = "On" .. metatable .. name .. "Changed"

	local get = function(ent)
		local value = cache[ent]

		if value == nil then
			return util.SafeCopy(data.Default)
		end

		return value
	end

	local set = function(ent, value)
		local old = get(ent)
		cache[ent] = value
		local new = get(ent)

		if not istable(old) and new == old then
			return true
		end

		hook.Run(hookName, ent, old, new)
	end

	meta[name] = get
	meta["Set" .. name] = function(ent, value)
		if value == default then value = nil end

		if set(ent, value) then
			return
		end

		if SERVER and not serverOnly then
			netstream.Send(nil, index, ent, value)
		end
	end

	if CLIENT then
		netstream.Hook(index, set)
	end
end

function Clear(ent)
	for _, entities in pairs(Store) do
		entities[ent] = nil
	end
end

if CLIENT then
	netstream.Hook("BulkEntityVars", function(ent, data)
		for name, value in pairs(data) do
			local set = ent["Set" .. name]

			if set then
				set(ent, value)
			end
		end
	end)
else
	function Sync(ent, requester)
		local data = {}

		for var, entities in pairs(Store) do
			data[var] = entities[ent]
		end

		if table.Count(data) > 0 then
			netstream.Send(requester, "BulkEntityVars", ent, data)
		end
	end
end
