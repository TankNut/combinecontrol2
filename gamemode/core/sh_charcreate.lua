module("CharCreate", package.seeall)

List = List or {}

Class = Class or {}
Class.__index = Class

Names = Names or {}

local meta = FindMetaTable("Player")

function Register(data)
	List[data.ID] = setmetatable(data, Class)
end

function RegisterFile(path)
	_G.CLASS = {
		ID = string.FileName(path)
	}

	GM:Include(path)

	Register(CLASS)

	CLASS = nil
end

function Load()
	local path = string.format("%s/gamemode/content/charcreate/", engine.ActiveGamemode())
	local files = file.Find(path .. "*.lua", "LUA")

	for _, v in ipairs(files) do
		RegisterFile(path .. v)
	end
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

		for k, v in pairs(charType.Options) do
			if v.Field then
				fields[v.Field] = options[k]
			end
		end

		charType:PreCreateCharacter(ply, fields, options)

		ply:CreateCharacter(fields)

		charType:PostCreateCharacter(ply, options)
	end
end

function meta:CanUseCharacterType(id)
	return tobool(Get(id))
end

function meta:GetCharacterTypes()
	local tab = {}

	for id in SortedPairsByMemberValue(List, "SortOrder") do
		if not self:CanUseCharacterType(id) then
			continue
		end

		table.insert(tab, id)
	end

	return tab
end
