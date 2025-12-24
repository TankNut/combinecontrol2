AddCSLuaFile()
DEFINE_BASECLASS("weapon_cc_base_plasma")

SWEP.Base = "weapon_cc_base_plasma"

SWEP.PrintName = "M247H Heavy Machine Gun"
SWEP.Category = "CombineControl - Halo"
SWEP.NPCCategory = "UNSC"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 54

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/vuthakral/halo/weapons/c_hum_m247h.mdl")
SWEP.WorldModel = Model("models/vuthakral/halo/weapons/w_m247h.mdl")

SWEP.Stats = {
	Type = "Bullet",
	Count = 1,

	Damage = 11,
	DamageFalloff = 0.98,

	Accuracy = {12, 2},

	Tracer = "Tracer",
	TracerCount = 1
}

SWEP.Heat = {
	CoolDelay = 0.4,

	HeatRate = 2,
	CoolRate = 40,

	Max = 100,
	ForceOverheat = true,
	AllowManual = false
}

SWEP.Recoil = {
	Value = 1,

	PosMult = Vector(2, 0, 1),
	AngMult = Angle(0, 0.2),

	Punch = 0.6
}

SWEP.Settings = {
	LowerHoldType = "heavy",
	BaseHoldType = "heavy",

	Firemodes = {FIREMODE_AUTO},
	FireRate = 600,

	ClipSize = 0,

	Range = 400,
	Zoom = {1.25},
}

SWEP.Animations = {
	Fidget = ACT_VM_FIDGET
}

SWEP.Sounds = {
	Primary = Sound("Weapon_M247.Single")
}

SWEP.Offsets = {
	Default = {
		Vector(0, 0, -5),
		Angle(0, 4, 0)
	},
	Holster = {
		Vector(0, 0, 0),
		Angle(20, 15, 0)
	},
	Sprint = {
		Vector(0, 0, -1),
		Angle(15, 5, 0)
	},
	Aiming = {
		Vector(-4, 0, -3),
		Angle(0, 4, 0)
	}
}

SWEP.Itemize = {
	Description = "A spartan-portable version of the M247 Heavy Machine Gun.",
	Rarity = RARITY_LEGENDARY,

	Weight = 15,

	EquipmentSlots = {"primary", "secondary"},

	IconAngle = Angle(15, 45, 10),
	IconFOV = 12
}

function SWEP:GetDelay()
	return math.ClampedRemap(self:GetHeat(), 0.7, 1, 0.1, 0.15)
end

if CLIENT then
	function SWEP:Initialize()
		self.ClientsideModel = ClientsideModel(self.WorldModel)
		self.ClientsideModel:SetNoDraw(true)

		BaseClass.Initialize(self)
	end

	local offsetVec = Vector(-5, -2, 3)
	local offsetAng = Angle(5, 0, 175)

	function SWEP:DrawWorldModel(flags)
		local ply = self:GetOwner()

		if IsValid(ply) then
			local boneid = ply:LookupBone("ValveBiped.Bip01_R_Hand") -- Right Hand
			if !boneid then return end

			local matrix = ply:GetBoneMatrix(boneid)
			if !matrix then return end

			local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

			self.ClientsideModel:SetModelScale(ply:GetModelScale(), 0)
			self.ClientsideModel:SetPos(newPos)
			self.ClientsideModel:SetAngles(newAng)

			self.ClientsideModel:SetupBones()
		else
			self.ClientsideModel:SetModelScale(1, 0)
			self.ClientsideModel:SetPos(self:GetPos())
			self.ClientsideModel:SetAngles(self:GetAngles())
		end

		self.ClientsideModel:DrawModel(flags)
	end

	function SWEP:GetTracerOrigin()
		local ply = self:GetOwner()

		if IsValid(ply) and ply:ShouldDrawLocalPlayer() then
			return self.ClientsideModel:GetAttachment(1).Pos
		end
	end
end

sound.Add({
	name = "Weapon_M247.Single",
	channel = CHAN_WEAPON,
	volume = 1,
	level = 140,
	pitch = {95, 105},
	sound = {
		")vuthakral/halo/weapons/aie/fire0.wav",
		")vuthakral/halo/weapons/aie/fire1.wav",
		")vuthakral/halo/weapons/aie/fire2.wav"
	}
})
