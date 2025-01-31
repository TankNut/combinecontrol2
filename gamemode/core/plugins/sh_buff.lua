module("buff", package.seeall)

function RegisterFile(path)
	_G.BUFF = {}

	GM:Include(path)

	Register(string.gsub(string.FileName(path), "^buff_", ""), BUFF)

	BUFF = nil
end

function RegisterFolder(dir)
	file.Iterate(dir, "shared.lua", "LUA", function(path, folder)
		local name = string.FileName(path)

		if name == "shared" then
			name = string.FileName(folder)
		end

		_G.BUFF = {}

		GM:Include(path)

		Register(string.gsub(name, "^buff_", ""), BUFF)

		BUFF = nil
	end)
end

hook.Add("LoadContent", "plugins.buff", function()
	RegisterFolder(ContentFolder .. "buffs/")

	for _, plugin in ipairs(PluginFolders) do
		RegisterFolder(plugin .. "buffs/")
	end
end)

hook.Add("Move", "plugins.buff", function(ply, mv) PlayerHook(ply, "Move", mv) end)

if SERVER then
	hook.Add("PlayerDeath", "plugins.buff", function(ply)
		PlayerHook(ply, "OnDeath")

		for name, buff in pairs(ply:GetBuffs()) do
			if buff.RemoveOnDeath then
				ply:RemoveBuff(name, true)
			end
		end
	end)

	hook.Add("BlockFallDamage", "plugins.buff", function(ply)
		return PlayerHook(ply, "BlockFallDamage")
	end)
end
