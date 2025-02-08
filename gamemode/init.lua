MsgC(Color(200, 200, 200, 255), "Loading serverside...\n")

GM.FullyLoaded = GM.FullyLoaded or false
GM.Config = GM.Config or {}

include("sh_enum.lua")
include("sh_fixes.lua")

include("core/enums.lua")
include("core/sh_config.lua")
include("config/sv_config.lua")
include("config/sh_config.lua")

include("sh_utils.lua")

include("config/motd.lua")
include("shared.lua")

include("sh_includes.lua")
include("sh_logging.lua")
include("sh_admin.lua")
include("sh_animation.lua")
include("sh_consciousness.lua")
include("sh_entity.lua")
include("sh_file.lua")
include("sh_player.lua")
include("sh_playsounds.lua")
include("sh_sandbox.lua")
include("sh_pon.lua")
include("sh_weapons.lua")
include("sh_sound.lua")

include("sv_logging.lua")
include("sv_admin.lua")
include("sv_business.lua")
include("sv_context.lua")
include("sv_logs.lua")
include("sv_net.lua")
include("sv_map.lua")
include("sv_player.lua")
include("sv_playsounds.lua")
include("sv_security.lua")
include("sv_sql.lua")
include("sv_think.lua")
include("sv_weapon.lua")
include("sv_worldents.lua")

AddCSLuaFile("cl_init.lua")

AddCSLuaFile("sh_enum.lua")
AddCSLuaFile("sh_fixes.lua")
AddCSLuaFile("sh_utils.lua")

AddCSLuaFile("core/enums.lua")
AddCSLuaFile("core/sh_config.lua")
AddCSLuaFile("config/sh_config.lua")
AddCSLuaFile("config/motd.lua")
AddCSLuaFile("shared.lua")

AddCSLuaFile("sh_includes.lua")
AddCSLuaFile("sh_logging.lua")
AddCSLuaFile("sh_admin.lua")
AddCSLuaFile("sh_animation.lua")
AddCSLuaFile("sh_consciousness.lua")
AddCSLuaFile("sh_entity.lua")
AddCSLuaFile("sh_file.lua")
AddCSLuaFile("sh_player.lua")
AddCSLuaFile("sh_playsounds.lua")
AddCSLuaFile("sh_sandbox.lua")
AddCSLuaFile("sh_pon.lua")
AddCSLuaFile("sh_weapons.lua")
AddCSLuaFile("sh_sound.lua")

AddCSLuaFile("cl_logging.lua")
AddCSLuaFile("cl_admin.lua")
AddCSLuaFile("cl_adminmenu.lua")
AddCSLuaFile("cl_binds.lua")
AddCSLuaFile("cl_charcreate.lua")
AddCSLuaFile("cl_context.lua")
AddCSLuaFile("cl_help.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_map.lua")
AddCSLuaFile("cl_music.lua")
AddCSLuaFile("cl_player.lua")
AddCSLuaFile("cl_playermenu.lua")
AddCSLuaFile("cl_playsounds.lua")
AddCSLuaFile("cl_playurl.lua")
AddCSLuaFile("cl_resource.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("cl_fonts.lua")
AddCSLuaFile("cl_weapon.lua")

--ctp
include( "ctp/sv_ctp.lua");
AddCSLuaFile( "ctp/cl_ctp.lua" );

IncludeFolder(GM.FolderName .. "/gamemode/gui")
IncludeFolder(GM.FolderName .. "/gamemode/logtypes")

AddCSLuaFile("core/_core.lua")
include("core/_core.lua")

function GM:Initialize()
	game.ConsoleCommand("net_maxfilesize 64\n")
	game.ConsoleCommand("sv_kickerrornum 0\n")

	game.ConsoleCommand("sv_allowupload 0\n")
	game.ConsoleCommand("sv_allowdownload 0\n")

	game.ConsoleCommand("sk_antlion_worker_spit_grenade_dmg 100\n")

	concommand.Remove("gm_save")

	concommand.Add("gm_save", function(ply)
		GAMEMODE:LogSecurity(ply:SteamID(), "n/a", ply:VisibleRPName(), "Tried to run command gm_save!")
	end)

	self:InitSQL()

	self:SetupDataDirectories()
	self:LoadBans()

	timer.Create("LoadBans", 60, 0, function()

		GAMEMODE:LoadBans()

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

	self:LogAll("Server started on map: " .. game.GetMap())
end

GM.FullyLoaded = true

MsgC(Color(200, 200, 200, 255), "Serverside loaded.\n")
