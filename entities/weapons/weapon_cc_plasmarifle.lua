AddCSLuaFile()

SWEP.Base = "weapon_cc_base_plasma"

SWEP.PrintName = "Type-25 Plasma Rifle"
SWEP.Category = "CombineControl"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 54

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/vuthakral/halo/weapons/c_hum_plasmarifle.mdl")
SWEP.WorldModel = Model("models/vuthakral/halo/weapons/w_plasmarifle.mdl")

SWEP.Stats = {
	Type = "Projectile",
	Class = "cc_projectile_plasma",

	Offset = Vector(8, -8, -8),

	Accuracy = {12, 2}
}

SWEP.Heat = {
	CoolDelay = 0.4,

	HeatRate = 4,
	CoolRate = 40,

	Max = 100,
	ForceOverheat = true,
	AllowManual = false
}

SWEP.Recoil = {
	Value = 0.6,

	PosMult = Vector(1, 0, 0.5),
	AngMult = Angle(0.5, 2),

	Punch = 0.6
}

SWEP.Settings = {
	LowerHoldType = "normal",
	BaseHoldType = "pistol",

	Firemodes = {FIREMODE_AUTO},

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
	Description = "Also known as the MA5, the MA37 Individual Combat Weapon System is the UNSC's standard-issue service rifle. Chambered in 7.62x51mm",

	Weight = 7,

	EquipmentSlots = {"primary", "secondary"},

	IconAngle = Angle(15, 45, 10),
	IconFOV = 12
}

function SWEP:GetDelay()
	return math.ClampedRemap(self:GetFireDuration(), 0, 0.8, 0.16, 0.11)
end

sound.Add({
	name = "Weapon_PlasmaRifle.Single",
	channel = CHAN_WEAPON,
	volume = 0.72,
	level = 110,
	pitch = {98, 101},
	sound = ")vuthakral/halo/weapons/plasmarifle/plas_rifle_fire.wav"
})
