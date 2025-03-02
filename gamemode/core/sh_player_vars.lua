module("PlayerVar", package.seeall)

Vars = Vars or {}
Fields = Fields or {}
Store = Store or {}

local PLAYER = FindMetaTable("Player")

function Add(name, data)
	local databaseType = data.DataType or BLOB()

	data = {
		Name = name,
		Index = "p_" .. name,
		Default = data.Default,
		Private = tobool(data.Private),
		ServerOnly = tobool(data.ServerOnly),
		-- Database persistence
		Persist = tobool(data.Persist),
		Field = data.Field or name,
		DataType = databaseType.DataType,
		Validate = data.Validate or databaseType.Validate,
		Encode = data.Encode or databaseType.Encode,
		Decode = data.Decode or databaseType.Decode,
		DatabaseIndex = tobool(data.DatabaseIndex)
	}

	Store[name] = Store[name] or {}
	Vars[name] = data

	local index = data.Index
	local default = data.Default
	local private = data.Private
	local serverOnly = data.ServerOnly
	local persist = data.Persist
	local dataType = data.DataType
	local validate = data.Validate

	local cache = Store[name]
	local hookName = "On" .. name .. "Changed"

	if persist then
		Fields[data.Field] = data
	end

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
			if persist and not loading then
				Save(ply:SteamID(), data, value)
			end

			if not serverOnly then
				netstream.Send(private and ply or nil, index, ply, value, loading)
			end
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
	netstream.Hook("BulkPlayerVars", function(ply, data)
		for name, value in pairs(data) do
			ply["Set" .. name](ply, value, true)
		end
	end)
else
	function GetOffline(steamid, name)
		local ply = player.GetBySteamID(steamid)

		if ply then
			return ply[name](ply)
		end

		local data = assert(Vars[name], name .. " is not a valid player var")

		local query = GAMEMODE.Database:Select("rp_players")
			query:Select(data.Field)
			query:WhereEqual("SteamID", steamid)
		local value = query:Execute()[1]

		if value then
			value = value[data.Field]
		else
			return util.SafeCopy(data.Default)
		end

		return data.Decode and data.Decode(value) or value
	end

	function SetOffline(steamid, name, value)
		local ply = player.GetBySteamID(steamid)

		if ply then
			ply["Set" .. name](ply, value)

			return
		end

		local data = assert(Vars[name], name .. " is not a valid player var")

		local default = data.Default
		local persist = assert(data.Persist, "Cannot SetOffline non-persist player vars")
		local dataType = data.DataType
		local validate = data.Validate

		if not persist then
			return
		end

		if value == default then value = nil end

		if validate and value != nil and not validate(value) then
			error(string.format("Set value '%s' doesn't match database type %s", value, dataType), 2)
		end

		Save(steamid, data, value)
	end

	function Sync(ply, requester)
		local data = {}

		for name, var in pairs(Vars) do
			if (var.Private and ply != requester) or var.ServerOnly then
				continue
			end

			data[name] = Store[name][ply]
		end

		if table.Count(data) > 0 then
			netstream.Send(requester, "BulkPlayerVars", ply, data)
		end
	end

	function Save(steamid, var, value)
		async.Start(function()
			local query = GAMEMODE.Database:Upsert("rp_players")
				query:Insert("SteamID", steamid)

			if value == nil then
				query:InsertRaw(var.Field, "NULL")
			else
				value = var.Encode and var.Encode(value) or value

				query:Insert(var.Field, value)
			end

			query:Execute()
		end)
	end

	function Load(ply)
		local steamid = ply:SteamID()
		local query

		query = GAMEMODE.Database:InsertIgnore("rp_players")
			query:Insert("SteamID", steamid)
		query:Execute()

		query = GAMEMODE.Database:Select("rp_players")
			query:WhereEqual("SteamID", steamid)
		local data = query:Execute()[1]

		for field, value in pairs(data) do
			local var = Fields[field]

			if not var then
				continue
			end

			if var.Decode then
				value = var.Decode(value)
			end

			ply["Set" .. var.Name](ply, value, true)
		end
	end
end
