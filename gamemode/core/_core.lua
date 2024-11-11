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





hook.Add("InitPostEntity", "combinecontrol", function()
	hook.Run("LoadDatabase")
end)
GM:Include("sh_helpers.lua")
GM:Include("sh_player_vars.lua")

hook.Add("LuapadCanRunCL", "combinecontrol", function(ply)
	return ply:IsDeveloper()
end)
GM:Include("sh_admin.lua")
GM:Include("sv_player.lua")
GM:Include("sv_database.lua")

hook.Add("LuapadCanRunSV", "combinecontrol", function(ply)
	return ply:IsDeveloper()
end)
