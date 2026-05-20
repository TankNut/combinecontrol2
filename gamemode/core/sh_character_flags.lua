module("CharacterFlag", package.seeall)

List = List or {}

local PLAYER = FindMetaTable("Player")

CharacterVar.Add("CharacterFlag", {
	Field = "Flag",
	Default = Config.Get("DefaultFlag"),
	DataType = VARCHAR(64)
})

function Register(name, flag)
	List[name] = inherit.Register("charflag", name, flag, flag.Base or "base")
end

function Get(name)
	if not name or not List[name] then
		return List[Config.Get("DefaultFlag")]
	end

	return List[name]
end

function Exists(name)
	return tobool(List[name])
end

function RegisterFolder(dir)
	file.IterateRecursive(dir, "shared.lua", "LUA", function(path, folder)
		local name = string.Filename(path)

		if name == "shared" then
			name = string.Filename(folder)
		end

		_G.FLAG = {}

		shared(path)

		Register(string.gsub(name, "^flag_", ""), FLAG)

		FLAG = nil
	end)
end

function PLAYER:GetCharFlag()
	local flag = PLAYER.CharacterFlag(self)

	if not flag or not List[flag] then
		return List[Config.Get("DefaultFlag")]
	end

	return List[flag]
end

function PLAYER:RunCharFlag(name, ...)
	return self:GetCharFlag():Run(self, name, ...)
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

	self:GiveBaseBuffs()
end

function GM:OnCharacterFlagChanged(ply, old, new, loaded)
	if loaded then
		return
	end

	ply:ApplyFlag()

	if SERVER then
		for _, item in pairs(ply:GetEquipment()) do
			item:CheckEquipmentSlot()
		end

		ply:GiveLoadoutWeapons()
	end
end
