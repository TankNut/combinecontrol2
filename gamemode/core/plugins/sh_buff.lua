module("buff", package.seeall)

function RegisterFile(path)
	_G.BUFF = {}

	GM:Include(path)

	Register(string.gsub(string.FileName(path), "^buff_", ""), BUFF)

	BUFF = nil
end

function RegisterFolder(basePath)
	local function load(path)
		local files, folders = file.Find(path .. "*", "LUA")

		for _, v in ipairs(files) do
			local filePath = path .. v

			if string.GetExtensionFromFilename(filePath) != "lua" then
				continue
			end

			RegisterFile(filePath)
		end

		for _, v in ipairs(folders) do
			local folderPath = path .. v
			local filePath = folderPath .. "/shared.lua"

			if file.Exists(filePath, "LUA") then
				_G.BUFF = {}

				GM:Include(filePath)

				Register(string.gsub(string.FileName(folderPath), "^buff_", ""), BUFF)

				BUFF = nil
			else
				load(folderPath .. "/")
			end
		end
	end

	load(basePath)
end

hook.Add("LoadContent", "buff", function()
	RegisterFolder(engine.ActiveGamemode() .. "/gamemode/content/buffs/")
end)

hook.Add("Move", "buff", function(ply, mv)
	HookPlayer(ply, "Move", mv)
end)

if SERVER then
	hook.Add("PlayerDeath", "buff", function(ply)
		HookPlayer(ply, "OnDeath")

		for name, buff in pairs(ply:GetBuffs()) do
			if buff.RemoveOnDeath then
				ply:RemoveBuff(name, true)
			end
		end
	end)
end
