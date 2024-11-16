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

	if flag.FileName == "flag_base" then
		List[name] = flag
	else
		List[name] = setmetatable(flag, {
			__index = baseclass.Get(flag.Base or "flag_base")
		})
	end
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

function meta:GetCharFlag()
	return List[meta.CharacterFlag(self)]
end

function meta:RunCharFlag(name, ...)
	return hook.Run("RunCharFlag", self, name, ...)
end

function GM:RunCharFlag(ply, name, ...)
	local flag = List[meta.CharacterFlag(ply)]

	return isfunction(flag[name]) and flag[name](flag, ply, ...) or flag[name]
end
