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

function SWEP:GetViewModel()
	return self:GetOwner():GetViewModel()
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

function SWEP:PrimeRandomSeed()
	math.randomseed(self:EntIndex() .. self:GetCommandNumber())
end

function SWEP:PlaySound(name, level, pitch, volume)
	local snd = self.Sounds[name]

	if not snd then
		return
	end

	if istable(snd) then
		snd = table.Random(snd)
	end

	self:EmitSound(snd, level or 75, pitch or 100, volume or 1)
end
