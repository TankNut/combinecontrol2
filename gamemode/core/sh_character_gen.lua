module("CharacterGen", package.seeall)

List = List or {}

function Register(name, gen)
	List[name] = inherit.Register("chargen", name, gen, gen.Base or "base")
end

function RegisterFolder(dir)
	file.Iterate(dir, "shared.lua", "LUA", function(path, folder)
		local name = string.FileName(path)

		if name == "shared" then
			name = string.FileName(folder)
		end

		_G.GENERATOR = {}

		GM:IncludeShared(path)

		Register(string.gsub(name, "^gen_", ""), GENERATOR)

		GENERATOR = nil
	end)
end

function Get(id)
	return List[id]
end

if SERVER then
	function Run(ply, id, temp)
		local generator = Get(id)
		local fields = generator:GetFields(ply)

		if temp then
			ply:CreateTempCharacter(fields)
		else
			ply:CreateCharacter(fields)
		end

		generator:PostCreateCharacter(ply)
	end
end
