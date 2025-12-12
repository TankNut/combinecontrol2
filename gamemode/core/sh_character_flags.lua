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

		shared(path)

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

	return flag:Run(ply, name, ...)
end

function GM:OnCharacterFlagChanged(ply, old, new, loaded)
	if not loaded then
		hook.Run("PlayerApplyFlag", ply)

		if SERVER then
			for _, item in pairs(ply:GetEquipment()) do
				item:CheckEquipmentSlot()
			end
		end
	end

	if SERVER then
		UpdateBuffs(ply, old or self.DefaultFlag, new or self.DefaultFlag)
	end
end

if SERVER then
	function UpdateBuffs(ply, old, new)
		for _, buff in ipairs(Get(old).Buffs) do
			ply:RemoveBuff(buff)
		end

		for _, buff in ipairs(Get(new).Buffs) do
			ply:AddBuff(buff)
		end
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
	ply:UpdateClassification()

	ply:SetBloodColor(ply:RunCharFlag("BloodColor"))
end
