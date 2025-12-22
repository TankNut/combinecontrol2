AddCSLuaFile()
DEFINE_BASECLASS("weapon_cc_base_gun")

SWEP.Base = "weapon_cc_base_gun"

SWEP.PrintName = "M7S SMG"
SWEP.Category = "CombineControl - Halo"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 54

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/vuthakral/halo/weapons/c_hum_m7s.mdl")
SWEP.WorldModel = Model("models/vuthakral/halo/weapons/w_m7s.mdl")

SWEP.Stats = {
	Type = "Bullet",
	Count = 1,

	Damage = 11,
	DamageFalloff = 0.98,

	Accuracy = {12, 2},

	Tracer = "Tracer",
	TracerCount = 1
}

SWEP.Recoil = {
	Value = 0.6,

	PosMult = Vector(0.6, 0, 0.3),
	AngMult = Angle(0.3, 1.2),

	Punch = 0.6
}

SWEP.Settings = {
	LowerHoldType = "passive",
	BaseHoldType = "ar2",

	Firemodes = {FIREMODE_AUTO},
	FireRate = 900,

	ClipSize = 60,

	Range = 400,
	Zoom = {1.25},
}

SWEP.Animations = {
	Fidget = ACT_VM_FIDGET
}

SWEP.Sounds = {
	Primary = Sound("Weapon_M7S.Single")
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
	Description = "Also known as the MA5, the MA37 Individual Combat Weapon System is the UNSC's standard-issue service rifle. Chambered in 7.62x51mm",

	Weight = 7,

	EquipmentSlots = {"primary", "secondary"},

	IconAngle = Angle(15, 45, 10),
	IconFOV = 12
}

sound.Add({
	name = "Weapon_M7S.Single",
	channel = CHAN_WEAPON,
	volume = 0.69,
	level = 75,
	sound = {
		")vuthakral/halo/weapons/m7s/fire0.wav",
		")vuthakral/halo/weapons/m7s/fire1.wav",
		")vuthakral/halo/weapons/m7s/fire2.wav"
	}
})
