local prefixes = {
	["sh_"] = shared,
	["cl_"] = client,
	["cc_"] = client,
	["gui_"] = client,
	["sv_"] = server
}

function GM:Include(path)
	local filename = string.Filename(path)

	for prefix, func in pairs(prefixes) do
		if string.sub(filename, 1, #prefix) == prefix then
			return func(path)
		end
	end

	return shared(path)
end

function GM:IncludeFolder(dir, entrypoint)
	file.Iterate(dir, entrypoint, "LUA", function(path)
		self:Include(path)
	end)
end

function GM:IncludeRecursive(dir, entrypoint)
	file.IterateRecursive(dir, entrypoint, "LUA", function(path)
		self:Include(path)
	end)
end

-- First section of includes is stuff with a specific load order, the second one is sorted alphabetically
GM:Include("sh_helpers.lua")
GM:Include("sh_player_vars.lua")
GM:Include("sh_character_vars.lua")
GM:Include("sh_global_vars.lua")
GM:Include("sh_entity_vars.lua")
GM:Include("sh_settings.lua")
GM:Include("sh_entity_cache.lua")
GM:Include("cl_fonts.lua")

GM:Include("cl_ambience.lua")
GM:Include("cl_spawnmenu.lua")
GM:Include("cl_view.lua")
GM:Include("cl_weaponselect.lua")

GM:Include("sh_actions.lua")
GM:Include("sh_admin.lua")
GM:Include("sh_animations.lua")
GM:Include("sh_appearance.lua")
GM:Include("sh_attachment.lua")
GM:Include("sh_badge.lua")
GM:Include("sh_binds.lua")
GM:Include("sh_buff.lua")
GM:Include("sh_buttons.lua")
GM:Include("sh_character_create.lua")
GM:Include("sh_character_flags.lua")
GM:Include("sh_character_gen.lua")
GM:Include("sh_character.lua")
GM:Include("sh_chat.lua")
GM:Include("sh_console.lua")
GM:Include("sh_content.lua")
GM:Include("sh_context.lua")
GM:Include("sh_dev.lua")
GM:Include("sh_doors.lua")
GM:Include("sh_entity.lua")
GM:Include("sh_hud.lua")
GM:Include("sh_hull.lua")
GM:Include("sh_inventory.lua")
GM:Include("sh_item.lua")
GM:Include("sh_language.lua")
GM:Include("sh_logging.lua")
GM:Include("sh_modeldata.lua")
GM:Include("sh_permaprops.lua")
GM:Include("sh_permissions.lua")
GM:Include("sh_player.lua")
GM:Include("sh_plugins.lua")
GM:Include("sh_propprotection.lua")
GM:Include("sh_ragdoll.lua")
GM:Include("sh_sandbox.lua")
GM:Include("sh_stash.lua")
GM:Include("sh_teams.lua")
GM:Include("sh_think.lua")

GM:Include("sv_access.lua")
GM:Include("sv_bots.lua")
GM:Include("sv_character.lua")
GM:Include("sv_data_character.lua")
GM:Include("sv_data_player.lua")
GM:Include("sv_data.lua")
GM:Include("sv_database.lua")
GM:Include("sv_item.lua")
GM:Include("sv_logging.lua")
GM:Include("sv_luapad.lua")
GM:Include("sv_npc.lua")
GM:Include("sv_player_update.lua")
GM:Include("sv_player.lua")
GM:Include("sv_resource.lua")
GM:Include("sv_worldents.lua")

GM:IncludeFolder(CoreFolder .. "ctp/")

GM:IncludeRecursive(CoreFolder .. "meta/", "shared.lua")
GM:IncludeRecursive(CoreFolder .. "vgui/")
GM:IncludeRecursive(CoreFolder .. "gui/")

GM:IncludeFolder(CoreFolder .. "actions/")

hook.Call("RegisterContent", GM, CoreFolder)

GM:LoadPlugins()

GM:Include(ContentFolder .. "_content.lua")

function GM:Initialize()
	if CLIENT then
		RunConsoleCommand("cl_showhints", 0)
	else
		RunConsoleCommand("sv_allowupload", 0)
		RunConsoleCommand("sv_allowdownload", 0)

		RunConsoleCommand("combine_spawn_health", 0)
		RunConsoleCommand("combine_guard_spawn_health", 0)

		concommand.Remove("gm_save")
		concommand.Add("gm_save", function(ply) end)
	end
end

function GM:OnReloaded()
	if CLIENT then
		if not self.NextReloadSound then
			self.NextReloadSound = 0
		end

		if CurTime() > self.NextReloadSound then
			surface.PlaySound("buttons/combine_button1.wav")
			self.NextReloadSound = CurTime() + 1
		end

		Hud.Clear()
		Hud.Rebuild()

		hook.Run("CreateFonts")
	end

	self.BaseClass:OnReloaded()

	Item.OnReloaded()
	ModelData.ClearCache()

	if CLIENT then
		derma.RefreshSkins()
		Chat.Create()
	end
end

if CLIENT then
	function GM:OnScreenSizeChanged()
		Hud.Clear()
		Hud.Rebuild()

		hook.Run("CreateFonts")
	end
end
