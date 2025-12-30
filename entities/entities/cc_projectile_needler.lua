AddCSLuaFile()
DEFINE_BASECLASS("cc_base_rocket")

ENT.Base = "cc_base_rocket"

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Model = Model("models/vuthakral/halo/weapons/w_needle.mdl")

ENT.Damage = 6
ENT.Velocity = 1400

ENT.TurnRate = 15

local color = Color(220, 0, 255)

if CLIENT then
	local sprite = Material("sprites/light_glow02_add")

	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:DrawTranslucent()
		local pos = self:GetPos()

		render.SetMaterial(sprite)

		render.DrawSprite(pos, 8, 8, color)
		render.DrawSprite(pos, 8, 8, color)
	end
else
	function ENT:Initialize()
		BaseClass.Initialize(self)

		util.SpriteTrail(self, 0, color, true, 20, 0, 0.1, 0.0125, "taconbanana/halo/trails/plasmarifle")
	end

	function ENT:UpdateVelocity(vel, delta)
		local target = self.Target

		if not IsValid(target) then
			return
		end

		local targetPos = target:GetPos() + VectorRand(target:GetModelBounds())
		local speed = vel:Length()

		do
			local distance = targetPos:Distance(self:GetPos())
			local impactTime = distance / speed

			targetPos:Add(target:GetVelocity() * impactTime)
		end

		local diff = (targetPos - self:GetPos()):Angle()
		local localAng = self:WorldToLocalAngles(diff)

		if not math.InRange(localAng.p, -90, 90) or not math.InRange(localAng.y, -90, 90) then
			return
		end

		local ang = vel:Angle()
		ang.p = math.ApproachAngle(ang.p, diff.p, self.TurnRate * delta)
		ang.y = math.ApproachAngle(ang.y, diff.y, self.TurnRate * delta)
		ang.r = 0

		return ang:Forward() * speed
	end

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
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetDamagePosition(tr.HitPos)
			dmg:SetDamageForce(tr.Normal * (damage * 75))

			dmg:SetInflictor(self)

			local attacker = self:GetOwner()

			if IsValid(attacker) then dmg:SetAttacker(attacker) end
			if IsValid(self.Weapon) then dmg:SetWeapon(self.Weapon) end

			ent:DispatchTraceAttack(dmg, tr, tr.Normal)
		end

		AddNeedle(self, tr, 1)

		self:SetNoDraw(true)

		SafeRemoveEntityDelayed(self, 0.1)
	end
end
