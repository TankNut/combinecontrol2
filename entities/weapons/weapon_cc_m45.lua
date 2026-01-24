AddCSLuaFile()
DEFINE_BASECLASS("weapon_cc_base_gun")

SWEP.Base = "weapon_cc_base_gun"

SWEP.PrintName = "M45 Tactical Shotgun"
SWEP.Category = "CombineControl - Halo"
SWEP.NPCCategory = "UNSC"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 54

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/vuthakral/halo/weapons/c_hum_m45.mdl")
SWEP.WorldModel = Model("models/vuthakral/halo/weapons/w_m45.mdl")

SWEP.Stats = {
	Type = "Bullet",
	Count = 15,

	Damage = 7,
	DamageFalloff = DMG_FALLOFF_SHOTGUN,

	Accuracy = 36,
	Range = RANGE_SHOTGUN,

	Tracer = "Tracer",
	TracerCount = 3
}

SWEP.Recoil = {
	Value = 3,

	PosMult = Vector(2, 0, 1),
	AngMult = Angle(0.6, 0.12),

	Punch = 0.6
}

SWEP.Settings = {
	LowerHoldType = "passive",
	BaseHoldType = "shotgun",

	Firemodes = {FIREMODE_SEMI},
	FireRate = -1,

	ClipSize = 6,
	ReloadAmount = 1,

	ShotgunReload = true
}

SWEP.Animations = {
	Fidget = ACT_VM_FIDGET
}

SWEP.Sounds = {
	Primary = Sound("Weapon_M45.Single")
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
		Vector(-1, 0, -0.5),
		Angle(0, 0, 0)
	}
}

SWEP.Itemize = {
	Description = "The M45 Tactical Shotgun is a weapon designed for close quarters combat and boarding scenarios by the UNSC.",
	Rarity = RARITY_UNCOMMON,

	Weight = 8,

	EquipmentSlots = {"primary", "secondary"},

	IconAngle = Angle(-10, -80, -16),
	IconFOV = 20
}

sound.Add({
	name = "Weapon_M45.Single",
	channel = CHAN_WEAPON,
	volume = 0.69,
	level = 140,
	pitch = 100,
	sound = {
		")vuthakral/halo/weapons/m90/fire0.wav",
		")vuthakral/halo/weapons/m90/fire1.wav",
		")vuthakral/halo/weapons/m90/fire2.wav"
	}
})
