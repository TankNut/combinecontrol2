MsgC(Color(200, 200, 200, 255), "Loading clientside...\n")

GM.FullyLoaded = GM.FullyLoaded or false
GM.Config = GM.Config or {}

if not CCP then
	CCP = {} -- CombineControl Panels.
end

include("sh_enum.lua")
include("sh_fixes.lua")

include("core/enums.lua")
include("core/sh_config.lua")
include("config/cl_motd.lua")
include("config/sh_config.lua")

include("sh_utils.lua")

include("shared.lua")

include("sh_includes.lua")
include("sh_logging.lua")
include("sh_admin.lua")
include("sh_animation.lua")
include("sh_entity.lua")
include("sh_file.lua")
include("sh_player.lua")
include("sh_playsounds.lua")
include("sh_sandbox.lua")
include("sh_pon.lua")
include("sh_utils.lua")
include("sh_weapons.lua")
include("sh_sound.lua")

include("cl_logging.lua")
include("cl_admin.lua")
include("cl_adminmenu.lua")
include("cl_binds.lua")
include("cl_context.lua")
include("cl_hud.lua")
include("cl_music.lua")
include("cl_player.lua")
include("cl_playsounds.lua")
include("cl_playurl.lua")
include("cl_fonts.lua")

IncludeFolder(GM.FolderName .. "/gamemode/gui")
IncludeFolder(GM.FolderName .. "/gamemode/logtypes")

include("core/_core.lua")

function GM:Initialize()
	RunConsoleCommand("cl_showhints", "0")
end

hook.Add("OnEntityCreated", "CL.Init.OnEntityCreated", function(ent)
	if ent:IsPlayer() then
		if ent != LocalPlayer() then

			net.Start("nRequestPlayerData")
				net.WriteEntity(ent)
			net.SendToServer()
		end
	elseif ent:IsDoor() then
		GAMEMODE.EntityTable.door[table.Count(GAMEMODE.EntityTable.door)] = ent
	elseif ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_effect" then
		GAMEMODE.EntityTable.prop[table.Count(GAMEMODE.EntityTable.prop)] = ent
	elseif ent:GetClass() == "cc_item" then
		GAMEMODE.EntityTable.item[table.Count(GAMEMODE.EntityTable.item)] = ent
	elseif ent:GetClass() == "cc_paper" then
		GAMEMODE.EntityTable.paper[table.Count(GAMEMODE.EntityTable.paper)] = ent
	elseif string.StartWith(ent:GetClass(), "npc_") then
		GAMEMODE.EntityTable.npc[table.Count(GAMEMODE.EntityTable.npc)] = ent
	end

	if Settings.Get("Thirdperson") then
		ctp:Enable()
	end
end)

function UIAutoClose(panel)
	if cookie.GetNumber("cc_escapemenuclose", 1) == 1 and input.IsKeyDown(KEY_ESCAPE) and panel:IsActive() then
		panel:Close()
		gui.HideGameUI()

		GAMEMODE.CursorItem = nil
	end
end

GM.FullyLoaded = true

MsgC(Color(200, 200, 200, 255), "Clientside loaded.\n")
