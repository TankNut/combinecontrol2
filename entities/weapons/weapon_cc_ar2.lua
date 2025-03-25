AddCSLuaFile()

SWEP.Base = "weapon_cc_base_gun"

SWEP.PrintName = "AR2"
SWEP.Category = "CombineControl"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 54

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/weapons/c_irifle.mdl")
SWEP.WorldModel = Model("models/weapons/w_irifle.mdl")

SWEP.Stats = {
	Type = "Bullet",
	Count = 1,

	Damage = 11,
	DamageFalloff = 0.98,

	Accuracy = {12, 2},

	Tracer = "AR2Tracer",
	TracerCount = 1,

	Impact = "AR2Impact"
}

SWEP.Recoil = {
	Value = 0.6,

	PosMult = Vector(2, -1, 1),
	AngMult = Angle(0, 0),

	Punch = 0.6
}

SWEP.Settings = {
	LowerHoldType = "passive",
	BaseHoldType = "ar2",

	Firemodes = {-1},

	FireRate = 600,
	BurstDelay = 0,

	ClipSize = 30,
	ReloadTime = -1,
	ReloadAmount = -1,

	Range = 400,

	AimTime = 0.35,

	Zoom = {1.25},
}

SWEP.Sounds = {
	Primary = Sound("Weapon_AR2.Single")
}

SWEP.Offsets = {
	Default = {
		Vector(0, 0, -1),
		Angle(0, 0, 0)
	},
	Holster = {
		Vector(0, -2, 2),
		Angle(20, 15, 0)
	},
	Sprint = {
		Vector(0, 0, 1),
		Angle(15, 5, 0)
	},
	Aiming = {
		Vector(-2, 1, 1),
		Angle(-1, 0, -5)
	}
}
