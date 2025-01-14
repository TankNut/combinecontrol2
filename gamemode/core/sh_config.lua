module("Config", package.seeall)

-- Bit basic but it's cleaner and lets us easily change stuff later on
function Get(key)
	local config = (GM or GAMEMODE).Config

	return config[key]
end
