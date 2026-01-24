AddCSLuaFile()
DEFINE_BASECLASS("weapon_cc_base_gun")

SWEP.Base = "weapon_cc_base_gun"

SWEP.PrintName = "Type-33 Needler"
SWEP.Category = "CombineControl - Halo"
SWEP.NPCCategory = "Covenant"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 54

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/vuthakral/halo/weapons/c_hum_needler.mdl")
SWEP.WorldModel = Model("models/vuthakral/halo/weapons/w_needler.mdl")

SWEP.Stats = {
	Type = "Projectile",
	Class = "cc_projectile_needler",

	Offset = Vector(8, -8, -8),

	Accuracy = ACCURACY_POOR,
	Range = RANGE_SMG
}

SWEP.Recoil = {
	Value = 0.6,

	PosMult = Vector(0.2, 0, 0.3),
	AngMult = Angle(0.3, 1.2),

	Punch = 0.6
}

SWEP.Settings = {
	LowerHoldType = "normal",
	BaseHoldType = "pistol",

	Firemodes = {FIREMODE_AUTO},

	ClipSize = 20,
	ReloadTime = 1.4
}

SWEP.Animations = {
	Fidget = ACT_VM_FIDGET
}

SWEP.Sounds = {
	Primary = Sound("Weapon_Needler.Single")
}

SWEP.Offsets = {
	Default = {
		Vector(3, 0, 0),
		Angle(0, 0, 0)
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
		Vector(0, 0, 1),
		Angle(-1, 0, 0)
	}
}

SWEP.Itemize = {
	Description = "The Type-25 Needler is a covenant infantry weapon that's feared for it's effectiveness against unshielded targets.",
	Rarity = RARITY_RARE,

	Weight = 4,

	EquipmentSlots = {"primary", "secondary"},

	IconAngle = Angle(15, 45, 10),
	IconFOV = 12
}

function SWEP:GetDelay()
	return math.ClampedRemap(self:GetFireDuration(), 0, 0.8, 0.125, 0.083)
end

if CLIENT then
	function SWEP:FinishReload()
		BaseClass.FinishReload(self)

		-- Sigh
		if lp == self:GetOwner() and not lp:ShouldDrawLocalPlayer() then
			self:EmitSound("drc.Needler_reload_end")
		end
	end

	function SWEP:SetupPoseParameters(ent)
		ent:SetPoseParameter("drc_ammo", self:Clip1() / self.Settings.ClipSize)
	end
else
	function SWEP:GetNeedlerTarget(owner, tr)
		local function validTarget(ent)
			if not IsValid(ent) or ent == owner then
				return false
			end

			if not (ent:IsNPC() or ent:IsPlayer()) then
				return false
			end

			if not ent:Alive() then
				return false
			end

			if not owner:VisibleVec(ent:WorldSpaceCenter()) then
				return false
			end

			return true
		end

		if validTarget(tr.Entity) then
			return tr.Entity
		end

		local pos = tr.StartPos

		local targets = ents.FindInCone(pos, tr.Normal, 2000, math.cos(math.rad(15)))
		local maxDist = math.huge
		local target

		for _, v in pairs(targets) do
			if not validTarget(v) then
				continue
			end

			local dist = pos:DistToSqr(v:WorldSpaceCenter())

			if dist >= maxDist then
				continue
			end

			target = v
			maxDist = dist
		end

		return target
	end

	function SWEP:FireProjectile(owner)
		local stats = self.Stats

		for i = 1, stats.Count do
			local ent = ents.Create(stats.Class)
			local pos, ang, tr = self:GetProjectileSetup(owner, Vector(stats.Offset or vector_origin), stats.Angle or angle_zero)

			ent.Target = self:GetNeedlerTarget(owner, tr)

			ent:SetPos(pos)
			ent:SetAngles(ang)

			ent:SetOwner(owner)
			ent:Spawn()
		end
	end
end

sound.Add({
	name = "Weapon_Needler.Single",
	channel = CHAN_WEAPON,
	volume = 0.72,
	level = 80,
	pitch = {98, 101},
	sound = {
		")vuthakral/halo/weapons/Needler/fire0.wav",
		")vuthakral/halo/weapons/Needler/fire1.wav",
		")vuthakral/halo/weapons/Needler/fire2.wav"
	}
})
