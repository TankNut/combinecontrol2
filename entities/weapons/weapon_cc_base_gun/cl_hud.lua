local mat = Material("VGUI/gradient-r")

local function DrawLine(x, y, rot, size, alpha)
	surface.SetMaterial(mat)

	surface.SetDrawColor(0, 0, 0, alpha * 220)
	surface.DrawTexturedRectRotated(x, y, size + 2, 4, rot)

	surface.SetDrawColor(255, 255, 255, alpha * 220)
	surface.DrawTexturedRectRotated(x, y, size, 2, rot)
end

function SWEP:ShouldDrawCrosshair()
	if self:GetHolstered() or self:ShouldLower() then
		return false
	end

	if self:IsReloading() then
		return false
	end

	return true
end

local alpha = 0
local fadeTime = 0.1

function SWEP:DoDrawCrosshair(x, y)
	if self:GetDeployed() then
		alpha = 0
	end

	if Settings.Get("AimCrosshairOnly") then
		alpha = self:GetAimState()
	else
		if self:ShouldDrawCrosshair() then
			alpha = math.Approach(alpha, 1, FrameTime() / fadeTime)
		else
			alpha = math.Approach(alpha, 0, FrameTime() / fadeTime)
		end
	end

	if alpha == 0 then
		return true
	end

	local ply = self:GetOwner()

	local tr = util.TraceLine({
		start = ply:GetShootPos(),
		endpos = ply:GetShootPos() + self:GetShootDir() * 56756,
		mask = MASK_SHOT,
		filter = ply
	})

	local dist = tr.Fraction * 56756
	local range = self:GetRange()
	local accuracy = self:GetAccuracy()

	local offset = accuracy * (dist / range)

	local pos = tr.HitPos:ToScreen()

	if ply:ShouldDrawLocalPlayer() then
		x = math.Truncate(pos.x)
		y = math.Truncate(pos.y)
	end

	local normal = tr.Normal:Angle():Right()
	local gap = math.abs(pos.x - (tr.HitPos + normal * offset):ToScreen().x) - math.NormalizeAngle(self:GetRecoilVelocity().p)

	local ang = Angle(0, 0, 0)

	local size = 12
	local mul = gap + size * 0.5

	for i = 0, 359, 360 / 4 do
		ang:SetRoll(i)

		local up = ang:Up()
		up:Mul(mul)

		DrawLine(math.Round(x + up.y), math.Round(y + up.z), 270 - ang.r, size, alpha)
	end

	return true
end

local firemodes = {
	[FIREMODE_AUTO] = "Automatic",
	[FIREMODE_SEMI] = "Semi-Automatic",
	[FIREMODE_SAFE] = "Safe"
}

function SWEP:GetFiremodeName()
	local index = self:GetFiremode()
	local override = self.Settings.FiremodeOverride

	if override and #override > 0 and index != FIREMODE_SAFE then
		return override
	end

	return firemodes[index] and firemodes[index] or index .. "-Round Burst"
end

function SWEP:GetHUDLines()
	local ammo = string.format("<f=CombineControl.Ammo><ol><c=cc_normal>%s/%s", self:Clip1(), self.Primary.ClipSize)
	local firemode = "<f=CombineControl.AmmoSmall><ol><c=cc_normal>" .. self:GetFiremodeName()

	return {ammo, firemode}
end
