module("CharacterVar", package.seeall)

Vars = Vars or {}
Store = Store or {}

local PLAYER = FindMetaTable("Player")

function Add(name, data)
	local databaseType = data.DataType or BLOB()

	data = {
		Name = name,
		Index = "c_" .. name,
		Default = data.Default,
		Private = tobool(data.Private),
		ServerOnly = tobool(data.ServerOnly),
		-- Database persistence
		Persist = true,
		Field = data.Field or name,
		DataType = databaseType.DataType,
		Validate = data.Validate or databaseType.Validate,
		Encode = data.Encode or databaseType.Encode,
		Decode = data.Decode or databaseType.Decode,
	}

	Store[name] = Store[name] or {}
	Vars[name] = data

	local index = data.Index
	local default = data.Default
	local private = data.Private
	local serverOnly = data.ServerOnly
	local dataType = data.DataType
	local validate = data.Validate

	local cache = Store[name]
	local hookName = "On" .. name .. "Changed"

	if serverOnly and CLIENT then
		return
	end

	local get = function(ply)
		local value = cache[ply]

		if value == nil then
			return util.SafeCopy(data.Default)
		end

		return value
	end

	local set = function(ply, value, loading)
		if not IsValid(ply) then
			return
		end

		local old = get(ply)
		cache[ply] = value
		local new = get(ply)

		if not istable(old) and new == old then
			return true
		end

		hook.Run(hookName, ply, old, new, loading)
	end

	PLAYER[name] = get
	PLAYER["Set" .. name] = function(ply, value, loading)
		assert(not isentity(value), "The var system does not support entities, use Get/SetNWEntity instead")

		if value == default then value = nil end

		if validate and value != nil and not validate(value) then
			error(string.format("Set value '%s' doesn't match database type %s", value, dataType), 2)
		end

		if set(ply, value, loading) then
			return
		end

		if SERVER then
			if not loading then
				Save(ply:CharID(), data, value)
			end

			if not serverOnly then
				netstream.Send(private and ply or nil, index, ply, value, loading)
			end
		end
	end

	PLAYER["SetTemp" .. name] = function(ply, value)
		if value == default then value = nil end

		if validate and value != nil and not validate(value) then
			error(string.format("Set value '%s' doesn't match database type %s", value, dataType), 2)
		end

		if set(ply, value) then
			return
		end

		if SERVER and not serverOnly then
			netstream.Send(private and ply or nil, index, ply, value)
		end
	end

	if CLIENT then
		netstream.Hook(index, set)
	end
end

function Clear(ply)
	for _, players in pairs(Store) do
		players[ply] = nil
	end
end

if CLIENT then
	netstream.Hook("BulkCharacterVars", function(ply, data)
		for name, value in pairs(data) do
			ply["Set" .. name](ply, value, true)
		end
	end)
else
	function Sync(ply, requester)
		local data = {}

		for name, var in pairs(Vars) do
			if (var.Private and ply != requester) or var.ServerOnly then
				continue
			end

			data[name] = Store[name][ply]
		end

		if table.Count(data) > 0 then
			netstream.Send(requester, "BulkCharacterVars", ply, data)
		end
	end

	function Save(id, var, value)
		if id == 0 then
			return
		end

		if id < 0 then
			Character.TempData[-id].Fields[var.Name] = value
		else
			async.Start(function()
				local query = GAMEMODE.Database:Update("rp_characters")

				if value == nil then
					query:UpdateRaw(var.Field, "NULL")
				else
					value = var.Encode and var.Encode(value) or value

					query:Update(var.Field, value)
				end

				query:WhereEqual("id", id)
				query:Execute()
			end)
		end
	end
end
