GM.Config = GM.Config or {}

include("sh_enum.lua")

include("core/enums.lua")
include("core/sh_config.lua")
include("config/sv_config.lua")
include("config/sh_config.lua")

include("sh_utils.lua")

include("shared.lua")

include("sh_animation.lua")
include("sh_player.lua")
include("sh_weapons.lua")

include("sv_net.lua")
include("sv_player.lua")

AddCSLuaFile("cl_init.lua")

AddCSLuaFile("sh_enum.lua")
AddCSLuaFile("sh_utils.lua")

AddCSLuaFile("core/enums.lua")
AddCSLuaFile("core/sh_config.lua")
AddCSLuaFile("config/cl_motd.lua")
AddCSLuaFile("config/sh_config.lua")
AddCSLuaFile("cl_skin.lua")

AddCSLuaFile("shared.lua")

AddCSLuaFile("sh_animation.lua")
AddCSLuaFile("sh_player.lua")
AddCSLuaFile("sh_weapons.lua")

AddCSLuaFile("cl_binds.lua")
AddCSLuaFile("cl_hud.lua")

AddCSLuaFile("core/_core.lua")
include("core/_core.lua")

function GM:Initialize()
	game.ConsoleCommand("sv_allowupload 0\n")
	game.ConsoleCommand("sv_allowdownload 0\n")

	concommand.Remove("gm_save")

	concommand.Add("gm_save", function(ply)
	end)

	-- Auto map switch support for rpa_changelevel
	local port = game.GetPort()

	if not file.Exists("cc_maps", "DATA") then
		file.CreateDir("cc_maps")
	end

	if file.Exists("cc_maps/" .. port .. ".txt", "DATA") then
		local map = file.Read("cc_maps/" .. port .. ".txt", "DATA")

		if map and map != game.GetMap() and table.HasValue(game.GetMapList(), map) then
			self.AutoMapOverride = map
		end
	end
end
