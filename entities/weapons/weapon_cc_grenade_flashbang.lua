AddCSLuaFile()

SWEP.Base = "weapon_cc_throwable"

SWEP.PrintName = "Flashbang"
SWEP.Category = "CombineControl"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 54

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/weapons/cstrike/c_eq_flashbang.mdl")
SWEP.WorldModel = Model("models/weapons/w_eq_flashbang.mdl")

if SERVER then
	function SWEP:CreateEntity()
		local ent = ents.Create("cc_grenade_flashbang")

		ent:Spawn()
		ent:Activate()

		ent:SetTimer(3)

		return ent
	end
end
