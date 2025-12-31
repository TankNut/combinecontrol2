AddCSLuaFile()
DEFINE_BASECLASS("weapon_cc_base_plasma")

SWEP.Base = "weapon_cc_base_plasma"

SWEP.RenderGroup = RENDERGROUP_BOTH

SWEP.PrintName = "Spartan Laser"
SWEP.Category = "CombineControl - Halo"
SWEP.NPCCategory = "UNSC"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 54

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/vuthakral/halo/weapons/c_hum_gnr.mdl")
SWEP.WorldModel = Model("models/vuthakral/halo/weapons/w_gnr.mdl")

SWEP.Stats = {
	Type = "Bullet",
	Count = 1,

	Damage = 500,
	DamageFalloff = 1,

	Accuracy = 0,

	Tracer = "cc_e_tracer_splaser",
	TracerCount = 1
}

SWEP.Heat = {
	CoolDelay = 0.1,

	HeatRate = 100,
	CoolRate = 25,

	Max = 100,
	ForceOverheat = true,
	AllowManual = false
}

SWEP.Recoil = {
	Value = 10,

	PosMult = Vector(1, 0, 0.5),
	AngMult = Angle(0.5, 2),

	Punch = 1
}

SWEP.Settings = {
	LowerHoldType = "passive",
	BaseHoldType = "rpg",

	Firemodes = {FIREMODE_SEMI},

	ClipSize = 0,

	Range = 800,
	Zoom = {1.25, 3},

	NPCBurst = {1, 1}
}

SWEP.Animations = {
	Fidget = ACT_VM_FIDGET
}

SWEP.Sounds = {
	Charge = Sound("Weapon_Splaser.Charge"),
	Primary = Sound("Weapon_Splaser.Single"),

	OverheatStart = Sound("drc.gnr_overheat"),
	OverheatFinish = "null"
}

SWEP.Offsets = {
	Default = {
		Vector(0, -1, -1),
		Angle(0, 0, 0)
	},
	Holster = {
		Vector(0, 0, -2),
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
	Description = "Formally known as the Special Applications Rifle, Caliber 14.5mm, the SRS99-AM is a long-range anti-material rifle used by the UNSC.",
	Rarity = RARITY_EPIC,

	Weight = 10,

	EquipmentSlots = {"primary", "secondary"},

	IconAngle = Angle(15, 45, 10),
	IconFOV = 12
}

function SWEP:Think()
	local oldDuration = self:GetFireDuration()

	BaseClass.Think(self)

	local duration = self:GetFireDuration()

	if oldDuration == 0 and duration > 0 then
		self:EmitSound(self.Sounds.Charge)
	elseif oldDuration > 0 and duration == 0 then
		self:StopSound(self.Sounds.Charge)
	end

	if duration > 2.5 then
		self:FireLaser()
	end
end

function SWEP:PrimaryPlayer()
end

function SWEP:FireLaser()
	self:PrimeRandomSeed()
	self:UpdateFiremode()

	local anim = self:PlayAnimation("Primary")
	self:PlayerAnimation(PLAYER_ATTACK1)

	self:EmitSound(self.Sounds.Primary)
	self:FireWeapon()

	self:ApplyRecoil()

	local delay = self:GetDelay()

	-- This bit of code lets us run higher fire rates more accurately
	local time = CurTime()
	local nextFire = self:GetNextPrimaryFire()
	local diff = time - nextFire

	if diff > engine.TickInterval() or diff < 0 then
		nextFire = time
	end

	self:SetNextPrimaryFire(nextFire + (delay == -1 and anim or delay))
	self:SetCurrentHeat(math.min(self:GetCurrentHeat() + self.Heat.HeatRate, self.Heat.Max))
end

if CLIENT then
	function SWEP:SetupPoseParameters(ent)
		ent:SetPoseParameter("drc_charge", self:GetFireDuration() / 2.5)
	end

	local mat = Material("sprites/light_glow02_add")

	local color1 = Color(255, 0, 0)
	local color2 = Color(255, 150, 150)

	local laserColor = Color(255, 0, 0)
	local laserMat = Material("effects/draconic_halo/laser_thick")

	function SWEP:DrawLaser(ply, ent, scale)
		local charge = (self:GetFireDuration() / 2.5) * scale

		if charge == 0 then
			return
		end

		ent:SetupBones()

		local matrix = ent:GetBoneMatrix(ent:LookupBone("gun"))
		matrix:Translate(Vector(22, 0, 3.6))
		matrix:Scale(Vector(scale, scale, scale))

		local pos = matrix:GetTranslation()

		render.SetMaterial(mat)
		render.DrawSprite(pos, charge * 10, charge * 10, color1)
		render.DrawSprite(pos, charge * 5, charge * 5, color2)

		if charge > 0 then
			local start = ply:GetShootPos()
			local tr = util.TraceLine({
				start = start,
				endpos = start + self:GetShootDir() * MAX_LENGTH,
				mask = MASK_SHOT,
				filter = ply
			})

			laserColor.a = math.Remap(math.sin(UnPredictedCurTime() * 1000), -1, 1, 25, 100)

			render.SetMaterial(laserMat)
			render.DrawBeam(pos, tr.HitPos, scale * 2, 0, 1, laserColor)
		end
	end

	function SWEP:PostDrawViewModel(vm, _, ply)
		BaseClass.PostDrawViewModel(self, vm, self, ply)

		self:DrawLaser(ply, vm, 1)
	end

	function SWEP:PostDrawTranslucentRenderables()
		local ply = self:GetOwner()

		if IsValid(ply) and ply:IsPlayer() and ply:ShouldDrawLocalPlayer() then
			self:DrawLaser(ply, self, ply:GetModelScale())
		end
	end

	function SWEP:DoDrawCrosshair()
		return true
	end
end

function SWEP:DoImpactEffect(tr, dmgtype)
	return true
end

sound.Add({
	name = "Weapon_Splaser.Charge",
	channel = CHAN_WEAPON,
	volume = 0.72,
	level = 100,
	pitch = 100,
	sound = "^vuthakral/halo/weapons/gnr/charge_in.wav"
})

sound.Add({
	name = "Weapon_Splaser.Single",
	channel = CHAN_WEAPON,
	volume = 0.72,
	level = 140,
	pitch = {99.5, 106},
	sound = {
		")vuthakral/halo/weapons/gnr/fire0.wav",
		")vuthakral/halo/weapons/gnr/fire1.wav",
		")vuthakral/halo/weapons/gnr/fire2.wav"
	}
})
