AddCSLuaFile()

function SWEP:CanFire()
	local owner = self:GetOwner()

	if owner:IsPlayer() then
		if self:GetHolstered() then
			self:ForceStopFire()

			return false
		end

		if self:ShouldLower() then
			return false
		end
	end

	if self.Primary.ClipSize > 0 and self:Clip1() <= 0 then
		if CLIENT then
			self:EmitSound(self.Sounds.Empty)
		end

		if owner:IsNPC() then
			if SERVER then
				owner:SetSchedule(SCHED_RELOAD)
			end

			return false
		end

		self:SetNextPrimaryFire(CurTime() + 0.2)
		self:ForceStopFire()

		return false
	end

	return true
end

function SWEP:PrimaryAttack()
	if not self:CanFire() then
		return
	end

	local owner = self:GetOwner()

	if owner:IsPlayer() then
		self:PrimaryPlayer(owner)
	else
		self:PrimaryNPC(owner)
	end
end

function SWEP:PrimaryPlayer(ply)
	self:UpdateFiremode()

	local anim = self:PlayAnimation("Attack")
	ply:SetAnimation(PLAYER_ATTACK1)

	self:EmitSound(self.Sounds.Primary)
	self:FireWeapon()

	self:ApplyRecoil()

	local delay = self:GetDelay()

	self:SetNextIdle(CurTime() + anim)
	self:SetNextPrimaryFire(CurTime() + (delay == -1 and anim or delay))
end

function SWEP:PrimaryNPC(npc)
	npc:SetAnimation(PLAYER_ATTACK1)

	self:EmitSound(self.Sounds.Primary)
	self:FireWeapon()
end

function SWEP:SecondaryAttack()
end

function SWEP:UpdateFiremode()
	local firemode = self:GetFiremode()

	self.Primary.Automatic = firemode != 0

	if firemode > 0 then
		local count = self:GetBurstIndex()

		if count + 1 >= firemode then
			self:ForceStopFire()
			self:SetBurstIndex(0)
		else
			self:SetBurstIndex(count + 1)
		end
	end
end

function SWEP:FireWeapon()
	self["Fire" .. self.Stats.Type](self, self:GetOwner())
end

function SWEP:FireBullet(ply)
	local tracer, count = self:GetTracerEffect()
	local damage = self:GetDamage()

	local bullet = {
		Num = self:GetBulletCount(),
		Src = ply:GetShootPos(),
		Dir = self:GetShootDir(),
		Spread = self:GetSpread(),
		TracerName = tracer,
		Tracer = count,
		Force = damage * 0.25,
		Damage = damage,
		Callback = function(attacker, tr, dmginfo)
			dmginfo:ScaleDamage(self:GetDamageFalloff(tr.StartPos:Distance(tr.HitPos)))
		end
	}

	ply:FireBullets(bullet)
end

function SWEP:DoImpactEffect(tr, dmgtype)
	local impact = self:GetImpactEffect()

	if impact and not tr.HitSky then
		local effectData = EffectData()

		effectData:SetOrigin(tr.HitPos + tr.HitNormal)
		effectData:SetNormal(tr.HitNormal)

		util.Effect(impact, effectData)
	end
end
