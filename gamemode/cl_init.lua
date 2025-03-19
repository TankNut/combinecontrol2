GM.Config = GM.Config or {}

if not CCP then
	CCP = {} -- CombineControl Panels.
end

include("sh_enum.lua")

include("core/enums.lua")
include("core/sh_config.lua")
include("config/cl_motd.lua")
include("config/sh_config.lua")
include("cl_skin.lua")

include("sh_utils.lua")

include("shared.lua")

include("sh_player.lua")
include("sh_weapons.lua")

include("cl_hud.lua")

include("core/_core.lua")

function GM:Initialize()
	RunConsoleCommand("cl_showhints", "0")
end

hook.Add("OnEntityCreated", "CL.Init.OnEntityCreated", function(ent)
	if ent:IsPlayer() and ent != lp then
		net.Start("nRequestPlayerData")
			net.WriteEntity(ent)
		net.SendToServer()
	end
end)

function UIAutoClose(panel)
	if cookie.GetNumber("cc_escapemenuclose", 1) == 1 and input.IsKeyDown(KEY_ESCAPE) and panel:IsActive() then
		panel:Close()
		gui.HideGameUI()

		GAMEMODE.CursorItem = nil
	end
end
