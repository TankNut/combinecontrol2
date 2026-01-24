AddCSLuaFile()
DEFINE_BASECLASS("weapon_cc_base_gun")

SWEP.Base = "weapon_cc_base_gun"

SWEP.PrintName = "T33-B Fuel Rod Gun"
SWEP.Category = "CombineControl - Halo"
SWEP.NPCCategory = "Covenant"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 54

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/vuthakral/halo/weapons/c_hum_t33b.mdl")
SWEP.WorldModel = Model("models/vuthakral/halo/weapons/w_t33b.mdl")

SWEP.Stats = {
	Type = "Projectile",
	Class = "cc_projectile_fuelrod",

	Offset = Vector(8, -8, -2),
	Angle = Angle(-5, 0, 0),

	Accuracy = ACCURACY_POOR,
	Range = RANGE_LAUNCHER
}

SWEP.Recoil = {
	Value = 3,

	PosMult = Vector(2, 0, 0.5),
	AngMult = Angle(0.6, 0.2),

	Punch = 0.6
}

SWEP.Settings = {
	LowerHoldType = "passive",
	BaseHoldType = "rpg",

	Firemodes = {FIREMODE_SEMI},
	FireRate = 120,

	ClipSize = 5
}

SWEP.Animations = {
	Fidget = ACT_VM_FIDGET
}

SWEP.Sounds = {
	Primary = Sound("Weapon_T33B.Single")
}

SWEP.Offsets = {
	Default = {
		Vector(0, -1, -1),
		Angle(0, 0, 0)
	},
	Holster = {
		Vector(0, -2, -4),
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

	Weight = 20,

	EquipmentSlots = {"primary", "secondary"},

	IconAngle = Angle(15, 45, 10),
	IconFOV = 12
}

if CLIENT then
	function SWEP:SetupPoseParameters(ent)
		ent:SetPoseParameter("drc_ammo", self:Clip1() / self.Settings.ClipSize)
	end
end

sound.Add({
	name = "Weapon_T33B.Single",
	channel = CHAN_WEAPON,
	volume = 1,
	level = 80,
	pitch = {98.5, 101.5},
	sound = {
		")vuthakral/halo/weapons/t33b/fire0.wav",
		")vuthakral/halo/weapons/t33b/fire1.wav",
		")vuthakral/halo/weapons/t33b/fire2.wav"
	}
})
