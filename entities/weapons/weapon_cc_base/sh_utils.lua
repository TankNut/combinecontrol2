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

	if ply:IsInNoClip() then
		return false
	end

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

local mins = Vector(-10, -10, -8)
local maxs = Vector(10, 10, 8)

function SWEP:GetMeleeTrace(reach)
	local ply = self:GetOwner()

	ply:LagCompensation(true)

	local trace = {
		start = ply:GetShootPos(),
		endpos = ply:GetShootPos() + self:GetShootDir() * reach,
		filter = ply,
		mask = MASK_SHOT_HULL,
		mins = mins,
		maxs = maxs
	}

	local tr = util.TraceLine(trace)
	local line = tr

	if not IsValid(tr.Entity) then
		tr = util.TraceHull(trace)
	end

	ply:LagCompensation(false)

	return tr, line
end
