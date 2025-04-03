AddCSLuaFile()

SWEP.Base = "weapon_cc_base_gun"

SWEP.PrintName = "Shotgun"
SWEP.Category = "CombineControl"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 54

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/weapons/c_shotgun.mdl")
SWEP.WorldModel = Model("models/weapons/w_shotgun.mdl")

SWEP.Stats = {
	Type = "Bullet",
	Count = 12,

	Damage = 8,
	DamageFalloff = 0.7,

	FixedRange = false,
	Accuracy = {12, 12},

	Tracer = "Tracer",
	TracerCount = 2,
}

SWEP.Recoil = {
	Value = 2,

	PosMult = Vector(2, 0, 0.5),
	AngMult = Angle(2, 0),

	Punch = 1
}

SWEP.Settings = {
	LowerHoldType = "passive",
	BaseHoldType = "shotgun",
	AimHoldType = "shotgun_aim",

	Firemodes = {FIREMODE_SEMI},
	FiremodeOverride = "Pump-Action",

	FireRate = -1,

	ClipSize = 6,
	ReloadAmount = 1,

	PumpAction = true,
	ShotgunReload = true,

	Zoom = {1.25},
}

SWEP.Sounds = {
	Empty = Sound("Weapon_Shotgun.Empty"),
	Primary = Sound("Weapon_Shotgun.Single"),
	Reload = Sound("Weapon_Shotgun.Reload")
}

SWEP.Offsets = {
	Default = {
		Vector(0, 1, -1),
		Angle(0, 1.5, 0)
	},
	Holster = {
		Vector(-2, 0, 0),
		Angle(12, 20, -5)
	},
	Sprint = {
		Vector(0, 1, 1),
		Angle(15, 10, 0)
	},
	Aiming = {
		Vector(0, 3, 1),
		Angle(-1.5, 2.5, -2)
	}
}
