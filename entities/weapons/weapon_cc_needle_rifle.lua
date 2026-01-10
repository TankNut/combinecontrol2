AddCSLuaFile()
DEFINE_BASECLASS("weapon_cc_base_gun")

SWEP.Base = "weapon_cc_base_gun"

SWEP.PrintName = "Type-31 Needle Rifle"
SWEP.Category = "CombineControl - Halo"
SWEP.NPCCategory = "Covenant"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 54

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/vuthakral/halo/weapons/c_hum_needlerifle.mdl")
SWEP.WorldModel = Model("models/vuthakral/halo/weapons/w_needlerifle.mdl")

SWEP.Stats = {
	Type = "Bullet",
	Count = 1,

	Damage = 40,
	DamageFalloff = DMG_FALLOFF_SNIPER,

	Accuracy = ACCURACY_GOOD,

	Tracer = "cc_e_tracer_needle_rifle",
	TracerCount = 1
}

SWEP.Recoil = {
	Value = 1,

	PosMult = Vector(2, 0, 0.5),
	AngMult = Angle(1, 0.2),

	Punch = 0.6
}

SWEP.Settings = {
	LowerHoldType = "passive",
	BaseHoldType = "ar2",

	Firemodes = {FIREMODE_SEMI},
	FireRate = 200,

	ClipSize = 21,

	Range = 800,
	Zoom = {1.25, 3},

	NPCBurst = {3, 3},
	NPCRate = 120
}

SWEP.Animations = {
	Fidget = ACT_VM_FIDGET
}

SWEP.Sounds = {
	Primary = Sound("Weapon_NeedleRifle.Single")
}

SWEP.Offsets = {
	Default = {
		Vector(2, -2, -3),
		Angle(0, 0, 0)
	},
	Holster = {
		Vector(5, 0, -2),
		Angle(20, 15, 0)
	},
	Sprint = {
		Vector(0, 0, -1),
		Angle(15, 5, 0)
	},
	Aiming = {
		Vector(-1, -1, -2),
		Angle(0, 0, 0)
	}
}

SWEP.Itemize = {
	Description = "The Type-31 Needle Rifle is a covenant infantry weapon infamous for it's lethality against infantry.",
	Rarity = RARITY_EPIC,

	Weight = 8,

	EquipmentSlots = {"primary", "secondary"},

	IconAngle = Angle(15, 45, 10),
	IconFOV = 12
}

if CLIENT then
	function SWEP:SetupPoseParameters(ent)
		ent:SetPoseParameter("drc_ammo", self:Clip1() / self.Settings.ClipSize)
	end
else
	function SWEP:BulletCallback(attacker, tr, dmginfo)
		BaseClass.BulletCallback(self, attacker, tr, dmginfo)

		AddNeedle(self, tr, 3)
	end
end

sound.Add({
	name = "Weapon_NeedleRifle.Single",
	channel = CHAN_WEAPON,
	volume = 0.72,
	level = 140,
	pitch = {98.5, 101.5},
	sound = {
		")vuthakral/halo/weapons/needlerifle/fire0.wav",
		")vuthakral/halo/weapons/needlerifle/fire1.wav",
		")vuthakral/halo/weapons/needlerifle/fire2.wav"
	}
})
