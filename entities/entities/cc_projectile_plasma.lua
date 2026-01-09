AddCSLuaFile()
DEFINE_BASECLASS("cc_base_projectile")

ENT.Base = "cc_base_projectile"

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.Model = Model("models/maxofs2d/hover_classic.mdl")

ENT.Scale = 1

ENT.Damage = {20, 40}
ENT.Velocity = 6350

ENT.TrailLifetime = 0.15
ENT.TrailColor = Color(25, 200, 255)

ENT.SpriteColor1 = Color(16, 195, 255)
ENT.SpriteColor2 = Color(16, 195, 255)

ENT.ImpactEffect = "cc_e_impact_plasma_rifle"
ENT.ImpactFlags = 1

function ENT:Initialize()
	BaseClass.Initialize(self)

	if SERVER then
		util.SpriteTrail(self, 0, self.TrailColor, true, 40 * self.Scale, 0, self.TrailLifetime, 0.0125, "taconbanana/halo/trails/plasmarifle.vmt")
	end
end

if CLIENT then
	local sprite = Material("sprites/glow04_noz")

	function ENT:DrawTranslucent(flags)
		local pos = self:GetPos()

		if IsValid(self:GetOwner()) and pos:Distance(self:GetOrigin()) < self:GetOwner():GetModelRadius() * 0.5 then
			return
		end

		if self:GetImpact() != vector_origin and pos:Distance(self:GetOrigin()) < 10 then
			return
		end

		local size = math.Rand(30, 35) * self.Scale
		local size2 = self.Scale * 10

		render.SetMaterial(sprite)

		render.DrawSprite(pos, size, size, self.SpriteColor1)
		render.DrawSprite(pos, size2, size2, self.SpriteColor2)
	end
else
	function ENT:OnHit(tr)
		self:SetImpact(tr.HitPos)

		local ent = tr.Entity

		if IsValid(ent) and ent.DispatchTraceAttack then
			local dmg = DamageInfo()
			local damage = self.Damage

			if istable(damage) then
				damage = math.random(self.Damage[1], self.Damage[2])
			end

			dmg:SetDamage(damage)
			dmg:SetDamageType(DMG_ENERGYBEAM)
			dmg:SetDamagePosition(tr.HitPos)
			dmg:SetDamageForce(tr.Normal * (damage * 75))

			dmg:SetInflictor(self)

			local attacker = self:GetOwner()

			if IsValid(attacker) then dmg:SetAttacker(attacker) end
			if IsValid(self.Weapon) then dmg:SetWeapon(self.Weapon) end

			ent:DispatchTraceAttack(dmg, tr, tr.Normal)
		end

		if not tr.HitSky then
			local effectData = EffectData()

			effectData:SetOrigin(tr.HitPos)
			effectData:SetNormal(tr.HitNormal)
			effectData:SetFlags(self.ImpactFlags)
			effectData:SetScale(self.Scale)

			util.Effect(self.ImpactEffect, effectData)
		end

		SafeRemoveEntityDelayed(self, self.TrailLifetime)
	end
end
