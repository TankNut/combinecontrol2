EFFECT.Mat = Material("effects/draconic_halo/laser_thicc")

function EFFECT:Init(data)
	self.Pos = data:GetStart()
	self.Ent = data:GetEntity()
	self.Attachment = data:GetAttachment()

	self.Start = self:GetTracerShootPos(self.Pos, self.Ent, self.Attachment)
	self.End = data:GetOrigin()

	self.Normal = (self.Start - self.End):Angle():Forward()

	self:SetRenderBoundsWS(self.Start, self.End)

	self.StartTime = CurTime()
	self.Lifetime = 0.2
end

function EFFECT:Think()
	if CurTime() - self.StartTime > self.Lifetime then
		return false
	end

	return true
end

local color1 = Color(255, 0, 0)
local color2 = Color(255, 150, 150)

function EFFECT:Render()
	local alpha = math.Remap(CurTime() - self.StartTime, 0, self.Lifetime, 255, 0)
	local size = math.Remap(CurTime() - self.StartTime, 0, self.Lifetime, 40, 5)

	color1.a = alpha
	color2.a = alpha

	render.SetMaterial(self.Mat)
	render.DrawBeam(self.Start, self.End, size, 0, 1, color1)

	-- Overbrighten the hell out of it
	render.DrawBeam(self.Start, self.End, size * 0.4, 0, 1, color2)
	render.DrawBeam(self.Start, self.End, size * 0.4, 0, 1, color2)
	render.DrawBeam(self.Start, self.End, size * 0.4, 0, 1, color2)
end
