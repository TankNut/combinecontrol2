function CustomMetaTable(name)
	local meta = FindMetaTable(name)

	if not meta then
		meta = {}
		meta.__index = meta
		meta.__name = name

		RegisterMetaTable(name, meta)
	end

	return meta
end

if CLIENT then
	hook.Add("InitPostEntity", "globals", function()
		_G.lp = LocalPlayer()
	end)
end

stub = function() end

-- Sometimes you gotta
function jank(callback)
	timer.Simple(0, callback)
end

hook.Add("ShutDown", "globals", function()
	IsShuttingDown = true
end)
