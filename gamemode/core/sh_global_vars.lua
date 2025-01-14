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

	GM[name] = function()
		return Store[name] or util.SafeCopy(default)
	end

	GM["Set" .. name] = function(_, val, loading)
		if val == default then val = nil end

		local old = Store[name]

		Store[name] = val

		hook.Run(hookName, old, val == nil and default or val, loading)

		if SERVER then
			netstream.Broadcast(index, val, loading)
		end
	end

	if CLIENT then
		netstream.Hook(index, function(val, loading)
			local old = Store[name]

			Store[name] = val

			hook.Run(hookName, old, val == nil and default or val, loading)
		end)
	end
end

if CLIENT then
	netstream.Hook("BulkGlobalVars", function(data)
		for name, val in pairs(data) do
			GAMEMODE["Set" .. name](GAMEMODE, val, true)
		end
	end)
else
	function Sync(ply)
		netstream.Send(ply, "BulkGlobalVars", Store)
	end
end
