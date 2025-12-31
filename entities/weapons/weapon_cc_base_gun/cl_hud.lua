local mat = Material("VGUI/gradient-r")

local function DrawLine(x, y, rot, size, alpha)
	surface.SetMaterial(mat)

	surface.SetDrawColor(0, 0, 0, alpha * 220)
	surface.DrawTexturedRectRotated(x, y, size + 2, 4, rot)

	surface.SetDrawColor(255, 255, 255, alpha * 220)
	surface.DrawTexturedRectRotated(x, y, size, 2, rot)
end

function SWEP:DrawScopeBackground(x, y, w, h)
	render.SetStencilEnable(true)
	render.ClearStencil()

	render.SetStencilTestMask(255)
	render.SetStencilWriteMask(255)

	render.SetStencilPassOperation(STENCILOPERATION_KEEP)
	render.SetStencilFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)

	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	render.SetStencilReferenceValue(0)

	render.ClearStencilBufferRectangle(x, y, x + w, y + h, 1)

	surface.DrawRect(0, 0, ScrW(), ScrH())

	render.SetStencilEnable(false)
end

function SWEP:DrawScope(x, y, w, h)
	local scope = self.Scope

	surface.SetDrawColor(0, 0, 0, 255)
	surface.SetMaterial(scope.Material)

	w = w * 0.5
	h = h * 0.5

	local x2 = x + w
	local y2 = y + h

	local c = math.ceil
	local f = math.floor

	surface.DrawTexturedRectUV(x, y, c(w), h, 1, 1, 0, 0)
	surface.DrawTexturedRectUV(x2, y, f(w), h, 0, 1, 1, 0)
	surface.DrawTexturedRectUV(x, y2, c(w), h, 1, 0, 0, 1)
	surface.DrawTexturedRectUV(x2, y2, f(w), h, 0, 0, 1, 1)
end

function SWEP:DrawScopeOverlay(x, y, w, h)
	surface.SetDrawColor(0, 0, 0, 255)

	surface.DrawLine(x + w * 0.5, y, x + w * 0.5, y + h)
	surface.DrawLine(x, y + h * 0.5, x + w, y + h * 0.5)
end

function SWEP:DrawHUD()
	if not self:InScope() then
		return
	end

	local scrW = ScrW()
	local scrH = ScrH()

	local ratio = scrW / scrH

	local scope = self.Scope

	local scale = scope.Scale
	local w = scrW * scale / ratio * scope.Width
	local h = scrH * scale * scope.Height

	local x = (scrW * 0.5) - w * 0.5
	local y = (scrH * 0.5) - h * 0.5

	surface.SetDrawColor(0, 0, 0, 197)

	self:DrawScopeBackground(x, y, w, h)
	self:DrawScope(x, y, w, h)
	self:DrawScopeOverlay(x, y, w, h)
end


function SWEP:ShouldDrawCrosshair()
	if self:GetHolstered() or self:ShouldLower() then
		return false
	end

	if self:IsReloading() then
		return false
	end

	if self:InScope() then
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

	if alpha == 0 or self:InScope() then
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

	local punch = self:GetRecoilPunch().p
	local accel = math.max(self.RecoilAcceleration.p, 0)
	local add = math.NormalizeAngle(math.abs(punch - accel)) * 2

	local normal = tr.Normal:Angle():Right()
	local gap = math.abs(pos.x - (tr.HitPos + normal * offset):ToScreen().x) + add

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

	if #override > 0 and index != FIREMODE_SAFE then
		return override
	end

	return firemodes[index] and firemodes[index] or index .. "-Round Burst"
end

function SWEP:GetHUDLines()
	local lines = {}

	if self.Primary.ClipSize > 0 then
		table.insert(lines, string.format("<f=CombineControl.Ammo><ol><c=cc_normal>%s/%s", self:Clip1(), self.Primary.ClipSize))
	end

	if #self.Settings.Firemodes > 1 then
		table.insert(lines, "<f=CombineControl.AmmoSmall><ol><c=cc_normal>" .. self:GetFiremodeName())
	end

	return lines
end
