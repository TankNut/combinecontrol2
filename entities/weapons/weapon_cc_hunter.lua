AddCSLuaFile()
DEFINE_BASECLASS("weapon_cc_base_gun")

SWEP.Base = "weapon_cc_base_gun"

SWEP.PrintName = "Fuel Rod Cannon"

SWEP.ViewModelFOV = 54

SWEP.UseHands   = false
SWEP.ViewModel  = Model("models/vuthakral/halo/weapons/c_hum_t33b.mdl")
SWEP.WorldModel = ""

SWEP.Stats = {
	Type = "Projectile",
	Class = "cc_projectile_fuelrod",

	Offset = Vector(25, -30, -20),
	Angle = Angle(-5, 0, 0),

	Accuracy = 30,
	Range = {400, 800}
}

SWEP.Recoil = {
	Value = 2,

	PosMult = Vector(1, 0, 0.5),
	AngMult = Angle(0.6, 0.2),

	Punch = 0
}

SWEP.Settings = {
	LowerHoldType = "passive",
	BaseHoldType = "rpg",

	Firemodes = {FIREMODE_SEMI},
	FireRate = 120,

	ClipSize = 0,

	NoNPC = true
}

SWEP.Sounds = {
	Primary = Sound("Weapon_Hunter.Single")
}

SWEP.Offsets = {
	Default = {
		Vector(0, -3, -5),
		Angle(0, 0, 0)
	},
	Holster = {
		Vector(0, -2, -4),
		Angle(20, 10, 0)
	},
	Sprint = {
		Vector(0, 0, -1),
		Angle(25, 15, 0)
	},
	Aiming = {
		Vector(0, -3, -5),
		Angle(0, 0, 0)
	}
}

sound.Add({
	name = "Weapon_Hunter.Single",
	channel = CHAN_WEAPON,
	volume = 1,
	level = 80,
	pitch = {98.5, 101.5},
	sound = ")vuthakral/halo/weapons/t33a/fire0.wav"
})
