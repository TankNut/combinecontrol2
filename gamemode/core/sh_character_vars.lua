module("CharacterVar", package.seeall)

Vars = Vars or {}
Store = Store or {}

local meta = FindMetaTable("Player")

function Add(name, data)
	local databaseType = data.DataType or BLOB()

	data = {
		Name = name,
		Index = "c_" .. name,
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
	local hookName = "Character" .. name .. "Changed"

	if serverOnly and CLIENT then
		return
	end

	meta["Character" .. name] = function(ply)
		local val = cache[ply]

		return val == nil and default or val
	end

	meta["SetCharacter" .. name] = function(ply, val, loading)
		if validate and not validate(val) then
			error(string.format("Set value '%s' doesn't match database type %s", val, dataType), 2)
		end

		local old = cache[ply]
		local hookVal = val == nil and default or val

		cache[ply] = val

		hook.Run(hookName, ply, old, hookVal, loading)

		if SERVER then
			if persist and not loading then
				Save(ply:CharID(), data, val)
			end

			if not serverOnly then
				netstream.Send(private and ply or nil, index, ply, val, loading)
			end
		end
	end

	if CLIENT then
		netstream.Hook(index, function(ply, val, loading)
			cache[ply] = val

			hook.Run(hookName, ply, old, val == nil and default or val, loading)
		end)
	end
end

function Clear(ply)
	for _, players in pairs(Store) do
		players[ply] = nil
	end
end

if SERVER then
	function Save(id, var, val)
		async.Start(function()
			local query = GAMEMODE.Database:Update("rp_characters")

			if val == nil then
				query:UpdateRaw(var.Field, "NULL")
			else
				val = var.DataType == "BLOB" and sfs.encode(val) or val

				query:Update(var.Field, val)
			end

			query:WhereEquals("id", id)
			query:Execute()
		end)
	end
end
