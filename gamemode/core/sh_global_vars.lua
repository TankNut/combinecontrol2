module("GlobalVar", package.seeall)

Vars = Vars or {}
Fields = Fields or {}
Store = Store or {}

local logger = log.Create("vars")

function Add(name, data)
	data = {
		Name = name,
		Index = "g_" .. name,
		Default = data.Default,
		ServerOnly = tobool(data.ServerOnly),
		-- Database persistence
		Persist = tobool(data.Persist),
		Mode = data.Mode or GLOBALVAR_ALWAYS,
		Field = data.Field or name
	}

	Vars[name] = data

	local index = data.Index
	local default = data.Default
	local persist = data.Persist
	local serverOnly = data.ServerOnly

	if serverOnly and CLIENT then
		return
	end

	local hookName = "On" .. name .. "Changed"

	if persist then
		Fields[data.Field] = data
	end

	local get = function(_, raw)
		local value = Store[name]

		if raw then
			return value
		elseif value == nil then
			return util.SafeCopy(data.Default)
		end

		return value
	end

	local set = function(value, loading)
		logger:Debug("Set: Global.%s", name)

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

			if not serverOnly then
				netstream.Broadcast(index, value, loading)
			end
		end
	end

	if CLIENT then
		netstream.Hook(index, set)
	end
end

if CLIENT then
	netstream.Hook("BulkGlobalVars", function(data)
		logger:Info("Received %s bulk global vars", table.Count(data))

		for name, value in pairs(data) do
			GAMEMODE["Set" .. name](GAMEMODE, value, true)
		end
	end)
else
	function Sync(ply)
		local data = {}

		for name, var in pairs(Vars) do
			if var.ServerOnly then
				continue
			end

			data[name] = Store[name]
		end

		if table.Count(data) > 0 then
			netstream.Send(ply, "BulkGlobalVars", data)
		end
	end

	function Save(var, value)
		async.Start(function()
			local query
			local map = ""

			if var.Mode == GLOBALVAR_MAP then
				map = game.GetMapoverride()
			elseif var.Mode == GLOBALVAR_MAP_NO_OVERRIDE then
				map = game.GetMap()
			end

			if value == nil then
				query = GAMEMODE.Database:Delete("rp_globals")

				query:WhereEqual("Map", map)
				query:WhereEqual("Key", var.Field)
			else
				query = GAMEMODE.Database:Upsert("rp_globals")

				query:Insert("Map", map)
				query:Insert("Key", var.Field)
				query:Insert("Value", sfs.encode(value))
			end

			query:Execute()
		end)
	end

	function Load(ply)
		local query = GAMEMODE.Database:Select("rp_globals")

		query:WhereIn("Map", {game.GetMap(), game.GetMapOverride(), ""})

		for _, data in ipairs(query:Execute()) do
			local var = Fields[data.Key]

			if not var then
				continue
			end

			GAMEMODE["Set" .. var.Name](GAMEMODE, sfs.decode(data.Value), true)
		end
	end
end
