local SHAPE = CustomMetaTable("SphereShape")

function SHAPE:Set(pos, radius)
	self.Position:Set(pos)
	self.Radius = radius
end

function SHAPE:ClosestPoint(pos)
	if self:Contains(pos) then
		return pos
	end

	local normal = pos - self.Position
	normal:Normalize()
	normal:Mul(self.Radius)

	return self.Position + normal
end

function SHAPE:Contains(pos)
	return self.Position:DistToSqr(pos) <= (self.Radius * self.Radius)
end

function util.SphereShape()
	local instance = setmetatable({
		Position = Vector(),
		Radius = 0
	}, SHAPE)

	return instance
end
