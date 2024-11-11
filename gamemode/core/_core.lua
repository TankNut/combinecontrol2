-- Starting off fresh

function GM:IncludeClient(path)
	if CLIENT then
		include(path)
	else
		AddCSLuaFile(path)
	end
end

function GM:IncludeShared(path)
	AddCSLuaFile(path)
	include(path)
end

function GM:IncludeServer(path)
	if SERVER then
		include(path)
	end
end

GM:IncludeShared("sh_helpers.lua")

GM:IncludeShared("sh_player_vars.lua")

GM:IncludeServer("sv_database.lua")
GM:IncludeShared("sh_admin.lua")

GM:IncludeServer("sv_player.lua")

hook.Add("InitPostEntity", "combinecontrol", function()
	hook.Run("LoadDatabase")
end)

hook.Add("LuapadCanRunCL", "combinecontrol", function(ply)
	return ply:IsDeveloper()
end)

hook.Add("LuapadCanRunSV", "combinecontrol", function(ply)
	return ply:IsDeveloper()
end)
