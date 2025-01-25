module("PlayerVar", package.seeall)

Vars = Vars or {}
Fields = Fields or {}
Store = Store or {}

local meta = FindMetaTable("Player")

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
		Validate = data.Validate or databaseType.Validate
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
		local old = get(ply)
		cache[ply] = value
		local new = get(ply)

		if not istable(old) and new == old then
			return true
		end

		hook.Run(hookName, ply, old, new, loading)
	end

	meta[name] = get
	meta["Set" .. name] = function(ply, value, loading)
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

	meta["SetTemp" .. name] = function(ply, value)
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
	netstream.Hook("BulkPlayerVars", function(ply, data)
		for name, value in pairs(data) do
			ply["Set" .. name](ply, value, true)
		end
	end)
else
	function Sync(ply, requester)
		local data = {}

		for var, players in pairs(Store) do
			data[var] = players[ply]
		end

		if #data > 0 then
			netstream.Send(requester, "BulkPlayerVars", ply, data)
		end
	end

	function Save(steamid, var, value)
		async.Start(function()
			local query = GAMEMODE.Database:Update("rp_players")

			if value == nil then
				query:UpdateRaw(var.Field, "NULL")
			else
				value = var.DataType == "BLOB" and sfs.encode(value) or value

				query:Update(var.Field, value)
			end

			query:WhereEqual("SteamID", steamid)
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

			if var.DataType == "BLOB" then
				value = sfs.decode(value)
			end

			ply["Set" .. var.Name](ply, value, true)
		end
	end
end
