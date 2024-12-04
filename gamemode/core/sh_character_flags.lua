module("CharacterFlag", package.seeall)

List = List or {}

local meta = FindMetaTable("Player")

CharacterVar.Add("Flag", {
	Default = "citizen",
	DataType = VARCHAR(64)
})

function Register(name, flag)
	flag.ClassName = name

	if not List[name] then
		List[name] = flag
	end

	if name != "base" then
		setmetatable(flag, {
			__index = baseclass.Get(flag.Base or "flag_base")
		})
	end

	baseclass.Set("flag_" .. name, flag)
end

function RegisterFile(path)
	_G.FLAG = {}

	GM:Include(path)

	Register(string.gsub(string.FileName(path), "^flag_", ""), FLAG)

	FLAG = nil
end

function Load()
	local path = string.format("%s/gamemode/content/flags/", engine.ActiveGamemode())
	local files = file.Find(path .. "*.lua", "LUA")

	for _, v in ipairs(files) do
		RegisterFile(path .. v)
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

	if isfunction(flag[name]) then
		return flag[name](flag, ply, ...)
	else
		return flag[name]
	end
end

function GM:CharacterFlagChanged(ply, old, new, loaded)
	if not loaded then
		hook.Run("PlayerApplyFlag", ply)
	end
end

function GM:PlayerApplyFlag(ply)
	if CLIENT then
		return
	end

	ply:SetTeam(ply:RunCharFlag("Team"))
	ply:ScaleMaxHealth(ply:RunCharFlag("Health"))

	ply:UpdateArmor()
	ply:UpdateVisibleName()
	ply:UpdateMovementSpeed()
	ply:UpdateAppearance()
	ply:UpdateLoadout()

	ply:SetBloodColor(ply:RunCharFlag("BloodColor"))
end
