AddCSLuaFile()

SWEP.Base = "weapon_cc_base_melee_swing"

SWEP.PrintName = "Crowbar"
SWEP.Category = "CombineControl"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 54

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/weapons/c_crowbar.mdl")
SWEP.WorldModel = Model("models/weapons/w_crowbar.mdl")

SWEP.Stats = {
	Damage = {8, 12},
	DamageType = DMG_CLUB,

	Reach = 75,
	Hold = {0.15, 0.5},

	Delay = 0.5,
	Block = Config.Get("MeleeBlockMultiplier")
}

SWEP.Settings = {
	LowerHoldType = "normal",
	BaseHoldType = "melee2",
	SwingHoldType = "melee",

	AimTime = 0.35,

	UseHolsterAnimations = true,
	IsLightWeapon = false
}

SWEP.Sounds = {
	Hit = Sound("Weapon_Crowbar.Melee_Hit"),
	Miss = Sound("Weapon_Crowbar.Single")
}

SWEP.Animations = {
	MeleeHit = ACT_VM_MISSCENTER
}

SWEP.Offsets = {
	Default = {
		Vector(0, 0, 0),
		Angle(0, 0, 0)
	},
	Sprint = {
		Vector(0, 0, 0),
		Angle(25, 15, -20)
	},
	Swing = {
		Vector(-20, 0, 0),
		Angle(-20, 0, 0)
	},
	Block = {
		Vector(0, 15, -12),
		Angle(-5, 0, -50)
	}
}
