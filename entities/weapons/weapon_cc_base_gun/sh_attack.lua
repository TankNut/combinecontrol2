AddCSLuaFile()

function SWEP:CanFire()
	local owner = self:GetOwner()

	if owner:IsPlayer() then
		if self:GetHolstered() or self:GetDeployed() then
			self:ForceStopFire()

			return false
		end

		if self:ShouldLower() or self:IsReloading() or self:GetShouldPump() then
			return false
		end
	end

	if (self.Primary.ClipSize > 0 and self:Clip1() <= 0) or self:GetFiremode() == FIREMODE_SAFE then
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
	if self:TryShove() or self:TryCancelReload() or not self:CanFire() then
		return
	end

	if self:GetOwner():IsPlayer() then
		self:PrimaryPlayer()
	else
		self:PrimaryNPC()
	end
end

function SWEP:PrimaryPlayer()
	self:PrimeRandomSeed()
	self:UpdateFiremode()

	local anim = self:PlayAnimation("Primary")
	self:PlayerAnimation(PLAYER_ATTACK1)

	self:EmitSound(self.Sounds.Primary)
	self:FireWeapon()

	self:ApplyRecoil()

	local delay = self:GetDelay()

	self:SetNextPrimaryFire(CurTime() + (delay == -1 and anim or delay))

	if self.Settings.PumpAction then
		self:SetShouldPump(true)
	end
end

function SWEP:PrimaryNPC(npc)
	self:PlayerAnimation(PLAYER_ATTACK1)

	self:EmitSound(self.Sounds.Primary)
	self:FireWeapon()
end

function SWEP:SecondaryAttack()
end

function SWEP:GetFiremode()
	return self.Settings.Firemodes[self:GetFiremodeIndex()]
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

function SWEP:CycleFiremode()
	local firemodes = self.Settings.Firemodes

	if #firemodes == 1 then
		return
	end

	local index = self:GetFiremodeIndex() + 1

	if index > #firemodes then
		index = 1
	end

	self:SetFiremodeIndex(index)
end

function SWEP:FireWeapon()
	self:TakePrimaryAmmo(self:GetAmmoCost())

	self["Fire" .. self.Stats.Type](self, self:GetOwner())
end

function SWEP:FireBullet(owner)
	local tracer, count = self:GetTracerEffect()
	local damage = self:GetDamage()

	local bullet = {
		Num = self:GetBulletCount(),
		Src = owner:GetShootPos(),
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

	owner:FireBullets(bullet)
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
