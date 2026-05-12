module("buff", package.seeall)

function RegisterFile(path)
	_G.BUFF = {}

	shared(path)

	Register(string.gsub(string.FileName(path), "^buff_", ""), BUFF)

	BUFF = nil
end

function RegisterFolder(dir)
	file.IterateRecursive(dir, "shared.lua", "LUA", function(path, folder)
		local name = string.FileName(path)

		if name == "shared" then
			name = string.FileName(folder)
		end

		_G.BUFF = {}

		shared(path)

		Register(string.gsub(name, "^buff_", ""), BUFF)

		BUFF = nil
	end)
end

if SERVER then
	hook.Add("PlayerDeath", "cc2.Buffs", function(ply)
		PlayerHook(ply, "OnDeath")

		for name, buff in pairs(ply:GetBuffs()) do
			if buff.RemoveOnDeath then
				ply:RemoveBuff(name, true)
			end
		end
	end)

	hook.Add("PostEntityTakeDamage", "cc2.Buffs", function(ply, dmg, wasDamageTaken)
		if not ply:IsPlayer() or not wasDamageTaken then
			return
		end

		PlayerHook(ply, "OnDamaged", dmg)
	end)
end
