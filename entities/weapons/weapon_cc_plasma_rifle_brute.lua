AddCSLuaFile()

SWEP.Base = "weapon_cc_base_plasma"

SWEP.PrintName = "Type-25 Brute Plasma Rifle"
SWEP.Category = "CombineControl - Halo"
SWEP.NPCCategory = "Covenant"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 54

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/vuthakral/halo/weapons/c_hum_plasmarifle_bloodhand.mdl")
SWEP.WorldModel = Model("models/vuthakral/halo/weapons/w_plasmarifle_red.mdl")

SWEP.Stats = {
	Type = "Projectile",
	Class = "cc_projectile_plasma_brute",

	Offset = Vector(8, -8, -8),

	Accuracy = {12, 2}
}

SWEP.Heat = {
	CoolDelay = 0.2,

	HeatRate = 4,
	CoolRate = 40,

	Max = 60,
	ForceOverheat = true,
	AllowManual = false
}

SWEP.Recoil = {
	Value = 0.6,

	PosMult = Vector(0.6, 0, 0.3),
	AngMult = Angle(0.3, 1.2),

	Punch = 0.6
}

SWEP.Settings = {
	LowerHoldType = "normal",
	BaseHoldType = "pistol",

	Firemodes = {FIREMODE_AUTO},
	FireRate = 540,

	ClipSize = 0,

	Range = 400,
	Zoom = {1.25},
}

SWEP.Animations = {
	Fidget = ACT_VM_FIDGET
}

SWEP.Sounds = {
	Primary = Sound("Weapon_PlasmaRifle.Single")
}

SWEP.Offsets = {
	Default = {
		Vector(5, -1, 0),
		Angle(0, 0, 0)
	},
	Holster = {
		Vector(5, -1, 0),
		Angle(20, 0, 0)
	},
	Sprint = {
		Vector(5, -1, 0),
		Angle(20, 0, 0)
	},
	Aiming = {
		Vector(0, 0, 0),
		Angle(0, 0, 0)
	}
}

SWEP.Itemize = {
	Description = "A variant of the Type-25 Directed Energy Rifle known as the 'blood-hand', this modified plasma rifle is almost exclusively used by the Jiralhanae and features a more aggressive design.",
	Rarity = RARITY_RARE,

	Weight = 6,

	EquipmentSlots = {"primary", "secondary"},

	IconAngle = Angle(15, 45, 10),
	IconFOV = 12
}

sound.Add({
	name = "Weapon_PlasmaRifle.Single",
	channel = CHAN_WEAPON,
	volume = 0.72,
	level = 110,
	pitch = {98, 101},
	sound = ")vuthakral/halo/weapons/plasmarifle/plas_rifle_fire.wav"
})
