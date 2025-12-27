AddCSLuaFile()

SWEP.Base = "weapon_cc_throwing"

SWEP.PrintName = "Flashbang"
SWEP.Category = "CombineControl"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 54

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/weapons/cstrike/c_eq_flashbang.mdl")
SWEP.WorldModel = Model("models/weapons/w_eq_flashbang.mdl")

SWEP.Animations = {
	Throw = ACT_VM_THROW,
	Lob = ACT_VM_THROW,
	Roll = ACT_VM_THROW
}

SWEP.ItemClass = "grenade_flashbang"
SWEP.Itemize = {
	Base = "base_throwing",
	Rarity = RARITY_UNCOMMON,

	Weight = 0.4,

	IconAngle = Angle(17, 79, 14),
	IconFOV = 8
}

if SERVER then
	function SWEP:CreateEntity()
		local ent = ents.Create("cc_grenade_flashbang")

		ent:Spawn()
		ent:Activate()

		ent:SetTimer(3)

		return ent
	end
end
