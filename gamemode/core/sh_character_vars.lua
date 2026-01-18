module("CharacterVar", package.seeall)

Vars = Vars or {}

local PLAYER = FindMetaTable("Player")

function Add(name, data)
	local databaseType = data.DataType or BLOB()

	netvar.Add(name, data)

	data = {
		Name = name,
		Default = data.Default,
		-- Database persistence
		Persist = true,
		Field = data.Field or name,
		DataType = databaseType.DataType,
		Validate = data.Validate or databaseType.Validate,
		Encode = data.Encode or databaseType.Encode,
		Decode = data.Decode or databaseType.Decode,
		DatabaseIndex = tobool(data.DatabaseIndex)
	}

	Vars[name] = data

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

		local id = ply:CharID()

		if SERVER and not loading and id != 0 then
			async.Start(function()
				Data.Character.Write(id, {
					[name] = (value == nil) and NULL or value
				})
			end)
		end
	end
end
