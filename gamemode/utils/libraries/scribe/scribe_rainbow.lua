local COMPONENT = {
	Name = {"rgb", "rainbow"}
}

function COMPONENT:Initialize(args)
	args = string.Explode("[,%s]", args, true)

	self.Complex = tobool(tonumber(args[1]))

	if self.Complex then
		self.Frequency = tonumber(args[2])
		self.Speed = tonumber(args[3]) or 0
	else
		self.Speed = tonumber(args[2]) or 0
	end
end

function COMPONENT:Push()
	self.SavedColor = self.Context.Color
	self.Counter = 0

	if self.Complex then
		self.Context:PushComplex()
	end

	self:AddRenderHook()
end

function COMPONENT:Pop()
	self:RemoveRenderHook()

	if self.Complex then
		self.Context:PopComplex()
	end

	self.Context:SetColor(self.SavedColor)
end

function COMPONENT:PreDrawText(part, data)
	-- Something else has overwritten us
	if self.Context.Color != self.SavedColor then
		return
	end

	self.Color = self.Context.Color

	if self.Complex then
		local frequency = self.Frequency or (360 / #part.Text)

		self.Context:SetColor(HSVToColor(self.Counter * frequency + (CurTime() * self.Speed) % 360, 1, 1))
	else
		self.Context:SetColor(HSVToColor(CurTime() * self.Speed % 360, 1, 1))
	end
end

function COMPONENT:PostDrawText(part, data)
	self.Counter = self.Counter + 1

	if self.Color then
		self.Context:SetColor(self.Color)
		self.Color = nil
	end
end

scribe.Register(COMPONENT)
