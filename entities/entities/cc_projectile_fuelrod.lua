AddCSLuaFile()
DEFINE_BASECLASS("cc_base_projectile")

ENT.Base = "cc_base_projectile"

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Model = Model("models/vuthakral/halo/weapons/fuelrod_rod.mdl")

ENT.Velocity = 1000
ENT.Gravity = 0.4

ENT.LoopSound = Sound("drc.fuelrod_flight")

ENT.Damage = 100

local color = Color(0, 200, 0)

if CLIENT then
	function ENT:Initialize()
		BaseClass.Initialize(self)

		local effect = EffectData()
		effect:SetOrigin(self:GetPos())
		effect:SetEntity(self)

		util.Effect("cc_e_fuelrod", effect)
	end

	function ENT:Think()
		BaseClass.Think(self)

		local dlight = DynamicLight(self:EntIndex())

		dlight.Pos 			= self:GetPos()
		dlight.Size 		= 250
		dlight.Brightness 	= 0
		dlight.Style		= 0
		dlight.r 			= 0
		dlight.g 			= 255
		dlight.b 			= 0
		dlight.Decay 		= 2000
		dlight.DieTime 		= CurTime() + 0.1
	end

	local sprite = Material("sprites/light_glow02_add")
	local mat = Material("engine/singlecolor")

	function ENT:Draw()
		render.SetColorModulation(color:UnpackToVector())

		render.MaterialOverride(mat)
			self:DrawModel()
		render.MaterialOverride()
	end

	function ENT:DrawTranslucent()
		local pos = self:GetPos()

		render.SetMaterial(sprite)

		local w = math.Rand(40, 45)
		local h = math.Rand(40, 45)

		render.DrawSprite(pos, w, h, color)
		render.DrawSprite(pos, w, h, color)
	end
else
	function ENT:Initialize()
		BaseClass.Initialize(self)

		util.SpriteTrail(self, 0, color, true, 100, 100, 0.1, 0.0125, "taconbanana/halo/trails/plasmarifle")
	end

	function ENT:OnHit(tr)
		self:SetImpact(tr.HitPos)

		util.Explosion(tr.HitPos, self:GetOwner(), self.Damage, SF_EXPLOSION_DECAL_ONLY)

		local effect = EffectData()
		effect:SetOrigin(tr.HitPos)
		effect:SetEntity(self)

		util.Effect("drc_halo_fuelrod_explode", effect, true, true)

		-- New way of doing distant sounds?
		local filter = RecipientFilter()
		filter:AddAllPlayers()

		self:EmitSound("Weapon_FuelRod.Explode", 75, 100, 1, CHAN_AUTO, 0, 1, filter)
		self:Remove()
	end
end

sound.Add({
	name = "Weapon_FuelRod.Explode",
	channel = CHAN_STATIC,
	volume = 1,
	level = 140,
	pitch = 100,
	sound = {
		")vuthakral/halo/weapons/t33b/explode0.wav",
		")vuthakral/halo/weapons/t33b/explode1.wav",
		")vuthakral/halo/weapons/t33b/explode2.wav"
	}
})
