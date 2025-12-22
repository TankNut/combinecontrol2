AddCSLuaFile()

SWEP.Base = "weapon_cc_throwing"

SWEP.PrintName = "Smoke Grenade"
SWEP.Category = "CombineControl"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 54

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/weapons/cstrike/c_eq_smokegrenade.mdl")
SWEP.WorldModel = Model("models/weapons/w_eq_smokegrenade.mdl")

SWEP.ItemClass = "grenade_smoke"
SWEP.Itemize = {
	Base = "base_throwing",

	IconAngle = Angle(17, 79, 14),
	IconFOV = 8
}

if SERVER then
	function SWEP:CreateEntity()
		local ent = ents.Create("cc_grenade_smoke")

		ent:Spawn()
		ent:Activate()

		ent:SetTimer(3)

		SafeRemoveEntityDelayed(ent, math.random(50, 90))

		return ent
	end
end
