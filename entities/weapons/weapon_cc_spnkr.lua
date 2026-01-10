AddCSLuaFile()
DEFINE_BASECLASS("weapon_cc_base_gun")

SWEP.Base = "weapon_cc_base_gun"

SWEP.PrintName = "M41 SPNKR"
SWEP.Category = "CombineControl - Halo"
SWEP.NPCCategory = "UNSC"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 54

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/vuthakral/halo/weapons/c_hum_spnkr.mdl")
SWEP.WorldModel = Model("models/vuthakral/halo/weapons/w_spnkr.mdl")

SWEP.Stats = {
	Type = "Projectile",
	Class = "cc_projectile_spnkr",

	Offset = Vector(8, -8, -2),

	Accuracy = ACCURACY_GOOD
}

SWEP.Recoil = {
	Value = 1,

	PosMult = Vector(1, 0, 0.5),
	AngMult = Angle(0.6, 0.2),

	Punch = 0.6
}

SWEP.Settings = {
	LowerHoldType = "passive",
	BaseHoldType = "rpg",

	Firemodes = {FIREMODE_SEMI},
	FireRate = 250,

	ClipSize = 2,

	Range = 400,
	Zoom = {1.25}
}

SWEP.Animations = {
	Primary = "fire_rand3",
	Fidget = ACT_VM_FIDGET
}

SWEP.Sounds = {
	Primary = Sound("Weapon_Spnkr.Single")
}

SWEP.Offsets = {
	Default = {
		Vector(0, -1, -1),
		Angle(0, 0, 0)
	},
	Holster = {
		Vector(0, 0, -2),
		Angle(20, 10, 0)
	},
	Sprint = {
		Vector(0, 0, -1),
		Angle(25, 15, 0)
	},
	Aiming = {
		Vector(-1, 0, 0),
		Angle(0, 0, 0)
	}
}

SWEP.Itemize = {
	Description = "The Type-31 Needle Rifle is a covenant infantry weapon infamous for it's lethality against infantry.",
	Rarity = RARITY_RARE,

	Weight = 10,

	EquipmentSlots = {"primary", "secondary"},

	IconAngle = Angle(15, 45, 10),
	IconFOV = 12
}

sound.Add({
	name = "Weapon_Spnkr.Single",
	channel = CHAN_WEAPON,
	volume = 0.4,
	level = 90,
	pitch = {95, 105},
	sound = {
		")vuthakral/halo/weapons/SPNKr/fire0.wav",
		")vuthakral/halo/weapons/SPNKr/fire1.wav",
		")vuthakral/halo/weapons/SPNKr/fire2.wav",
		")vuthakral/halo/weapons/SPNKr/fire3.wav"
	}
})
