module("CharacterGen", package.seeall)

List = List or {}

local PLAYER = FindMetaTable("Player")

function Register(name, gen)
	gen.ID = name

	List[name] = inherit.Register("chargen", name, gen, gen.Base or "base")
end

function RegisterFolder(dir)
	file.Iterate(dir, "shared.lua", "LUA", function(path, folder)
		local name = string.FileName(path)

		if name == "shared" then
			name = string.FileName(folder)
		end

		_G.GENERATOR = {}

		shared(path)

		Register(string.gsub(name, "^gen_", ""), GENERATOR)

		GENERATOR = nil
	end)
end

function Get(id)
	return List[id]
end

if SERVER then
	function Run(ply, id, event)
		local generator = Get(id)
		local fields = generator:GetFields(ply)

		if event then
			fields.IsEventCharacter = true
		end

		ply:CreateCharacter(fields)

		generator:PostCreateCharacter(ply)
	end

	netstream.Hook("GenCharacter", function(ply, id)
		if not ply:CanUseCharacterGenerator(id) then
			return
		end

		Run(ply, id, true)

		Log.Write("character_generate", ply, Get(id))
	end)
end

function PLAYER:CanUseCharacterGenerator(id)
	return tobool(Get(id))
end

function PLAYER:GetCharacterGenerators()
	local tab = {}

	for id in SortedPairs(List) do
		if not self:CanUseCharacterGenerator(id) then
			continue
		end

		table.insert(tab, id)
	end

	return tab
end
