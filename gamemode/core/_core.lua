-- Starting off fresh

function GM:Include(path)
	local realm = string.Left(string.FileName(path), 3)

	if realm == "cl_" or realm == "cc_" then
		return self:IncludeClient(path)
	elseif realm == "sv_" then
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

function GM:LoadContent()
	Badge.Load()
	Language.Load()

	CharacterFlag.Load()
	CharCreate.Load()
	Chat.Load()
	Item.Load()
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

GM:Include("cl_think.lua")
GM:Include("cl_vgui.lua")
GM:Include("sh_admin.lua")
GM:Include("sh_appearance.lua")
GM:Include("sh_badge.lua")
GM:Include("sh_binds.lua")
GM:Include("sh_character_flags.lua")
GM:Include("sh_character.lua")
GM:Include("sh_charcreate.lua")
GM:Include("sh_chat.lua")
GM:Include("sh_entity.lua")
GM:Include("sh_global.lua")
GM:Include("sh_hull.lua")
GM:Include("sh_inventory.lua")
GM:Include("sh_item.lua")
GM:Include("sh_language.lua")
GM:Include("sh_player.lua")
GM:Include("sh_propprotection.lua")
GM:Include("sh_sandbox.lua")
GM:Include("sv_character.lua")
GM:Include("sv_database.lua")
GM:Include("sv_item.lua")
GM:Include("sv_player_update.lua")
GM:Include("sv_player.lua")
GM:Include("sv_resource.lua")

local baseFolder = engine.ActiveGamemode() .. "/gamemode/"

GM:LoadFolder(baseFolder .. "core/meta/", "shared.lua")
GM:LoadFolder(baseFolder .. "core/vgui/")
GM:LoadFolder(baseFolder .. "core/gui/")
GM:LoadFolder(baseFolder .. "core/plugins/", "_plugin.lua")

BuildPluginFolders()

GM:Include(baseFolder .. "content/_content.lua")

hook.Call("LoadContent", GM)

function GM:OnReloaded()
	if CLIENT then
		if not self.NextReloadSound then
			self.NextReloadSound = 0
		end

		if CurTime() > self.NextReloadSound then
			surface.PlaySound("buttons/combine_button1.wav")
			self.NextReloadSound = CurTime() + 1
		end
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
