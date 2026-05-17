local BaseClass = inherit.Get("hud", "base")

HUD.Name = "Edit Mode"

function HUD:ShouldAddElement()
	if not lp:IsAdmin() then
		return false
	end

	return BaseClass.ShouldAddElement(self)
end

function HUD:ShouldDraw()
	if not lp:EditMode() then
		return false
	end

	return BaseClass.ShouldDraw(self)
end

local offset = Vector(0.1, 0.1, 0.1)

function HUD:DrawButtons()
	for button in Buttons.Iterator() do
		if not IsValid(button) or button:IsDormant() then
			continue
		end

		local color = Buttons.GetAccessType(button).Color

		local mins = button:OBBMins()
		local maxs = button:OBBMaxs()

		mins:Sub(offset)
		maxs:Add(offset)

		render.SetColorMaterial()
		render.DrawBox(button:GetPos(), button:GetAngles(), mins, maxs, color, true)
	end
end

local lineColor = Color(0, 120, 0)
local groupColor = ColorAlpha(lineColor, 100)

local groupMin = Vector(-5, -5, -5)
local groupMax = Vector(5, 5, 5)

function HUD:DrawDoors()
	local groups = {}

	render.SetColorMaterial()

	for ent in Doors.Iterator() do
		local group = ent:DoorGroup()

		if #group > 0 then
			groups[group] = groups[group] or {}

			table.insert(groups[group], ent:WorldSpaceCenter())
		end

		if ent:IsDormant() then
			continue
		end

		local color = Doors.GetAccessType(ent).Color

		local mins = ent:OBBMins()
		local maxs = ent:OBBMaxs()

		mins:Sub(offset)
		maxs:Add(offset)

		render.DrawBox(ent:GetPos(), ent:GetAngles(), mins, maxs, color, true)
	end

	for group, positions in pairs(groups) do
		-- Don't draw groups that only contain one door
		if #positions <= 1 then
			continue
		end

		local pos = Vector()

		for _, vec in ipairs(positions) do
			pos:Add(vec)
		end

		pos:Div(#positions)

		render.DepthRange(0, 0)
			for _, vec in ipairs(positions) do
				render.DrawLine(vec, pos, lineColor, true)
			end

			render.SetColorMaterial()
			render.DrawBox(pos, Angle(), groupMin, groupMax, groupColor, true)
			render.DrawWorldText(pos + Vector(0, 0, 5), group)
		render.DepthRange(0, 1)
	end
end

function HUD:PostDrawTranslucentRenderables(depth, skybox)
	if skybox then
		return
	end

	self:DrawButtons()
	self:DrawDoors()
end
