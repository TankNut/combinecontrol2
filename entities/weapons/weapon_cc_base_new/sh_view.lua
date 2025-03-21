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
		local diff = to - from
		local ratio = math.max(math.abs(diff[1]), math.abs(diff[2]), math.abs(diff[3]))

		from[1] = math.Approach(from[1], to[1], speed * (diff[1] / ratio))
		from[2] = math.Approach(from[2], to[2], speed * (diff[2] / ratio))
		from[3] = math.Approach(from[3], to[3], speed * (diff[3] / ratio))
	end

	function SWEP:AddComputedOffsets(pos, ang)
		local ply = self:GetOwner()
		local eye = ply:EyeAngles()
		local roll = 15

		 -- Offset the weapon depending on the view pitch
		if self:GetHolstered() or self:IsSprinting() then
			roll = 20

			local pitch = eye.p
			local vOffset = math.ease.InOutSine(math.Remap(pitch, 0, 90, 0, 1))
			local factor = ply:GetFOV() / self.ViewModelFOV

			pos.z = pos.z - math.abs(vOffset * 3)

			ang.p = math.min(ang.p + vOffset * 30 - (pitch / factor), ang.p)
			ang.y = ang.y * (1 - vOffset)
		end

		local vel = ply:GetVelocity()
		local sidewaysVelocity = vel:GetNormalized():Dot(eye:Right()) * vel:Length()

		ang.r = ang.r + math.RemapC(sidewaysVelocity, -ply:GetRunSpeed(), ply:GetRunSpeed(), -roll, roll)

		local crouch = ply:GetCrouchState()

		pos.x = pos.x - crouch
		pos.z = pos.z - crouch
		ang.p = ang.p - crouch
		ang.r = ang.r - crouch * 5
	end

	function SWEP:GetViewModelTarget()
		local offsets = self.Offsets

		local targetPos = Vector(offsets.Default[1])
		local targetAng = Angle(offsets.Default[2])

		if self:GetHolstered() then
			targetPos:Add(offsets.Holster[1])
			targetAng:Add(offsets.Holster[2])
		elseif self:IsSprinting() then
			targetPos:Add(offsets.Sprint[1])
			targetAng:Add(offsets.Sprint[2])
		elseif self:ShouldAim() then
			targetPos:Add(offsets.Aiming[1])
			targetAng:Add(offsets.Aiming[2])
		end

		self:AddComputedOffsets(targetPos, targetAng)

		return targetPos, targetAng
	end

	local HL2_BOB_VERTICAL = 0.5
	local HL2_BOB_LATERAL = HL2_BOB_VERTICAL * 2
	local HL2_BOB = 0.5

	local bobTime = 0
	local lastBobTime = 0

	function SWEP:AddViewmodelBob(pos, ang)
		local ply = self:GetOwner()
		local maxSpeed = ply:IsOnGround() and 160 or 500
		local scale = Lerp(self:GetAimState(), 1.5, 1)

		local speed = math.min(ply:GetVelocity():Length2D(), ply:GetRunSpeed())
		local offset = math.Remap(speed, 0, maxSpeed, 0, 1)
		local curTime = CurTime()

		bobTime = bobTime + (curTime - lastBobTime) * offset
		lastBobTime = curTime

		local cycle = bobTime - math.floor((bobTime / HL2_BOB_VERTICAL) * HL2_BOB_VERTICAL)
		cycle = cycle / HL2_BOB_VERTICAL

		if cycle < HL2_BOB then
			cycle = math.pi * (cycle / HL2_BOB)
		else
			cycle = math.pi + math.pi * (cycle - HL2_BOB) / (1 - HL2_BOB)
		end

		local vertical = speed * 0.005 * scale
		vertical = math.Clamp(vertical * 0.3 + vertical * 0.7 * math.sin(cycle), -7, 4)

		cycle = bobTime - math.floor((bobTime / HL2_BOB_LATERAL) * HL2_BOB_LATERAL)
		cycle = cycle / HL2_BOB_LATERAL

		if cycle < HL2_BOB then
			cycle = math.pi * cycle / HL2_BOB
		else
			cycle = math.pi + math.pi * (cycle - HL2_BOB) / (1 - HL2_BOB)
		end

		local lateral = speed * 0.005 * scale
		lateral = math.Clamp(lateral * 0.3 + lateral * 0.7 * math.sin(cycle), -7, 4)

		pos:Add(ang:Forward() * vertical * 0.1)
		pos:Add(ang:Right() * lateral * 0.8)
		pos.z = pos.z + vertical * 0.1 * scale

		ang.p = ang.p - vertical * 0.4
		ang.y = ang.y - lateral * 0.3
		ang.r = ang.r + vertical * 0.5
	end

	local timescale = GetConVar("host_timescale")
	local lastDelta = SysTime()

	function SWEP:GetViewModelPosition(pos, ang)
		self.SwayScale = Lerp(self:GetAimState(), 2, 1)

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

		local addPos, addAng = self:GetVMRecoil()

		self:AddViewmodelBob(addPos, addAng)

		return LocalToWorld(self.VMPos + addPos, self.VMAng + addAng, pos, ang)
	end

	function SWEP:AdjustMouseSensitivity()
		local desired = self.DefaultFOV
		local fov = self:GetOwner():GetFOV()

		return fov / desired
	end

	function SWEP:PreDrawViewModel(vm, _, ply)
		if self.UseHolsterAnimations and self:GetHolstered() and self:GetCycle() > 0.9 then
			return true
		end
	end
end
