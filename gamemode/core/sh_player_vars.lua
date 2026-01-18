module("PlayerVar", package.seeall)

Vars = Vars or {}
Fields = Fields or {}

local PLAYER = FindMetaTable("Player")

function Add(name, data)
	local databaseType = data.DataType or BLOB()

	netvar.Add(name, data)

	data = {
		Name = name,
		Default = data.Default,
		-- Database persistence
		Persist = tobool(data.Persist),
		Field = data.Field or name,
		DataType = databaseType.DataType,
		Validate = data.Validate or databaseType.Validate,
		Encode = data.Encode or databaseType.Encode,
		Decode = data.Decode or databaseType.Decode,
		DatabaseIndex = tobool(data.DatabaseIndex)
	}

	Vars[name] = data

	if data.Persist then
		Fields[data.Field] = data
	end

	if data.ServerOnly and CLIENT then
		return
	end

	local validation = data.Validate

	PLAYER[name] = function(ply, raw) return netvar.Get(ply, name, raw) end
	PLAYER["Set" .. name] = function(ply, value, loading)
		if validation and value != nil and not validation(value) then
			error(string.format("Set value '%s' doesn't match database type %s", value, data.DataType), 2)
		end

		if netvar.Set(ply, name, value, loading) then
			return
		end

		if SERVER and data.Persist and not loading then
			async.Start(function()
				Data.Player.Write(ply:SteamID(), {
					[name] = (value == nil) and NULL or value
				})
			end)
		end
	end
end
