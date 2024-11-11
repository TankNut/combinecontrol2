module("PlayerVars", package.seeall)

Vars = Vars or {}
Fields = Fields or {}

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

	Vars[name] = data

	local index = data.Index
	local default = data.Default
	local private = data.Private
	local serverOnly = data.ServerOnly
	local persist = data.Persist
	local dataType = data.DataType
	local validate = data.Validate

	local hookName = "Player" .. name .. "Changed"

	if persist then
		Fields[data.Field] = data
	end

	if serverOnly and CLIENT then
		return
	end

	meta[name] = function(ply)
		local var = ply[index]

		return var == nil and default or var
	end

	meta["Set" .. name] = function(ply, val, loading)
		if validate and not validate(val) then
			error(string.format("Set value '%s' doesn't match database type %s", val, dataType), 2)
		end

		local old = ply[index]

		ply[index] = val

		hook.Run(hookName, ply, old, val, loading)

		if SERVER then
			if persist and not loading then
				Save(ply:SteamID(), data, val)
			end

			if not serverOnly then
				netstream.Send(private and ply or nil, index, ply, val)
			end
		end
	end

	if CLIENT then
		netstream.Hook(index, function(ply, val)
			ply[index] = val

			hook.Run(hookName, ply, old, val)
		end)
	end
end

if SERVER then
	function Save(steamid, var, val)
		async.Start(function()
			local query = GAMEMODE.Database:Update("rp_players")

			if val == nil then
				query:Null(var.Field)
			else
				val = var.DataType == "BLOB" and sfs.encode(val) or val

				query:Update(var.Field, val)
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

		for field, val in pairs(data) do
			local var = Fields[field]

			if not var then
				continue
			end

			if var.DataType == "BLOB" then
				val = sfs.decode(val)
			end

			ply["Set" .. var.Name](ply, val, true)
		end
	end
end
