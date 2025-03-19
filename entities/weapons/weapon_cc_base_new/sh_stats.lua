AddCSLuaFile()

function SWEP:GetBulletCount()
	return self.Stats.Count
end

function SWEP:GetDamage()
	return self.Stats.Damage
end

function SWEP:GetDamageFalloff(dist)
	local distMod = 1000

	return math.max(self.Stats.DamageFalloff ^ (dist / distMod), 0.2)
end

function SWEP:GetDelay()
	local rate = self.Settings.FireRate

	if rate == -1 then
		return rate
	end

	return 60 / rate
end

function SWEP:GetRange()
	return self.Settings.Range
end

function SWEP:GetAccuracy()
	local val = self.Stats.Accuracy

	if istable(val) then
		return Lerp(self:GetAimState(), val[1], val[2])
	end

	return val
end

function SWEP:GetSpread()
	if self.Stats.FixedRange then
		return self:GetAccuracy()
	end

	local range = self:GetRange()
	local accuracy = self:GetAccuracy()

	local inches = accuracy / 0.75
	local yards = (range / 0.75) / 36
	local MOA = (inches * 100) / yards

	local spread = math.rad(MOA / 60)

	return Vector(spread, spread, 0)
end

function SWEP:GetTracerEffect()
	return self.Stats.Tracer, self.Stats.TracerCount
end

function SWEP:GetImpactEffect()
	return self.Stats.Impact
end

function SWEP:GetAimTime()
	return self.Settings.AimTime
end

function SWEP:GetSprintTime()
	return self.Settings.SprintTime
end

function SWEP:GetHolsterTime()
	return self.Settings.HolsterTime
end

function SWEP:GetSelectedZoom()
	return self.Settings.Zoom[1]
end

function SWEP:GetZoom()
	return Lerp(math.ease.InOutSine(self:GetAimState()), 1, self:GetSelectedZoom())
end
