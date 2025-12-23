AddCSLuaFile()
DEFINE_BASECLASS("weapon_cc_base_gun")

SWEP.Base = "weapon_cc_base_gun"

SWEP.PrintName = "M392 DMR"
SWEP.Category = "CombineControl - Halo"
SWEP.NPCCategory = "UNSC"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 54

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/vuthakral/halo/weapons/c_hum_dmr.mdl")
SWEP.WorldModel = Model("models/vuthakral/halo/weapons/w_dmr.mdl")

SWEP.Stats = {
	Type = "Bullet",
	Count = 1,

	Damage = 18,
	DamageFalloff = 0.98,

	Accuracy = {12, 2},

	Tracer = "Tracer",
	TracerCount = 1
}

SWEP.Recoil = {
	Value = 1.5,

	PosMult = Vector(1, 0, 0.5),
	AngMult = Angle(0.6, 0.2),

	Punch = 0.6
}

SWEP.Settings = {
	LowerHoldType = "passive",
	BaseHoldType = "ar2",

	Firemodes = {FIREMODE_SEMI},
	FireRate = 180,

	ClipSize = 15,

	Range = 800,
	Zoom = {1.25, 3},

	NPCBurst = {3, 3},
	NPCRate = 120
}

SWEP.Animations = {
	Fidget = ACT_VM_FIDGET
}

SWEP.Sounds = {
	Primary = Sound("Weapon_DMR.Single")
}

SWEP.Offsets = {
	Default = {
		Vector(0, -0.5, -2),
		Angle(0, 0, 0)
	},
	Holster = {
		Vector(0, 0, -1),
		Angle(15, 15, 0)
	},
	Sprint = {
		Vector(0, 0, -1),
		Angle(15, 5, 0)
	},
	Aiming = {
		Vector(0, 0, -0.5),
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

function SWEP:FireAnimationEvent(_, _, _, name)
	if name == "drc.halo_eject_rifle" then
		return true
	end
end

if CLIENT then
	local fill = Color(37, 141, 170)
	local outline = Color(16, 60, 80)

	function SWEP:GetVisibleAmmo()
		local ammo = self:Clip1()

		if ammo == -1 then
			ammo = self.Settings.ClipSize
		end

		return ammo < 10 and "0" .. ammo or ammo
	end

	function SWEP:DrawAmmoCounter(ent, scale)
		local matrix = ent:GetBoneMatrix(ent:LookupBone("b_gun"))

		matrix:Translate(Vector(1.72, 0, 6.15))
		matrix:Rotate(Angle(0, -90, 90))
		matrix:Scale(Vector(scale, scale, scale))

		cam.Start3D2D(matrix:GetTranslation(), matrix:GetAngles(), 0.003)
			draw.SimpleTextOutlined(self:GetVisibleAmmo(), "reach_ammocounter", 0, 12.5, fill, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, outline)
		cam.End3D2D()
	end

	function SWEP:PostDrawViewModel(vm, _, ply)
		BaseClass.PostDrawViewModel(self, vm, self, ply)

		self:DrawAmmoCounter(vm, 1)
	end

	function SWEP:DrawWorldModel(flags)
		BaseClass.DrawWorldModel(self, flags)

		local scale = 1
		local ply = self:GetOwner()

		if IsValid(ply) and ply:IsPlayer() then
			if ply:IsCloaked() then
				return
			end

			scale = ply:GetModelScale()
		end

		self:DrawAmmoCounter(self, scale)
	end
end

sound.Add({
	name = "Weapon_DMR.Single",
	channel = CHAN_WEAPON,
	volume = 1,
	level = 140,
	pitch = {95, 105},
	sound = {
		")vuthakral/halo/weapons/dmr/fire0.wav",
		")vuthakral/halo/weapons/dmr/fire1.wav",
		")vuthakral/halo/weapons/dmr/fire2.wav"
	}
})
