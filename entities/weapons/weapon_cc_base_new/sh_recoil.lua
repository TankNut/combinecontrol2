AddCSLuaFile()

local RECOIL_DAMPING = 9
local RECOIL_SPRING_CONSTANT = 65

function SWEP:DoRecoilDecay()
	local ang = self:GetRecoilPunch()
	local vel = self:GetRecoilVelocity()

	ang.p = math.NormalizeAngle(ang.p)
	ang.y = math.NormalizeAngle(ang.y)
	ang.r = math.NormalizeAngle(ang.r)

	vel.p = math.NormalizeAngle(vel.p)
	vel.y = math.NormalizeAngle(vel.y)
	vel.r = math.NormalizeAngle(vel.r)

	local frametime = FrameTime()

	if ang:LengthSqr() > 0.001 or vel:LengthSqr() > 0.001 then
		ang:Add(vel * frametime)

		local damping = ang.p > 0 and RECOIL_DAMPING * 2 or RECOIL_DAMPING

		vel:Mul(math.max(1 - (damping * frametime), 0))
		vel:Sub(ang * math.Clamp(RECOIL_SPRING_CONSTANT * frametime, 0, 2))

		ang:ViewClamp()

		self:SetRecoilPunch(ang)
		self:SetRecoilVelocity(vel)
	else
		self:SetRecoilPunch(angle_zero)
		self:SetRecoilVelocity(angle_zero)
	end
end

function SWEP:GetRecoilMultiplier()
	return math.tan(self:GetOwner():GetFOV() * (math.pi / 360)) * self:GetZoom()
end

local TAPFIRE_THRESHOLD = 0.75

function SWEP:ApplyRecoil()
	local recoil = self.Recoil
	local value = recoil.Value * self:GetRecoilMultiplier()
	local viewPunchMult = 1

	if math.abs(self:GetRecoilPunch().p) < value * TAPFIRE_THRESHOLD then
		viewPunchMult = 0.5
	end

	math.randomseed(self:EntIndex() .. self:GetCommandNumber())

	local ang = Angle(-value, math.Rand(-1, 1) * (value / 3))
	local ply = self:GetOwner()

	if CLIENT and IsFirstTimePredicted() then
		ply:SetEyeAngles(ply:EyeAngles() + ang * recoil.Punch * viewPunchMult)
	end

	ply:ViewPunch(ang * viewPunchMult)
	self:SetRecoilVelocity(self:GetRecoilVelocity() + ang * 20)
end

if CLIENT then
	function SWEP:GetVMRecoil()
		local amt = self:GetRecoilPunch()

		amt.p = math.NormalizeAngle(amt.p)
		amt.y = math.NormalizeAngle(amt.y)
		amt.r = math.NormalizeAngle(amt.r)

		local posMult = self.Recoil.PosMult
		local angMult = self.Recoil.AngMult

		local pos = Vector(amt.p * posMult.x, amt.y * posMult.y, amt.p * posMult.z)
		local ang = Angle(amt.p * angMult.p, amt.y * angMult.y, 0)

		return pos, ang
	end
end
