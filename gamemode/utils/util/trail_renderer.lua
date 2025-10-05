local CLASS = CustomMetaTable("TrailRenderer")

AccessorFunc(CLASS, "Material", "Material")

AccessorFunc(CLASS, "Spacing", "Spacing")
AccessorFunc(CLASS, "Lifetime", "Lifetime")
AccessorFunc(CLASS, "Distance", "Distance")

AccessorFunc(CLASS, "StartWidth", "StartWidth")
AccessorFunc(CLASS, "EndWidth", "EndWidth")

AccessorFunc(CLASS, "StartColor", "StartColor")
AccessorFunc(CLASS, "EndColor", "EndColor")

AccessorFunc(CLASS, "Gravity", "Gravity")

function CLASS:Initialize()
	self.Points = {}
	self.LastUpdate = CurTime()

	-- Accessors
	self.Material = Material("trails/laser")

	self.Spacing = 0.25
	self.Lifetime = 1
	self.Distance = 0

	self.StartWidth = 3
	self.EndWidth = 0

	self.StartColor = Color(255, 255, 255, 255)
	self.EndColor = Color(255, 255, 255, 0)

	self.Gravity = Vector()
end

function CLASS:Update(pos, ang)
	local time = CurTime()

	if not self.Points[1] then
		table.insert(self.Points, {
			Pos = Vector(pos),
			Time = CurTime(),
			Distance = 0
		})
	else
		local dist = self.Points[#self.Points].Pos:Distance(pos)

		if dist > self.Spacing then
			table.insert(self.Points, {
				Pos = Vector(pos),
				Time = CurTime(),
				Distance = dist
			})
		end
	end

	if not self.Gravity:IsZero() then
		local delta = time - self.LastUpdate
		local gravity = self.Gravity * delta

		gravity:Rotate(ang)

		for _, data in ipairs(self.Points) do
			data.Pos:Add(gravity)
		end
	end

	self.LastUpdate = time
end

local col = Color()

function CLASS:Draw()
	if #self.Points == 0 then
		return
	end

	local time = CurTime()
	local count = #self.Points

	local distance = 0

	render.SetMaterial(self.Material)

	render.StartBeam(count)
		for i = count, 1, -1 do
			local data = self.Points[i]

			if i != count then
				distance = distance + data.Distance
			end

			local f

			if self.Distance > 0 then
				f = 1 - (distance / self.Distance)
			else
				f = 1 - (time - data.Time) / self.Lifetime
			end

			local f2 = f

			f = -f + 1

			local tex = (1 / count) * (i - 1)

			col.r = math.Clamp(Lerp(tex, self.EndColor.r, self.StartColor.r), 0, 255)
			col.g = math.Clamp(Lerp(tex, self.EndColor.g, self.StartColor.g), 0, 255)
			col.b = math.Clamp(Lerp(tex, self.EndColor.b, self.StartColor.b), 0, 255)
			col.a = math.Clamp(Lerp(tex, self.EndColor.a, self.StartColor.a), 0, 255)

			render.AddBeam(data.Pos, (f * self.EndWidth) + (f2 * self.StartWidth), tex, col)

			if f >= 1 then
				table.remove(self.Points, i)
			end
		end
	render.EndBeam()
end

function CLASS:SetMaterial(mat)
	self.Material = Material(mat)
end

function util.TrailRenderer()
	local instance = setmetatable({}, CLASS)

	instance:Initialize()

	return instance
end
