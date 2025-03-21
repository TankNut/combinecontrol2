AddCSLuaFile()

function SWEP:GetLoweredHoldType()
	return self.Settings.LowerHoldType
end

function SWEP:GetBaseHoldType()
	return self.Settings.BaseHoldType
end

function SWEP:GetAimHoldType()
	return self.Settings.AimHoldType
end

function SWEP:GetNPCHoldType()
	return self.Settings.NPCHoldType or self:GetBaseHoldType()
end
