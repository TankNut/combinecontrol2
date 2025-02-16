-- Starting off fresh

local prefixes = {
	["cl_"] = "client",
	["cc_"] = "client",
	["gui_"] = "client",
	["sv_"] = "server"
}

function GM:Include(path)
	local filename = string.FileName(path)
	local includeRealm = "shared"

	for prefix, realm in pairs(prefixes) do
		if string.sub(filename, 1, #prefix) == prefix then
			includeRealm = realm

			break
		end
	end

	if includeRealm == "client" then
		return self:IncludeClient(path)
	elseif includeRealm == "server" then
		return self:IncludeServer(path)
	end

	return self:IncludeShared(path)
end

function GM:IncludeClient(path)
	if CLIENT then
		return include(path)
	else
		AddCSLuaFile(path)
	end
end

function GM:IncludeShared(path)
	AddCSLuaFile(path)
	return include(path)
end

function GM:IncludeServer(path)
	if SERVER then
		return include(path)
	end
end

function GM:LoadFolder(dir, subFile)
	file.Iterate(dir, subFile, "LUA", function(path)
		self:Include(path)
	end)
end

-- First section of includes is stuff with a specific load order, the second one is sorted alphabetically
--GM:Include("enums.lua")
--GM:Include("sh_config.lua")
GM:Include("sh_helpers.lua")
GM:Include("sh_player_vars.lua")
GM:Include("sh_character_vars.lua")
GM:Include("sh_global_vars.lua")
GM:Include("sh_entity_vars.lua")
GM:Include("sh_settings.lua")

GM:Include("cl_scribe.lua")
GM:Include("cl_vgui.lua")
GM:Include("cl_view.lua")
GM:Include("cl_weaponselect.lua")
GM:Include("sh_admin.lua")
GM:Include("sh_appearance.lua")
GM:Include("sh_badge.lua")
GM:Include("sh_binds.lua")
GM:Include("sh_bot.lua")
GM:Include("sh_buff.lua")
GM:Include("sh_character_flags.lua")
GM:Include("sh_character.lua")
GM:Include("sh_charcreate.lua")
GM:Include("sh_chat.lua")
GM:Include("sh_console.lua")
GM:Include("sh_entity.lua")
GM:Include("sh_hud.lua")
GM:Include("sh_hull.lua")
GM:Include("sh_inventory.lua")
GM:Include("sh_item.lua")
GM:Include("sh_language.lua")
GM:Include("sh_permaprops.lua")
GM:Include("sh_player.lua")
GM:Include("sh_propprotection.lua")
GM:Include("sh_ragdoll.lua")
GM:Include("sh_sandbox.lua")
GM:Include("sh_think.lua")
GM:Include("sv_character.lua")
GM:Include("sv_database.lua")
GM:Include("sv_item.lua")
GM:Include("sv_luapad.lua")
GM:Include("sv_player_update.lua")
GM:Include("sv_player.lua")
GM:Include("sv_resource.lua")

local baseFolder = engine.ActiveGamemode() .. "/gamemode/"

GM:LoadFolder(baseFolder .. "core/ctp/")
GM:LoadFolder(baseFolder .. "core/meta/", "shared.lua")
GM:LoadFolder(baseFolder .. "core/vgui/")
GM:LoadFolder(baseFolder .. "core/gui/")

GM:Include(baseFolder .. "content/_content.lua")

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
	end

	self.BaseClass:OnReloaded()

	Item.OnReloaded()

	if CLIENT then
		derma.RefreshSkins()
		Chat.Create()
	end
end


function GM:OnGamemodeLoaded()
	if CLIENT then
		Chat.Create()
	end
end
