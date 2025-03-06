module("CharacterFlag", package.seeall)

List = List or {}

local PLAYER = FindMetaTable("Player")

CharacterVar.Add("CharacterFlag", {
	Field = "Flag",
	DataType = VARCHAR(64)
})

function Register(name, flag)
	List[name] = inherit.Register("charflag", name, flag, flag.Base or "base")
end

function Get(name)
	return List[name]
end

function RegisterFolder(dir)
	file.Iterate(dir, "shared.lua", "LUA", function(path, folder)
		local name = string.FileName(path)

		if name == "shared" then
			name = string.FileName(folder)
		end

		_G.FLAG = {}

		GM:IncludeShared(path)

		Register(string.gsub(name, "^flag_", ""), FLAG)

		FLAG = nil
	end)
end

function PLAYER:GetCharFlag()
	return List[PLAYER.CharacterFlag(self) or GAMEMODE.DefaultFlag]
end

function PLAYER:RunCharFlag(name, ...)
	return hook.Run("RunCharFlag", self, name, ...)
end

function GM:RunCharFlag(ply, name, ...)
	local flag = ply:GetCharFlag()

	if isfunction(flag[name]) then
		return flag[name](flag, ply, ...)
	else
		return flag[name]
	end
end

function GM:OnCharacterFlagChanged(ply, old, new, loaded)
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
	ply:UpdateVisibleDescription()
	ply:UpdateMovementSpeed()
	ply:UpdateAppearance()
	ply:UpdateLoadout()
	ply:UpdateMaxWeight()

	ply:SetBloodColor(ply:RunCharFlag("BloodColor"))
end
