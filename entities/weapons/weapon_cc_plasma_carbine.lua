AddCSLuaFile()
DEFINE_BASECLASS("weapon_cc_base_gun")

SWEP.Base = "weapon_cc_base_gun"

SWEP.PrintName = "Type-51 Plasma Carbine"
SWEP.Category = "CombineControl - Halo"
SWEP.NPCCategory = "Covenant"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 54

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/vuthakral/halo/weapons/c_hum_carbine_h3.mdl")
SWEP.WorldModel = Model("models/vuthakral/halo/weapons/w_t51c.mdl")

SWEP.Stats = {
	Type = "Bullet",
	Count = 1,

	Damage = 20,
	DamageFalloff = 0.98,

	Accuracy = {12, 2},

	Tracer = "cc_e_tracer_plasma_carbine",
	TracerCount = 1,

	Impact = "cc_e_impact_plasma_carbine"
}

SWEP.Recoil = {
	Value = 1,

	PosMult = Vector(1, 0, 0.5),
	AngMult = Angle(0.6, 0.2),

	Punch = 0.6
}

SWEP.Settings = {
	LowerHoldType = "passive",
	BaseHoldType = "ar2",

	Firemodes = {FIREMODE_SEMI},
	FireRate = 250,

	ClipSize = 18,

	Range = 400,
	Zoom = {1.25}
}

SWEP.Animations = {
	Fidget = ACT_VM_FIDGET
}

SWEP.Sounds = {
	Primary = Sound("Weapon_PlasmaCarbine.Single")
}

SWEP.Offsets = {
	Default = {
		Vector(2, -2, -2),
		Angle(0, 0, 0)
	},
	Holster = {
		Vector(3, 0, -2),
		Angle(20, 15, 0)
	},
	Sprint = {
		Vector(0, 0, -1),
		Angle(15, 15, 0)
	},
	Aiming = {
		Vector(2, -1, -1),
		Angle(0, 0, 0)
	}
}

SWEP.Itemize = {
	Description = "The Type-31 Needle Rifle is a covenant infantry weapon infamous for it's lethality against infantry.",
	Rarity = RARITY_RARE,

	Weight = 8,

	EquipmentSlots = {"primary", "secondary"},

	IconAngle = Angle(15, 45, 10),
	IconFOV = 12
}

sound.Add({
	name = "Weapon_PlasmaCarbine.Single",
	channel = CHAN_WEAPON,
	volume = 0.4,
	level = 110,
	pitch = {99, 101},
	sound = {
		")vuthakral/halo/weapons/t51c/carbine_new28.wav",
		")vuthakral/halo/weapons/t51c/carbine_new29.wav",
		")vuthakral/halo/weapons/t51c/carbine_new30.wav"
	}
})
