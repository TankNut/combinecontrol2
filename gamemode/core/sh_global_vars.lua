module("GlobalVar", package.seeall)

Vars = Vars or {}
Store = Store or {}

function Add(name, data)
	data = {
		Name = name,
		Index = "g_" .. name,
		Default = data.Default
	}

	Vars[name] = data

	local index = data.Index
	local default = data.Default

	local hookName = "On" .. name .. "Changed"

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
		if value == default then value = nil end

		if set(value, loading) then
			return
		end

		if SERVER then
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
end
