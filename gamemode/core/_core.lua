-- Starting off fresh

function GM:Include(path)
	local realm = path:Left(3)

	if realm == "cl_" then
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

function GM:LoadFolder(path)
	path = string.format("%s/gamemode/%s/", engine.ActiveGamemode(), path)

	local files, folders = file.Find(path .. "*.lua", "LUA")

	for _, v in ipairs(files) do
		self:Include(path .. v)
	end

	for _, v in ipairs(folders) do
		self:IncludeShared(path .. v .. "/_plugin.lua")
	end
end

-- First section of includes is stuff with a specific load order, the second one is sorted alphabetically
GM:Include("sh_helpers.lua")
GM:Include("sh_player_vars.lua")
GM:Include("sh_character_vars.lua")

GM:Include("cl_think.lua")
GM:Include("sh_admin.lua")
GM:Include("sh_character_flags.lua")
GM:Include("sh_character.lua")
GM:Include("sh_entity.lua")
GM:Include("sv_character.lua")
GM:Include("sv_database.lua")
GM:Include("sv_player.lua")

GM:LoadFolder("core/plugins")

CharacterFlag.Load()
