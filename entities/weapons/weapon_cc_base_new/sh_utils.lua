AddCSLuaFile()

function SWEP:GetCommandNumber()
	return self:GetOwner():GetCurrentCommand():CommandNumber()
end

function SWEP:ForceStopFire()
	local owner = self:GetOwner()

	if owner:IsPlayer() then
		owner:ConCommand("-attack")
	end
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
	local owner = self:GetOwner()

	if owner:IsNPC() then
		return owner:GetAimVector()
	else
		return (owner:GetAimVector():Angle() + owner:GetViewPunchAngles()):Forward()
	end
end

function SWEP:IsSprinting()
	local ply = self:GetOwner()

	return ply:IsSprinting() and ply:GetVelocity():Length2D() >= Lerp(0.3, ply:GetWalkSpeed(), ply:GetRunSpeed())
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
