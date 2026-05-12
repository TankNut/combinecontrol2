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
	file.IterateRecursive(dir, "shared.lua", "LUA", function(path, folder)
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
	return self:GetCharFlag():Run(self, name, ...)
end

local UpdateBuffs

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

function PLAYER:ApplyFlag()
	if CLIENT then
		return
	end

	self:SetTeam(self:RunCharFlag("Team"))
	self:ScaleMaxHealth(self:RunCharFlag("Health"))

	self:UpdateArmor()
	self:UpdateVisibleName()
	self:UpdateVisibleDescription()
	self:UpdateMovementSpeed()
	self:UpdateAppearance()
	self:UpdateMaxWeight()
	self:UpdateClassification()

	self:SetBloodColor(self:RunCharFlag("BloodColor"))
end


function GM:OnCharacterFlagChanged(ply, old, new, loaded)
	if not loaded then
		ply:ApplyFlag()

		if SERVER then
			for _, item in pairs(ply:GetEquipment()) do
				item:CheckEquipmentSlot()
			end

			ply:GiveLoadoutWeapons()
		end
	end

	if SERVER then
		UpdateBuffs(ply, old or self.DefaultFlag, new or self.DefaultFlag)
	end
end
