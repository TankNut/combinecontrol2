AddCSLuaFile()

function SWEP:IsReloading()
	return self:GetFinishReload() != 0
end

function SWEP:CanReload()
	if self:GetHolstered() or self:ShouldLower() then
		return false
	end

	if self:Clip1() >= self.Primary.ClipSize then
		return false
	end

	if self:IsReloading() then
		return false
	end

	return true
end

function SWEP:StartReload()
	local ply = self:GetOwner()

	ply:SetAnimation(PLAYER_RELOAD)

	if self.Settings.ShotgunReload then
		self:SetFirstReload(true)
		self:SetFinishReload(CurTime() + self:PlayAnimation("ReloadStart"))
	else
		self:PlaySound("Reload")
		self:SetFinishReload(CurTime() + self:PlayAnimation("Reload"))
	end
end

function SWEP:GetReloadAmount()
	local amount = self.Settings.ReloadAmount

	return amount == -1 and self.Settings.ClipSize or amount
end

function SWEP:ReloadThink()
	local reload = self:GetFinishReload()

	if reload != 0 and reload <= CurTime() then
		self:FinishReload()
	end
end

function SWEP:TryCancelReload()
	if self:IsReloading() and self.Settings.ShotgunReload then
		self:SetCancelReload(true)
		self:ForceStopFire()
	end
end

function SWEP:FinishReload()
	local settings = self.Settings

	if self:GetFirstReload() then
		self:SetFirstReload(false)
	else
		local amount = math.min(settings.ClipSize - self:Clip1(), self:GetReloadAmount())

		if settings.PumpAction and self:Clip1() == 0 then
			self:SetShouldPump(true)
		end

		self:SetClip1(self:Clip1() + amount)
	end

	if settings.ShotgunReload then
		if self:Clip1() >= settings.ClipSize or self:GetCancelReload() then
			self:SetCancelReload(false)
			self:SetFinishReload(0)
			self:SetNextPrimaryFire(CurTime() + self:PlayAnimation("ReloadFinish"))
		else
			self:PlaySound("Reload")
			self:SetFinishReload(CurTime() + self:PlayAnimation("Reload"))
		end
	else
		self:SetFinishReload(0)
	end
end

function SWEP:Reload()
	if self:CanReload() then
		self:StartReload()
	end
end
