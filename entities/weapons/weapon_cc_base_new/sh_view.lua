AddCSLuaFile()

function SWEP:TranslateFOV(fov)
	local target = fov / self:GetZoom()

	self.DefaultFOV = fov
	self.ViewModelFOV = self.OrigViewModelFOV + (fov - target) * 0.75

	return target
end

if CLIENT then
	local function lerpMod(from, to, delta)
		from[1] = Lerp(delta, from[1], to[1])
		from[2] = Lerp(delta, from[2], to[2])
		from[3] = Lerp(delta, from[3], to[3])

		if isangle(from) then
			for i = 1, 3 do
				from[i] = math.NormalizeAngle(from[i])
			end
		end
	end

	local function approachMod(from, to, speed)
		from[1] = math.Approach(from[1], to[1], speed)
		from[2] = math.Approach(from[2], to[2], speed)
		from[3] = math.Approach(from[3], to[3], speed)
	end

	function SWEP:AddComputedOffsets(pos, ang)
		local ply = self:GetOwner()
		local eye = ply:EyeAngles()
		local vel = ply:GetVelocity()
		local len = vel:Length()

		-- do -- Offset the weapon depending on the view pitch
		-- 	local mult = math.ease.InOutQuad(self:GetHolsterState())
		-- 	local pitch = eye.p
		-- 	local sign = math.Sign(pitch)

		-- 	local vOffset = math.Remap(math.abs(pitch), 0, 89, 0, 1)

		-- 	vOffset = math.ease.InSine(vOffset) * 30 * mult

		-- 	pos.z = pos.z - math.abs(vOffset * 0.3)

		-- 	ang.p = ang.p - math.Clamp(vOffset * sign, 0, 20)
		-- 	ang.y = ang.y + vOffset
		-- 	ang.r = ang.r - vOffset * 0.2
		-- end

		local sidewaysVelocity = vel:GetNormalized():Dot(eye:Right()) * len / ply:GetRunSpeed()

		ang.r = ang.r + math.RemapC(sidewaysVelocity, -1, 1, -10, 10)
	end

	function SWEP:GetViewModelTarget()
		local offsets = self.Offsets

		local targetPos = Vector(offsets.Default[1])
		local targetAng = Angle(offsets.Default[2])

		local holster = self:GetHolsterState()
		local sprint = math.max(self:GetSprintState() - holster, 0)
		local aim = self:ShouldAim() and 1 or 0 --self:GetAimState()

		targetPos:Add(offsets.Holster[1] * holster)
		targetAng:Add(offsets.Holster[2] * holster)

		targetPos:Add(offsets.Sprint[1] * sprint)
		targetAng:Add(offsets.Sprint[2] * sprint)

		targetPos:Add(offsets.Aiming[1] * aim)
		targetAng:Add(offsets.Aiming[2] * aim)

		self:AddComputedOffsets(targetPos, targetAng)

		return targetPos, targetAng
	end

	local timescale = GetConVar("host_timescale")
	local lastDelta = SysTime()

	function SWEP:GetViewModelPosition(pos, ang)
		self.BobScale = Lerp(self:GetAimState(), 1.5, 0.5)
		self.SwayScale = Lerp(self:GetAimState(), 2, 0.3)

		local targetPos, targetAng = self:GetViewModelTarget()

		if not self.VMPos then
			self.VMPos = targetPos
			self.VMAng = targetAng
		end

		local delta = (SysTime() - lastDelta) * timescale:GetFloat()
		local comp = (1 / delta) / 66.66

		if comp < 1 then
			delta = delta * comp
		end

		local speed = delta * (0.4 / self.Settings.AimTime)

		lerpMod(self.VMPos, targetPos, speed)
		lerpMod(self.VMAng, targetAng, speed)

		approachMod(self.VMPos, targetPos, speed * 0.1)
		approachMod(self.VMAng, targetAng, speed * 0.1)

		local recoilPos, recoilAng = self:GetVMRecoil()
		local mult = 1 - math.ease.InOutQuad(self:GetHolsterState())

		ang.p = ang.p * mult

		return LocalToWorld(self.VMPos + recoilPos, self.VMAng + recoilAng, pos, ang)
	end

	function SWEP:AdjustMouseSensitivity()
		local desired = self.DefaultFOV
		local fov = self:GetOwner():GetFOV()

		return fov / desired
	end

	function SWEP:PreDrawViewModel(vm, _, ply)
		if self.UseHolsterAnimations and self:GetHolsterState() > 0.9 then
			return true
		end
	end
end
