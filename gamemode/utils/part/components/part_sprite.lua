local BaseClass = inherit.Get("part", "base")
local PART = {}

function PART:Initialize(outfit, name, data)
	BaseClass.Initialize(self, outfit, name, data)

	self.Width = data.Width or 10
	self.Height = data.Height or 10

	self.Material = Material(data.Material or "vgui/avatar_default")

	self.Color = data.Color or Color(255, 255, 255)

	self.SpriteRadius = data.SpriteRadius or 2
	self.Filter = data.Filter

	self.PixVis = util.GetPixelVisibleHandle()
end

function PART:Draw(renderMode)
	if renderMode and (self:ShouldHide() or renderMode == "opaque") then
		return
	end

	local pos = self:GetRenderPos()

	render.SetMaterial(self.Material)

	if self.Filter then
		render.PushFilterMin(self.Filter)
		render.PushFilterMag(self.Filter)
	end

	local alpha = util.PixelVisible(pos, self.SpriteRadius, self.PixVis)

	if alpha > 0 then
		local color = Color(
			self.Color.r * alpha,
			self.Color.g * alpha,
			self.Color.b * alpha
		)

		render.DepthRange(0, 0)
		render.SetBlend(alpha)

		render.DrawSprite(pos, self.Width, self.Height, color)

		render.SetBlend(1)
		render.DepthRange(0, 1)
	end

	if self.Filter then
		render.PopFilterMag()
		render.PopFilterMin()
	end
end

inherit.Register("part", "sprite", PART, "base")
