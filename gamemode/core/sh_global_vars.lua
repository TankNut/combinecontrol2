module("GlobalVar", package.seeall)

Vars = Vars or {}
Fields = Fields or {}
Store = Store or {}

function Add(name, data)
	data = {
		Name = name,
		Index = "g_" .. name,
		Default = data.Default,
		ServerOnly = tobool(data.ServerOnly),
		-- Database persistence
		Persist = tobool(data.Persist),
		MapBased = tobool(data.MapBased),
		Field = data.Field or name
	}

	Vars[name] = data

	local index = data.Index
	local default = data.Default
	local persist = data.Persist

	local hookName = "On" .. name .. "Changed"

	if persist then
		Fields[data.Field] = data
	end

	local get = function()
		local value = Store[name]

		if value == nil then
			return util.SafeCopy(data.Default)
		end

		return value
	end

	local set = function(value, loading)
		local old = get()
		Store[name] = value
		local new = get()

		if not istable(old) and new == old then
			return true
		end

		hook.Run(hookName, old, new, loading)
	end

	GM[name] = get
	GM["Set" .. name] = function(_, value, loading)
		assert(not isentity(value), "The var system does not support entities, use Get/SetNWEntity instead")

		if value == default then value = nil end

		if set(value, loading) then
			return
		end

		if SERVER then
			if persist and not loading then
				Save(data, value)
			end

			netstream.Broadcast(index, value, loading)
		end
	end

	if CLIENT then
		netstream.Hook(index, set)
	end
end

if CLIENT then
	netstream.Hook("BulkGlobalVars", function(data)
		for name, value in pairs(data) do
			GAMEMODE["Set" .. name](GAMEMODE, value, true)
		end
	end)
else
	function Sync(ply)
		netstream.Send(ply, "BulkGlobalVars", Store)
	end

	function Save(var, value)
		async.Start(function()
			local query

			if value == nil then
				query = GAMEMODE.Database:Delete("rp_globals")

				query:WhereEqual("Map", var.MapBased and game.GetMapOverride() or "")
				query:WhereEqual("Key", var.Field)
			else
				query = GAMEMODE.Database:Upsert("rp_globals")

				query:Insert("Map", var.MapBased and game.GetMapOverride() or "")
				query:Insert("Key", var.Field)
				query:Insert("Value", sfs.encode(value))
			end

			query:Execute()
		end)
	end

	function Load(ply)
		local query = GAMEMODE.Database:Select("rp_globals")

		query:WhereIn("Map", {game.GetMapOverride(), ""})

		for _, data in ipairs(query:Execute()) do
			local var = Fields[data.Key]

			if not var then
				continue
			end

			GAMEMODE["Set" .. var.Name](GAMEMODE, sfs.decode(data.Value), true)
		end
	end
end
