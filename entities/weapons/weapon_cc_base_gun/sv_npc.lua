function SWEP:GetCapabilities()
	return bit.bor(CAP_WEAPON_RANGE_ATTACK1, CAP_INNATE_RANGE_ATTACK1)
end

function SWEP:GetNPCBulletSpread(prof)
	return 5 - prof
end

function SWEP:GetNPCBurstSettings()
	local settings = self.Settings

	return settings.NPCBurst[1], settings.NPCBurst[2], self:GetDelay()
end

function SWEP:GetNPCRestTimes()
	local settings = self.Settings

	if settings.NPCRest then
		return settings.NPCRest[1], settings.NPCRest[2]
	else
		local delay = self:GetDelay()

		return delay * 2, delay * 3
	end
end
