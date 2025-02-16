module("CharCreate", package.seeall)

List = List or {}
Names = Names or {}

local PLAYER = FindMetaTable("Player")

function Register(name, data)
	List[name] = inherit.Register("chartype", name, data, data.Base or "base")
end

function RegisterFolder(dir)
	file.Iterate(dir, "shared.lua", "LUA", function(path, folder)
		local name = string.FileName(path)

		if name == "shared" then
			name = string.FileName(folder)
		end

		_G.CLASS = {}

		GM:IncludeShared(path)

		Register(string.gsub(name, "^chartype_", ""), CLASS)

		CLASS = nil
	end)
end

function Get(id)
	return List[id]
end

function Validate(id, fields)
	local charType = Get(id)

	if not charType then
		return false
	end

	return validate.Multi(fields, charType.Validate)
end

function AddNames(index, ...)
	Names[index] = {...}
end

function GetRandomName(index)
	local data = Names[index]

	if not data then
		return ""
	end

	local name = {}

	for _, options in ipairs(data) do
		table.insert(name, options[math.random(#options)])
	end

	return table.concat(name, " ")
end

if SERVER then
	netstream.Hook("CreateCharacter", function(ply, id, options)
		if not ply:CanUseCharacterType(id) then
			return
		end

		Run(ply, id, options)
	end)

	function Run(ply, id, submitted)
		local ok, options = Validate(id, submitted)

		if not ok then
			return
		end

		local charType = Get(id)
		local fields = table.Copy(charType.Fields)

		charType:PreCreateCharacter(ply, fields, options)

		for k, v in pairs(charType.Options) do
			if v.Field then
				fields[v.Field] = options[k]
			end
		end

		ply:CreateCharacter(fields)

		charType:PostCreateCharacter(ply, options)
	end
end

function PLAYER:CanUseCharacterType(id)
	return tobool(Get(id))
end

function PLAYER:GetCharacterTypes()
	local tab = {}

	for id in SortedPairsByMemberValue(List, "SortOrder") do
		if not self:CanUseCharacterType(id) then
			continue
		end

		table.insert(tab, id)
	end

	return tab
end
