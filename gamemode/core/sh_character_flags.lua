module("CharacterFlag", package.seeall)

List = List or {}

local meta = FindMetaTable("Player")

CharacterVar.Add("Flag", {
	Default = "citizen",
	DataType = VARCHAR(64)
})

function Add(name, flag)
	flag.FileName = "flag_" .. name
	flag.ClassName = name

	List[name] = flag.Base and setmetatable(flag, {
		__index = baseclass.Get(flag.Base)
	}) or flag
end

function Load()
	local path = string.format("%s/gamemode/content/flags/", engine.ActiveGamemode())
	local files = file.Find(path .. "*.lua", "LUA")

	for _, v in ipairs(files) do
		_G.FLAG = {}

		GM:Include(path .. v)

		Add(v:FileName():sub(6), FLAG)

		FLAG = nil
	end

	for _, flag in pairs(List) do
		baseclass.Set(flag.FileName, flag)
	end
end

function meta:GetCharacterFlag()
	return List[meta.CharacterFlag(self)]
end

function meta:GetCharacterFlagAttribute(name, ...)
	return hook.Run("GetCharacterFlagAttribute", self, name, ...)
end

function GM:GetCharacterFlagAttribute(ply, name, ...)
	local flag = List[meta.CharacterFlag(ply)]

	return isfunction(flag[name]) and flag[name](flag, ply, ...) or flag[name]
end
