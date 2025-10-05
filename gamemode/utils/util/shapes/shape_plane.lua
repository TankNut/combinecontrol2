local SHAPE = CustomMetaTable("PlaneShape")

function SHAPE:FromNormal(normal, distance)
	self.Normal:Set(normal)
	self.Normal:Normalize()

	self.Distance = distance
end

function SHAPE:FromPoint(pos, normal)
	self.Normal:Set(normal)
	self.Normal:Normalize()

	self.Distance = pos:Dot(self.Normal)
end

function SHAPE:DistanceTo(pos)
	return self.Normal:Dot(pos) - self.Distance
end

function SHAPE:ClosestPoint(pos)
	return pos - self:DistanceTo(pos) * self.Normal
end

function SHAPE:Contains(pos)
	return self:DistanceTo(pos) <= 0
end

function util.PlaneShape()
	local instance = setmetatable({
		Normal = Vector(0, 0, 1),
		Distance = 0
	}, SHAPE)

	return instance
end
