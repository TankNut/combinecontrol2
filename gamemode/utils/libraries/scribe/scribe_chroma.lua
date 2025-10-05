local COMPONENT = {
	Name = {"chroma"}
}

function COMPONENT:Initialize(args)
	args = string.Explode("[,%s]", args, true)

	self.Mult = tonumber(args[1]) or 1
	self.Chance = tonumber(args[2]) or 100
end

function COMPONENT:Push()
	self.Context:PushComplex()
	self:AddRenderHook()
end

function COMPONENT:Pop()
	self:RemoveRenderHook()
	self.Context:PopComplex()
end

local matrix = Matrix()

function COMPONENT:PreDrawText(part, data)
	if self.Context.DryRun or self.Context.Console then
		return
	end

	local alpha = self.Context.Color.a
	local x, y = data.x, data.y

	render.OverrideBlend(true, BLEND_SRC_ALPHA, BLEND_ONE, BLENDFUNC_ADD)

	for channel, val in pairs(self.Context.Color) do
		if channel == "a" then
			continue
		end

		if math.Maybe(self.Chance) then
			matrix:SetField(1, 4, math.Rand(-self.Mult, self.Mult))
			matrix:SetField(2, 4, math.Rand(-self.Mult, self.Mult))
		else
			matrix:SetField(1, 4, 0)
			matrix:SetField(2, 4, 0)
		end

		cam.PushModelMatrix(matrix, true)

		local r = channel == "r" and val or 0
		local g = channel == "g" and val or 0
		local b = channel == "b" and val or 0

		surface.SetTextColor(r, g, b, alpha)
		surface.SetTextPos(x, y)
		surface.DrawText(data.Text)

		cam.PopModelMatrix()
	end

	render.OverrideBlend(false)

	return true
end

scribe.Register(COMPONENT)
