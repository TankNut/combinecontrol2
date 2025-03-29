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

	self:SetFinishReload(CurTime() + self:PlayAnimation("Reload"))
end

function SWEP:GetReloadAmount()
	return self.Primary.ClipSize
end

function SWEP:FinishReload()
	local amount = self:GetReloadAmount()

	self:SetClip1(math.min(self:Clip1() + amount, self.Primary.ClipSize))

	self:SetFinishReload(0)
end

function SWEP:Reload()
	if self:CanReload() then
		self:StartReload()
	end
end
