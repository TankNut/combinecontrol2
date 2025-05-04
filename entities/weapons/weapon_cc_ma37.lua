AddCSLuaFile()

SWEP.Base = "weapon_cc_base_gun"

SWEP.PrintName = "MA37 ICWS"
SWEP.Category = "CombineControl"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 54

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/vuthakral/halo/weapons/c_hum_ma37.mdl")
SWEP.WorldModel = Model("models/vuthakral/halo/weapons/w_ma37.mdl")

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

	Firemodes = {FIREMODE_AUTO},
	FireRate = 600,

	ClipSize = 32,

	Range = 400,
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
		Vector(0, -2, 1),
		Angle(20, 15, 0)
	},
	Sprint = {
		Vector(0, 0, 0),
		Angle(15, 5, 0)
	},
	Aiming = {
		Vector(-2, 1, 0),
		Angle(-1, 0, -5)
	}
}

SWEP.Itemize = {
	Description = "Also known as the MA5, the MA37 Individual Combat Weapon System is the UNSC's standard-issue service rifle. Chambered in 7.62x51mm",

	Weight = 7,

	EquipmentSlots = {"primary", "secondary"},

	IconAngle = Angle(15, 45, 10),
	IconFOV = 12
}
