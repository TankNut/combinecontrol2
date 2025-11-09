AddCSLuaFile()

function SWEP:TranslateFOV(fov)
	local ply = self:GetOwner()

	if ply:GetViewEntity() != ply then
		return fov
	end

	local target = fov / self:GetZoom()

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

	function SWEP:GetViewModelTarget()
		local offsets = self.Offsets

		local targetPos = Vector(offsets.Default[1])
		local targetAng = Angle(offsets.Default[2])

		if self:GetHolstered() then
			targetPos:Set(offsets.Holster[1])
			targetAng:Set(offsets.Holster[2])
		elseif self:IsSprinting() then
			targetPos:Set(offsets.Sprint[1])
			targetAng:Set(offsets.Sprint[2])
		end

		return targetPos, targetAng
	end

	local HL2_BOB_VERTICAL = 0.5
	local HL2_BOB_LATERAL = HL2_BOB_VERTICAL * 2
	local HL2_BOB = 0.5

	local bobTime = 0
	local lastBobTime = 0

	function SWEP:GetBobScale()
		return 1
	end

	function SWEP:GetSwayScale()
		return 2
	end

	function SWEP:AddViewmodelBob(pos, ang)
		local ply = self:GetOwner()
		local maxSpeed = ply:IsOnGround() and 160 or 500
		local scale = self:GetBobScale()

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
		pos:AddZ(vertical * 0.1 * scale)

		ang:SubPitch(vertical * 0.4)
		ang:SubYaw(lateral * 0.3)
		ang:AddRoll(vertical * 0.5)
	end

	local timescale = GetConVar("host_timescale")
	local lastDelta = SysTime()

	function SWEP:GetStaticViewModelOffset()
		return Vector(), Angle()
	end

	function SWEP:GetViewModelPosition(pos, ang)
		self.SwayScale = self:GetSwayScale()

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

		-- approachMod(self.VMPos, targetPos, speed * 0.1)
		-- approachMod(self.VMAng, targetAng, speed * 0.1)

		local addPos, addAng = self:GetStaticViewModelOffset()

		self:AddViewmodelBob(addPos, addAng)

		return LocalToWorld(self.VMPos + addPos, self.VMAng + addAng, pos, ang)
	end

	local desired = GetConVar("fov_desired")

	function SWEP:AdjustMouseSensitivity()
		local fov = self:GetOwner():GetFOV()

		return fov / desired:GetFloat()
	end

	function SWEP:PreDrawViewModel(vm, _, ply)
		if self.Settings.UseHolsterAnimations and self:GetHolstered() and (vm:GetCycle() > 0.9 or self:GetDeployed()) then
			return true
		end

		for index, mat in pairs(self.ViewModelMaterials) do
			if not isnumber(index) then
				continue
			end

			render.MaterialOverrideByIndex(index, mat)
		end
	end

	function SWEP:PostDrawViewModel(vm, _, ply)
		render.MaterialOverrideByIndex(nil)
	end

	function SWEP:DrawWorldModel(flags)
		for index, mat in pairs(self.WorldModelMaterials) do
			if not isnumber(index) then
				continue
			end

			render.MaterialOverrideByIndex(index, mat)
		end

		self:DrawModel(flags)

		render.MaterialOverrideByIndex(nil)
	end

	function SWEP:DrawWorldModelTranslucent(flags)
		for index, mat in pairs(self.WorldModelMaterials) do
			render.MaterialOverrideByIndex(index, mat)
		end

		self:DrawModel(flags)

		render.MaterialOverrideByIndex(nil)
	end
end
