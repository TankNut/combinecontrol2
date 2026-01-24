AddCSLuaFile()
DEFINE_BASECLASS("weapon_cc_base_gun")

SWEP.Base = "weapon_cc_base_gun"

SWEP.PrintName = "M7 SMG"
SWEP.Category = "CombineControl - Halo"
SWEP.NPCCategory = "UNSC"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 54

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/vuthakral/halo/weapons/c_hum_m7.mdl")
SWEP.WorldModel = Model("models/vuthakral/halo/weapons/w_m7.mdl")

SWEP.Stats = {
	Type = "Bullet",
	Count = 1,

	Damage = 10,
	DamageFalloff = DMG_FALLOFF_SMG,

	Accuracy = ACCURACY_POOR,
	Range = RANGE_SMG,

	Tracer = "Tracer",
	TracerCount = 1
}

SWEP.Recoil = {
	Value = 0.6,

	PosMult = Vector(0.2, 0, 0.2),
	AngMult = Angle(0.3, 1.2),

	Punch = 0.6
}

SWEP.Settings = {
	LowerHoldType = "passive",
	BaseHoldType = "smg",

	Firemodes = {FIREMODE_AUTO},
	FireRate = 900,

	ClipSize = 60
}

SWEP.Animations = {
	Fidget = ACT_VM_FIDGET
}

SWEP.Sounds = {
	Primary = Sound("Weapon_M7.Single")
}

SWEP.Offsets = {
	Default = {
		Vector(0, -0.5, -2),
		Angle(0, 0, 0)
	},
	Holster = {
		Vector(0, 0, 0),
		Angle(20, 15, 0)
	},
	Sprint = {
		Vector(0, 0, -1),
		Angle(15, 5, 0)
	},
	Aiming = {
		Vector(-2, 0, -1),
		Angle(-1, 0, 0)
	}
}

SWEP.Itemize = {
	Description = "Formally known as the M7/Caseless, the M7 is a UNSC issued PDW commonly used by infantry, special forces and vehicle crews.",
	Rarity = RARITY_COMMON,

	Weight = 4,

	EquipmentSlots = {"primary", "secondary"},

	IconAngle = Angle(15, 45, 10),
	IconFOV = 15
}

sound.Add({
	name = "Weapon_M7.Single",
	channel = CHAN_WEAPON,
	volume = 0.69,
	level = 140,
	sound = {
		")vuthakral/halo/weapons/m7smg/fire1.wav",
		")vuthakral/halo/weapons/m7smg/fire2.wav",
		")vuthakral/halo/weapons/m7smg/fire3.wav",
		")vuthakral/halo/weapons/m7smg/fire4.wav",
		")vuthakral/halo/weapons/m7smg/fire5.wav",
		")vuthakral/halo/weapons/m7smg/fire7.wav",
		")vuthakral/halo/weapons/m7smg/fire8.wav",
		")vuthakral/halo/weapons/m7smg/fire9.wav",
		")vuthakral/halo/weapons/m7smg/fire10.wav",
		")vuthakral/halo/weapons/m7smg/fire11.wav",
		")vuthakral/halo/weapons/m7smg/fire12.wav",
		")vuthakral/halo/weapons/m7smg/fire13.wav",
		")vuthakral/halo/weapons/m7smg/fire14.wav",
		")vuthakral/halo/weapons/m7smg/fire15.wav",
		")vuthakral/halo/weapons/m7smg/fire16.wav",
		")vuthakral/halo/weapons/m7smg/fire17.wav"
	}
})
