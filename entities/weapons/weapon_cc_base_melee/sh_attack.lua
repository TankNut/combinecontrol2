AddCSLuaFile()

function SWEP:GetDamage()
	local damage = self.Stats.Damage

	if istable(damage) then
		return math.random(damage[1], damage[2]), self.Stats.DamageType
	else
		return damage, self.Stats.DamageType
	end
end

function SWEP:GetDelay(hit)
	local delay = self.Stats.Delay

	if istable(delay) then
		return hit and delay[1] or delay[2]
	else
		return delay
	end
end

local phys_pushscale = GetConVar("phys_pushscale")

function SWEP:PerformSwing()
	self:PrimeRandomSeed()

	local stats = self.Stats
	local ply = self:GetOwner()

	self:PlayerAnimation(PLAYER_ATTACK1)

	ply:LagCompensation(true)

	local trace = {
		start = ply:GetShootPos(),
		endpos = ply:GetShootPos() + self:GetShootDir() * stats.Reach,
		filter = ply,
		mask = MASK_SHOT_HULL,
		mins = Vector(-10, -10, -8),
		maxs = Vector(10, 10, 8)
	}

	local tr = util.TraceLine(trace)
	local line = tr

	if not IsValid(tr.Entity) then
		tr = util.TraceHull(trace)
	end

	local ent = tr.Entity

	if tr.Hit then
		if self.Sounds.HitWall then
			local hitFlesh = IsValid(ent) and (ent:IsNPC() or ent:IsPlayer())

			self:PlaySound(hitFlesh and "Hit" or "HitWall")
		else
			self:PlaySound("Hit")
		end

		self:PlayAnimation("MeleeHit")
	else
		self:PlaySound("Miss")
		self:PlayAnimation("MeleeMiss")
	end

	local scale = phys_pushscale:GetFloat()
	local damage = self:GetDamage()

	if IsValid(ent) and (ent:IsNPC() or ent:IsPlayer() or ent:Health() > 0) then
		local dmginfo = DamageInfo()

		dmginfo:SetAttacker(ply)
		dmginfo:SetInflictor(self)
		dmginfo:SetDamagePosition(tr.HitPos)

		local force = Vector(40, 20, 0)

		force:Mul(damage * scale)
		force:Rotate(self:GetShootDir():Angle())

		dmginfo:SetDamageForce(force)
		dmginfo:SetDamage(damage)
		dmginfo:SetDamageType(stats.DamageType)

		ent:DispatchTraceAttack(dmginfo, tr)
	end

	if IsValid(ent) then
		local phys = ent:GetPhysicsObject()

		if IsValid(phys) then
			phys:ApplyForceOffset(ply:GetAimVector() * damage * 10 * phys:GetMass() * scale, tr.HitPos)
		end
	end

	if IsFirstTimePredicted() and line.Hit then
		local effectData = EffectData()

		effectData:SetOrigin(line.HitPos)
		effectData:SetStart(line.StartPos)
		effectData:SetNormal(line.HitNormal)
		effectData:SetSurfaceProp(line.SurfaceProps)
		effectData:SetDamageType(stats.DamageType)
		effectData:SetHitBox(line.HitBox)
		effectData:SetEntity(line.Entity)

		util.Effect("Impact", effectData)

		if self.Settings.Effect then
			util.Effect(self.Settings.Effect, effectData)
		end
	end

	ply:LagCompensation(false)

	self:SetNextPrimaryFire(CurTime() + self:GetDelay(tr.Hit))
end
