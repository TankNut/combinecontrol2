AddCSLuaFile()
DEFINE_BASECLASS("weapon_cc_base_gun")

SWEP.Base = "weapon_cc_base_gun"

SWEP.PrintName = "M6G Magnum"
SWEP.Category = "CombineControl - Halo"
SWEP.NPCCategory = "UNSC"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 54

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/vuthakral/halo/weapons/c_hum_m6g_reach.mdl")
SWEP.WorldModel = Model("models/vuthakral/halo/weapons/w_m6g_reach.mdl")

SWEP.Stats = {
	Type = "Bullet",
	Count = 1,

	Damage = 32,
	DamageFalloff = DMG_FALLOFF_RIFLE,

	Accuracy = ACCURACY_GOOD,
	Range = RANGE_PISTOL,

	Tracer = "Tracer",
	TracerCount = 1
}

SWEP.Recoil = {
	Value = 1,

	PosMult = Vector(0, 0, 0),
	AngMult = Angle(0, 0),

	Punch = 0.6
}

SWEP.Settings = {
	LowerHoldType = "normal",
	BaseHoldType = "pistol_aimed",

	Firemodes = {FIREMODE_SEMI},
	FireRate = 240,

	ClipSize = 8
}

SWEP.Sounds = {
	Primary = Sound("Weapon_M6G.Single")
}

SWEP.Offsets = {
	Default = {
		Vector(0, 0, 0),
		Angle(0, 0, 0)
	},
	Holster = {
		Vector(0, 0, 0),
		Angle(15, 15, 0)
	},
	Sprint = {
		Vector(0, 0, 0),
		Angle(15, 0, 0)
	},
	Aiming = {
		Vector(0, 0, 0),
		Angle(-1, 0, 0)
	}
}

SWEP.Itemize = {
	Description = "Formally known as the M7/Caseless, the M7 is a UNSC issued PDW commonly used by infantry, special forces and vehicle crews.",
	Rarity = RARITY_COMMON,

	Weight = 2,

	EquipmentSlots = {"primary", "secondary"},

	IconAngle = Angle(15, 45, 10),
	IconFOV = 12
}

if CLIENT then
	function SWEP:SetupPoseParameters(ent)
		local bool = self:Clip1() > 0

		if self:IsReloading() and self:GetFinishReload() - CurTime() < 0.65 then
			bool = true
		end

		ent:SetPoseParameter("drc_emptymag", bool and 1 or 0)
	end
end

function SWEP:FireAnimationEvent(_, _, _, name)
	if name == "drc.halo_eject_rifle" then
		return true
	end
end

sound.Add({
	name = "Weapon_M6G.Single",
	channel = CHAN_WEAPON,
	volume = 0.72,
	level = 140,
	pitch = {98.5, 101.5},
	sound = {
		")vuthakral/halo/weapons/m6gr/fire0.wav",
		")vuthakral/halo/weapons/m6gr/fire1.wav",
		")vuthakral/halo/weapons/m6gr/fire2.wav",
		")vuthakral/halo/weapons/m6gr/fire3.wav"
	}
})
