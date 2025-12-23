AddCSLuaFile()
DEFINE_BASECLASS("weapon_cc_base_plasma")

SWEP.Base = "weapon_cc_base_plasma"

SWEP.PrintName = "Type-51 Plasma Repeater"
SWEP.Category = "CombineControl - Halo"
SWEP.NPCCategory = "Covenant"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 54

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/vuthakral/halo/weapons/c_hum_plasmarepeater.mdl")
SWEP.WorldModel = Model("models/vuthakral/halo/weapons/w_plasmarepeater.mdl")

SWEP.Stats = {
	Type = "Projectile",
	Class = "cc_projectile_plasma_repeater",

	Offset = Vector(8, -8, -8),

	Accuracy = {12, 2}
}

SWEP.Heat = {
	CoolDelay = 0.4,

	HeatRate = 2,
	CoolRate = 20,
	PassiveCoolRate = 10,

	Max = 100,
	ForceOverheat = false,
	AllowManual = true
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

	ClipSize = 0,

	Range = 400,
	Zoom = {1.25},
}

SWEP.Animations = {
	Fidget = ACT_VM_FIDGET
}

SWEP.Sounds = {
	Primary = Sound("Weapon_PlasmaRepeater.Single"),

	Vent = Sound("Weapon_PlasmaRepeater.Vent"),
	VentLoop = Sound("Weapon_PlasmaRepeater.VentLoop"),

	OverheatStart = Sound("Weapon_PlasmaRepeater.Overheat"),
	OverheatFinish = Sound("Weapon_PlasmaRepeater.OverheatFinish")
}

SWEP.Offsets = {
	Default = {
		Vector(2, -1, -1),
		Angle(0, 0, 0)
	},
	Holster = {
		Vector(5, -1, 0),
		Angle(20, 15, 0)
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

if CLIENT then
	SWEP.ViewModelMaterials = {
		[7] = Material("null")
	}
end

SWEP.Itemize = {
	Description = "Also known as the MA5, the MA37 Individual Combat Weapon System is the UNSC's standard-issue service rifle. Chambered in 7.62x51mm",

	Weight = 7,

	EquipmentSlots = {"primary", "secondary"},

	IconAngle = Angle(15, 45, 10),
	IconFOV = 12
}

function SWEP:GetDelay()
	return math.ClampedRemap(self:GetHeat(), 0.4, 1, 0.1, 0.333)
end

function SWEP:OnOverheatStart()
	BaseClass.OnOverheatStart(self)

	self:EmitSound(self.Sounds.Vent)
	self:EmitSound(self.Sounds.VentLoop)
end

function SWEP:OnOverheatEnd()
	BaseClass.OnOverheatEnd(self)

	self:StopSound(self.Sounds.VentLoop)
end

sound.Add({
	name = "Weapon_PlasmaRepeater.Single",
	channel = CHAN_WEAPON,
	volume = 0.69, -- Nice
	level = 110,
	pitch = {98.5, 101.5},
	sound = {
		")vuthakral/halo/weapons/plasmarepeater/fire0.wav",
		")vuthakral/halo/weapons/plasmarepeater/fire1.wav",
		")vuthakral/halo/weapons/plasmarepeater/fire2.wav"
	}
})

sound.Add({
	name = "Weapon_PlasmaRepeater.Overheat",
	channel = CHAN_AUTO,
	volume = 0.165,
	level = 56,
	pitch = {98.5, 101.5},
	sound = {
		")vuthakral/halo/weapons/plasmarepeater/vent_open0.wav",
		")vuthakral/halo/weapons/plasmarepeater/vent_open1.wav",
		")vuthakral/halo/weapons/plasmarepeater/vent_open2.wav"
	}
})

sound.Add({
	name = "Weapon_PlasmaRepeater.OverheatFinish",
	channel = CHAN_AUTO,
	volume = 0.22,
	level = 56,
	pitch = {98.5, 101.5},
	sound = {
		")vuthakral/halo/weapons/plasmarepeater/vent_close0.wav",
		")vuthakral/halo/weapons/plasmarepeater/vent_close1.wav",
		")vuthakral/halo/weapons/plasmarepeater/vent_close2.wav"
	}
})

sound.Add({
	name = "Weapon_PlasmaRepeater.Vent",
	channel = CHAN_AUTO,
	volume = 0.72,
	level = 56,
	pitch = {98.5, 101.5},
	sound = ")vuthakral/halo/weapons/plasmarepeater/vent_in.wav"
})


sound.Add({
	name = "Weapon_PlasmaRepeater.VentLoop",
	channel = CHAN_AUTO,
	volume = 0.72,
	level = 56,
	pitch = 100,
	sound = ")vuthakral/halo/weapons/plasmarepeater/vent_loop.wav"
})
