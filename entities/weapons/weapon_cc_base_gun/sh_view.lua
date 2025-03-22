DEFINE_BASECLASS("weapon_cc_base")
AddCSLuaFile()

if CLIENT then
	function SWEP:GetViewModelTarget()
		local targetPos, targetAng = BaseClass.GetViewModelTarget(self)
		local offsets = self.Offsets

		if self:ShouldAim() then
			targetPos:Add(offsets.Aiming[1])
			targetAng:Add(offsets.Aiming[2])
		end

		self:AddComputedOffsets(targetPos, targetAng)

		return targetPos, targetAng
	end

	function SWEP:AddComputedOffsets(pos, ang)
		local ply = self:GetOwner()
		local eye = ply:EyeAngles()
		local roll = 10

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

		ang.r = ang.r + math.ClampedRemap(sidewaysVelocity, -ply:GetRunSpeed(), ply:GetRunSpeed(), -roll, roll)

		local crouch = ply:GetCrouchState()

		pos.x = pos.x - crouch
		pos.z = pos.z - crouch
		ang.p = ang.p - crouch
		ang.r = ang.r - crouch * 5
	end

	function SWEP:GetStaticViewModelOffset()
		return self:GetVMRecoil()
	end
end
