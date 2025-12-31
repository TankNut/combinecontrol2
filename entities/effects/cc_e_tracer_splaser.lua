EFFECT.Flash = Material("effects/draconic_halo/flash_composite")
EFFECT.Mat = Material("effects/draconic_halo/laser_thick")

function EFFECT:Init(data)
	self.Pos = data:GetStart()
	self.Ent = data:GetEntity()
	self.Attachment = data:GetAttachment()

	self.Start = self:GetTracerShootPos(self.Pos, self.Ent, self.Attachment)
	self.End = data:GetOrigin()

	self.Normal = (self.Start - self.End):Angle():Forward()

	self:SetRenderBoundsWS(self.Start, self.End)

	self.StartTime = UnPredictedCurTime()
	self.Lifetime = 0.3
end

function EFFECT:Think()
	if UnPredictedCurTime() - self.StartTime > self.Lifetime then
		return false
	end

	return true
end

local color1 = Color(255, 0, 0)
local color2 = Color(255, 255, 255)

function EFFECT:Render()
	local frac = math.Clamp((UnPredictedCurTime() - self.StartTime) / self.Lifetime, 0, 1)

	local alpha1 = math.ClampedRemap(frac, 0, 1, 255, 0)
	local alpha2 = math.ClampedRemap(frac, 0, 0.7, 255, 0)

	color1.a = alpha1
	color2.a = alpha2

	local sprite1 = math.ClampedRemap(frac, 0.1, 1, 100, 60) * 0.7
	local sprite2 = math.ClampedRemap(frac, 0.1, 1, 40, 5)

	render.SetMaterial(self.Flash)
	render.DrawSprite(self.Start, sprite1, sprite1, color1)
	render.DrawSprite(self.Start, sprite2, sprite2, color2)

	local size1 = math.ClampedRemap(frac, 0, 1, 100, 20)
	local size2 = math.ClampedRemap(frac, 0, 1, 40, 5)

	render.SetMaterial(self.Mat)
	render.DrawBeam(self.Start, self.End, size1, 0, 1, color1)
	render.DrawBeam(self.Start, self.End, size1, 0, 1, color1)
	render.DrawBeam(self.Start, self.End, size1, 0, 1, color1)

	render.DrawBeam(self.Start, self.End, size2, 0, 1, color2)
end
