AddCSLuaFile()

SWEP.Base = "weapon_cc_base_melee"

SWEP.PrintName = "Knife"
SWEP.Category = "CombineControl"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 54

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/weapons/cstrike/c_knife_t.mdl")
SWEP.WorldModel = Model("models/weapons/w_knife_t.mdl")

SWEP.Stats = {
	Damage = {8, 12},
	DamageType = DMG_SLASH,

	Reach = 48,

	Delay = {0.5, 1},
	Block = Config.Get("MeleeBlockMultiplier")
}

SWEP.Settings = {
	LowerHoldType = "normal",
	BaseHoldType = "knife",
	SwingHoldType = "melee",

	AimTime = 0.35,

	UseHolsterAnimations = false,
	IsLightWeapon = true
}

SWEP.Sounds = {
	Hit = {
		Sound("weapons/knife/knife_hit1.wav"),
		Sound("weapons/knife/knife_hit2.wav"),
		Sound("weapons/knife/knife_hit3.wav"),
		Sound("weapons/knife/knife_hit4.wav")
	},
	HitWall = Sound("weapons/knife/knife_hitwall1.wav"),
	Miss = {Sound("weapons/knife/knife_slash1.wav"), Sound("weapons/knife/knife_slash2.wav")}
}

SWEP.Animations = {
	MeleeHit = {"midslash1", "midslash2"}
}

SWEP.Offsets = {
	Default = {
		Vector(0, 0, 0),
		Angle(0, 0, 0)
	},
	Holster = {
		Vector(0, 0, -6),
		Angle(0, 0, 0)
	},
	Block = {
		Vector(0, 1, -5),
		Angle(-10, -10, 15)
	}
}
