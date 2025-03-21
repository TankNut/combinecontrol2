AddCSLuaFile()

SWEP.Base = "weapon_cc_base_new"

SWEP.PrintName = "AR2"
SWEP.Category = "CombineControl"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 54

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/weapons/c_irifle.mdl")
SWEP.WorldModel = Model("models/weapons/w_irifle.mdl")

SWEP.Stats = {
	Type = "Bullet", -- Used to determine what swep base function is called
	Count = 1, -- Amount of bullets to fire

	Damage = 11, -- Per bullet
	DamageFalloff = 0.98, -- Damage percentage per 1000 units

	FixedRange = false, -- For shotguns, overrides Settings.Range and forces it to use only Accuracy
	Accuracy = {12, 2}, -- Hip vs aimed

	Tracer = "AR2Tracer", -- The tracer effect, do not leave empty
	TracerCount = 1, -- Fire a tracer every X bullets

	Impact = "AR2Impact" -- Optional impact effect that is layered on top of the default
}

SWEP.Recoil = {
	-- The base recoil value
	Value = 0.6,

	-- How the recoil value is applied to the viewmodel
	PosMult = Vector(2, -1, 1),
	AngMult = Angle(0, 0),

	-- Amount of recoil that's applied to the player's eyeangles
	Punch = 0.6
}

SWEP.Settings = {
	LowerHoldType = "passive", -- Holstered/lowered
	BaseHoldType = "ar2", -- Default

	Firemodes = {-1}, -- -1 = automatic, 0 = semi, 1+ = burst

	FireRate = 600, -- Rounds per minute, -1 = animation time
	BurstDelay = 0, -- Delay between bursts, -1 = animation time

	ClipSize = 30,
	ReloadTime = -1, -- -1 = animation time
	ReloadAmount = -1, -- -1 = everything

	Range = 400, -- Range in units at which the weapon hits the accuracy stat exactly

	AimTime = 0.35, -- Seconds

	Zoom = {1.25}, -- Scrollwheel to switch between zoom levels
}

SWEP.Sounds = {
	Primary = Sound("Weapon_AR2.Single")
}

SWEP.Offsets = {
	Default = {
		Vector(0, 0, -1),
		Angle()
	},
	Holster = {
		Vector(0, -2, 2),
		Angle(20, 15, 0)
	},
	Sprint = {
		Vector(0, 0, 1),
		Angle(15, 5, 0)
	},
	Aiming = {
		Vector(-2, 1, 1),
		Angle(-1, 0, -5)
	}
}
