AddCSLuaFile()

function SWEP:GetCommandNumber()
	return self:GetOwner():GetCurrentCommand():CommandNumber()
end

function SWEP:ForceStopFire()
	self:GetOwner():ConCommand("-attack")
end

function SWEP:GetFiremode()
	return self.Settings.Firemodes[self:GetFiremodeIndex()]
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

function SWEP:GetShootDir()
	local ply = self:GetOwner()

	if ply:IsNPC() then
		return ply:GetAimVector()
	else
		return (ply:GetAimVector():Angle() + ply:GetViewPunchAngles()):Forward()
	end
end

function SWEP:GetHolsterState()
	local state = math.Clamp(math.TimeFraction(self:GetHolsterStart(), self:GetHolsterEnd(), CurTime()), 0, 1)

	return self:GetHolstered() and state or 1 - state
end

function SWEP:IsSprinting()
	local ply = self:GetOwner()

	return ply:IsSprinting() and ply:GetVelocity():Length() >= Lerp(0.5, ply:GetWalkSpeed(), ply:GetRunSpeed())
end

function SWEP:ShouldLower()
	return self:IsSprinting()
end

function SWEP:ShouldAim()
	if self:ShouldLower() or self:GetHolstered() then
		return false
	end

	return self:GetOwner():KeyDown(IN_ATTACK2)
end
