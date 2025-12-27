AddCSLuaFile()
DEFINE_BASECLASS("weapon_cc_base_gun")

SWEP.Base = "weapon_cc_base_gun"

SWEP.PrintName = "SRS99-AM"
SWEP.Category = "CombineControl - Halo"
SWEP.NPCCategory = "UNSC"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 54

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/vuthakral/halo/weapons/c_hum_srs99am.mdl")
SWEP.WorldModel = Model("models/vuthakral/halo/weapons/w_srs99am.mdl")

SWEP.Stats = {
	Type = "Bullet",
	Count = 1,

	Damage = 120,
	DamageFalloff = 0.98,

	Accuracy = {12, 2},

	Tracer = "cc_e_tracer_smoke",
	TracerCount = 1
}

SWEP.Recoil = {
	Value = 5,

	PosMult = Vector(1, 0, 0.5),
	AngMult = Angle(0.5, 2),

	Punch = 1
}

SWEP.Settings = {
	LowerHoldType = "passive",
	BaseHoldType = "ar2",
	AimHoldType = "sniper",

	Firemodes = {FIREMODE_AUTO},
	FireRate = 60,

	ClipSize = 4,

	Range = 400,
	ScopedRange = 2400,
	Zoom = {1.25, 5, 8, 20},
	ScopeIndex = 2,

	NPCBurst = {1, 1}
}

SWEP.Scope = {
	Scale = 0.5,
	Width = 1.65,
	Height = 1,

	Material = Material("models/vuthakral/halo/HUD/scope_sniper.png", "smooth")
}

SWEP.Animations = {
	Fidget = ACT_VM_FIDGET
}

SWEP.Sounds = {
	Primary = Sound("Weapon_SRS99AM.Single")
}

SWEP.Offsets = {
	Default = {
		Vector(0, -1, -3),
		Angle(1, 0, 0)
	},
	Holster = {
		Vector(3, -2, 0),
		Angle(20, 20, 0)
	},
	Sprint = {
		Vector(0, 0, -1),
		Angle(25, 15, 0)
	},
	Aiming = {
		Vector(0, 1, -1),
		Angle(1, 0, 0)
	}
}

SWEP.Itemize = {
	Description = "Formally known as the Special Applications Rifle, Caliber 14.5mm, the SRS99-AM is a long-range anti-material rifle used by the UNSC.",
	Rarity = RARITY_EPIC,

	Weight = 10,

	EquipmentSlots = {"primary", "secondary"},

	IconAngle = Angle(15, 45, 10),
	IconFOV = 12
}

if CLIENT then
	local nan = Vector(0 / 0, 0 / 0, 0 / 0)
	local reset = Vector(1, 1, 1)

	function SWEP:PreDrawViewModel(vm, _, ply)
		if BaseClass.PreDrawViewModel(self, vm, self, ply) then
			return true
		end

		vm:ManipulateBoneScale(74, nan)
		vm:SetupBones()
	end

	function SWEP:PostDrawViewModel(vm, _, ply)
		BaseClass.PostDrawViewModel(self, vm, self, ply)

		vm:ManipulateBoneScale(74, reset)
	end

	local reticle = Material("models/vuthakral/halo/hud/reticles/ret_sr")

	function SWEP:DrawScopeOverlay(x, y, w, h)
		local midX = ScrW() * 0.5
		local midY = ScrH() * 0.5

		surface.SetDrawColor(0, 0, 0, 255)

		local scale = ScreenScaleH(9)

		surface.SetMaterial(reticle)
		surface.DrawTexturedRect(midX - scale * 0.5 + 1, midY - scale * 0.5 + 1, scale, scale)
	end
end

sound.Add({
	name = "Weapon_SRS99AM.Single",
	channel = CHAN_WEAPON,
	volume = 1,
	level = 140,
	pitch = {98.5, 101.5},
	sound = {
		")vuthakral/halo/weapons/srs99am/fire0.wav",
		")vuthakral/halo/weapons/srs99am/fire1.wav"
	}
})
