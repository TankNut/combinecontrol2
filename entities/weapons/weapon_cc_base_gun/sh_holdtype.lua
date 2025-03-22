AddCSLuaFile()

function SWEP:GetAimHoldType()
	return self.Settings.AimHoldType or self:GetBaseHoldType()
end

function SWEP:GetNPCHoldType()
	return self.Settings.NPCHoldType or self:GetBaseHoldType()
end

function SWEP:UpdateHoldType()
	local old = self:GetHoldType()
	local holdType = self:GetBaseHoldType()

	if self:ShouldLower() or self:GetHolstered() then
		holdType = self:GetLoweredHoldType()
	elseif self:ShouldAim() then
		holdType = self:GetAimHoldType()
	end

	if holdType != old then
		self:SetHoldType(holdType)
	end
end
