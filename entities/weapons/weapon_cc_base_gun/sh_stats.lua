AddCSLuaFile()

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
		return Lerp(math.ease.InOutSine(self:GetAimState()), val[1], val[2])
	end

	return val
end

function SWEP:GetSpread()
	local range = self.Stats.FixedRange and 1000 or self:GetRange()
	local accuracy = self:GetAccuracy()

	local inches = accuracy / 0.75
	local yards = (range / 0.75) / 36
	local MOA = (inches * 100) / yards

	return MOA / 60
end

function SWEP:GetZoom()
	return Lerp(math.ease.InOutSine(self:GetAimState()), 1, self.Settings.Zoom[1])
end
