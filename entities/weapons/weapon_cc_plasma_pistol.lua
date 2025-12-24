AddCSLuaFile()

SWEP.Base = "weapon_cc_base_plasma"

SWEP.PrintName = "Type-25 Plasma Pistol"
SWEP.Category = "CombineControl - Halo"
SWEP.NPCCategory = "Covenant"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 54

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/vuthakral/halo/weapons/c_hum_plasmapistol.mdl")
SWEP.WorldModel = Model("models/vuthakral/halo/weapons/w_plasmapistol.mdl")

SWEP.Stats = {
	Type = "Projectile",
	Class = "cc_projectile_plasma_pistol",

	Offset = Vector(8, -8, -8),

	Accuracy = {12, 2}
}

SWEP.Heat = {
	CoolDelay = 0.4,

	HeatRate = 12,
	CoolRate = 40,

	Max = 100,
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

	Firemodes = {FIREMODE_SEMI},
	FireRate = 300,

	ClipSize = 0,

	Range = 400,
	Zoom = {1.25},
}

SWEP.Animations = {
	Fidget = ACT_VM_FIDGET
}

SWEP.Sounds = {
	Primary = Sound("Weapon_PlasmaPistol.Single"),
	OverheatStart = "Weapon_PlasmaPistol.Overheat",
	OverheatFinish = "Weapon_PlasmaPistol.OverheatFinish"
}

SWEP.Offsets = {
	Default = {
		Vector(5, -1, -2),
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
		Vector(0, 0, -1),
		Angle(0, 0, 0)
	}
}

SWEP.Itemize = {
	Description = "The Type-25 Directed Energy Pistol is a covenant infantry weapon that's commonly carried by smaller covenant species.",
	Rarity = RARITY_UNCOMMON,

	Weight = 4,

	EquipmentSlots = {"primary", "secondary"},

	IconAngle = Angle(15, 45, 10),
	IconFOV = 12
}

sound.Add({
	name = "Weapon_PlasmaPistol.Single",
	channel = CHAN_WEAPON,
	volume = 0.72,
	level = 110,
	pitch = {98, 101},
	sound = {
		")vuthakral/halo/weapons/pp/fire0.wav",
		")vuthakral/halo/weapons/pp/fire1.wav",
		")vuthakral/halo/weapons/pp/fire2.wav"
	}
})

sound.Add({
	name = "Weapon_PlasmaPistol.Overheat",
	channel = CHAN_AUTO,
	volume = 0.42,
	level = 56,
	pitch = 100,
	sound = "vuthakral/halo/weapons/pp/overheat.wav"
})

sound.Add({
	name = "Weapon_PlasmaPistol.OverheatFinish",
	channel = CHAN_AUTO,
	volume = 0.72,
	level = 56,
	pitch = 100,
	sound = {
		"vuthakral/halo/weapons/pp/exit0.wav",
		"vuthakral/halo/weapons/pp/exit1.wav",
		"vuthakral/halo/weapons/pp/exit2.wav"
	}
})
