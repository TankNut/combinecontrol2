AddCSLuaFile()

function SWEP:CanFire(quiet)
	local owner = self:GetOwner()

	if owner:IsPlayer() then
		if self:GetHolstered() or self:GetDeployed() then
			if not quiet then
				self:ForceStopFire()
			end

			return false
		end

		if self:ShouldLower() or self:IsReloading() or self:GetShouldPump() then
			return false
		end
	end

	if (self.Primary.ClipSize > 0 and self:Clip1() <= 0) or self:GetFiremode() == FIREMODE_SAFE then
		if CLIENT and not quiet then
			self:EmitSound(self.Sounds.Empty)
		end

		if owner:IsNPC() then
			if SERVER and not quiet then
				owner:SetSchedule(SCHED_RELOAD)
			end

			return false
		end

		self:SetNextPrimaryFire(CurTime() + 0.2)

		if not quiet then
			self:ForceStopFire()
		end

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

	self:SetLastAttack(CurTime())
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

	-- This bit of code lets us run higher fire rates more accurately
	local time = CurTime()
	local nextFire = self:GetNextPrimaryFire()
	local diff = time - nextFire

	if diff > engine.TickInterval() or diff < 0 then
		nextFire = time
	end

	self:SetNextPrimaryFire(nextFire + (delay == -1 and anim or delay))

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
	self:TakePrimaryAmmo(self.Settings.AmmoCost)

	self["Fire" .. self.Stats.Type](self, self:GetOwner())
end
