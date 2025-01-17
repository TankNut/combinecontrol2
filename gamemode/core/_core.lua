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

function GM:LoadFolder(path, subFile)
	path = string.format("%s/gamemode/%s/", engine.ActiveGamemode(), path)

	local files, folders = file.Find(path .. "*", "LUA")

	for _, filePath in ipairs(files) do
		if string.GetExtensionFromFilename(filePath) != "lua" then
			continue
		end

		self:Include(path .. filePath)
	end

	if subFile then
		for _, folderPath in ipairs(folders) do
			self:IncludeShared(string.format("%s%s/%s", path, folderPath, subFile))
		end
	end
end

function GM:LoadContent()
	Language.Load()

	CharacterFlag.Load()
	CharCreate.Load()
	Chat.Load()
	Item.Load()
end

-- First section of includes is stuff with a specific load order, the second one is sorted alphabetically
GM:Include("enums.lua")
--GM:Include("sh_config.lua")
GM:Include("sh_helpers.lua")
GM:Include("sh_player_vars.lua")
GM:Include("sh_character_vars.lua")
GM:Include("sh_global_vars.lua")

GM:Include("cl_think.lua")
GM:Include("cl_vgui.lua")
GM:Include("sh_admin.lua")
GM:Include("sh_appearance.lua")
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
GM:Include("sh_sandbox.lua")
GM:Include("sv_character.lua")
GM:Include("sv_database.lua")
GM:Include("sv_item.lua")
GM:Include("sv_player_update.lua")
GM:Include("sv_player.lua")

GM:LoadFolder("core/meta", "shared.lua")
GM:LoadFolder("core/vgui")
GM:LoadFolder("core/gui")
GM:LoadFolder("core/plugins", "_plugin.lua")

local contentFolder = engine.ActiveGamemode() .. "/gamemode/content/"

GM:Include(contentFolder .. "sh_defines.lua")
GM:Include(contentFolder .. "sh_names.lua")

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
