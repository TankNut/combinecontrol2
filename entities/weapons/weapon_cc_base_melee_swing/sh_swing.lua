AddCSLuaFile()

function SWEP:GetDamage()
	local damage = self.Stats.Damage

	return Lerp(self:GetSwingPower(), damage[1], damage[2]), self.Stats.DamageType
end

function SWEP:GetSwingPower()
	local swing = self:GetSwingStart()

	if swing == 0 then
		return 0
	end

	return math.Clamp(math.TimeFraction(swing + self.Stats.Hold[1], swing + self.Stats.Hold[2], CurTime()), 0, 1)
end

function SWEP:GetSwingTime()
	local swing = self:GetSwingStart()

	if swing == 0 then
		return 0
	end

	return math.Clamp(math.TimeFraction(swing, swing + self.Stats.Hold[2], CurTime()), 0, 1)
end

if CLIENT then
	function SWEP:GetStaticViewModelOffset()
		local offsets = self.Offsets
		local swing = self:GetSwingStart()
		local power = swing > 0 and self:GetSwingTime() or 0

		if power > 0 then
			power = math.EaseInOut(power, 0.5, 1)

			return offsets.Swing[1] * power, offsets.Swing[2] * power
		end

		return Vector(), Angle()
	end
end
