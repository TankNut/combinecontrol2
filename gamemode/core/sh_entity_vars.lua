module("EntityVar", package.seeall)

Vars = Vars or {}
Store = Store or {}

local ENTITY = FindMetaTable("Entity")

function Add(name, data, metatable)
	metatable = metatable or "Entity"

	local meta = assert(FindMetaTable(metatable), "Attempt to add an entity var to nil metatable " .. metatable)

	if meta != ENTITY then
		assert(meta.MetaBaseClass == ENTITY, "Attempt to add an entity var to non-entity metatable " .. metatable)
	end

	data = {
		Name = name,
		Index = "e_" .. name,
		Default = data.Default,
		ServerOnly = tobool(data.ServerOnly)
	}

	Store[name] = Store[name] or {}
	Vars[name] = data

	local index = data.Index
	local default = data.Default
	local serverOnly = data.ServerOnly

	if serverOnly and CLIENT then
		return
	end

	local cache = Store[name]
	local hookName = "On" .. name .. "Changed"

	local get = function(ent)
		local value = cache[ent]

		if value == nil then
			return util.SafeCopy(data.Default)
		end

		return value
	end

	local set = function(ent, value, loading)
		local old = get(ent)
		cache[ent] = value
		local new = get(ent)

		if not istable(old) and new == old then
			return true
		end

		hook.Run(hookName, ent, old, new, loading)
	end

	meta[name] = get
	meta["Set" .. name] = function(ent, value, loading)
		if value == default then value = nil end

		if set(ent, value, loading) then
			return
		end

		if SERVER and not serverOnly and ent:EntIndex() > 0 then
			netstream.Send(nil, index, ent, value, loading)
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
			ent["Set" .. name](ent, value, true)
		end
	end)
else
	function Sync(ent, requester)
		local data = {}

		for name, var in pairs(Vars) do
			if var.ServerOnly then
				continue
			end

			data[name] = Store[name][ent]
		end

		if table.Count(data) > 0 then
			netstream.Send(requester, "BulkEntityVars", ent, data)
		end
	end
end
