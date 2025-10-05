local SHAPE = CustomMetaTable("BoxShape")

function SHAPE:FromBounds(mins, maxs)
	self.Mins:Set(mins)
	self.Maxs:Set(maxs)

	self:Sort()
end

function SHAPE:FromPlayer(ply)
	local pos = ply:GetPos()
	local mins, maxs

	if ply:Crouching() then
		mins, maxs = ply:GetHullDuck()
	else
		mins, maxs = ply:GetHull()
	end

	self.Mins:Set(mins)
	self.Mins:Add(pos)

	self.Maxs:Set(maxs)
	self.Maxs:Add(pos)
end

function SHAPE:Sort()
	local ax, ay, az = self.Mins:Unpack()
	local bx, by, bz = self.Maxs:Unpack()

	self.Mins:SetUnpacked(
		math.min(ax, bx),
		math.min(ay, by),
		math.min(az, bz)
	)

	self.Maxs:SetUnpacked(
		math.max(ax, bx),
		math.max(ay, by),
		math.max(az, bz)
	)
end

function SHAPE:GetCenter()
	local vec = self.Mins + self.Maxs
	vec:Mul(0.5)

	return vec
end

function SHAPE:GetSize()
	return self.Maxs - self.Mins
end

function SHAPE:GetExtents()
	local vec = self:GetCenter()
	vec:Sub(self.Maxs)
	vec:Negate()

	return vec
end

function SHAPE:ClosestPoint(pos)
	return Vector(
		math.Clamp(pos.x, self.Mins.x, self.Maxs.x),
		math.Clamp(pos.y, self.Mins.y, self.Maxs.y),
		math.Clamp(pos.z, self.Mins.z, self.Maxs.z)
	)
end

function SHAPE:Contains(pos)
	return math.InRange(pos.x, self.Mins.x, self.Maxs.x)
		and math.InRange(pos.y, self.Mins.y, self.Maxs.y)
		and math.InRange(pos.z, self.Mins.z, self.Maxs.z)
end

function util.BoxShape()
	local instance = setmetatable({
		Mins = Vector(),
		Maxs = Vector()
	}, SHAPE)

	return instance
end
