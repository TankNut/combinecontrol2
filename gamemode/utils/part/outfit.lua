local CLASS = {}

function CLASS:Initialize(ent, name, data)
	self.Entity = ent
	self.Name = name
	self.Data = data

	self.Components = {}

	self:Parse(data)
end

function CLASS:Parse(data)
	for name, args in pairs(data) do
		local instance = inherit.Instance("part", args.Type or "model")
		instance:Initialize(self, name, args)

		self.Components[name] = instance
	end
end

function CLASS:Think()
	for _, child in pairs(self.Components) do
		child:Think()
	end
end

function CLASS:Remove()
	for _, child in pairs(self.Components) do
		child:Remove()
	end
end

function CLASS:Draw(renderMode)
	if renderMode and self.Hidden then
		return
	end

	if self.Entity == lp and not lp:ShouldDrawLocalPlayer() then
		return
	end

	for _, child in pairs(self.Components) do
		if child.Hidden then
			continue
		end

		child:Draw(renderMode)
	end
end

inherit.Register("part", "outfit", CLASS)
