function render.GetViewID(noPlayer)
	return render.GetViewSetup(noPlayer).viewid
end

function render.IsDrawingMainView()
	return render.GetViewID(true) == VIEW_MAIN
end

function render.DrawWorldText(pos, text, noz)
	local ang = (pos - EyePos()):Angle()

	cam.Start3D2D(pos, Angle(0, ang.y - 90, 90), 0.25)
		if noz then
			render.DepthRange(0, 0)
		end

		render.PushFilterMag(TEXFILTER.POINT)
		render.PushFilterMin(TEXFILTER.POINT)
			surface.SetFont("BudgetLabel")

			local w, h = surface.GetFontSize("BudgetLabel", text)

			surface.SetTextColor(255, 255, 255, 255)
			surface.SetTextPos(-w * 0.5, -h * 0.5)

			surface.DrawText(text)
		render.PopFilterMin()
		render.PopFilterMag()

		if noz then
			render.DepthRange(0, 1)
		end
	cam.End3D2D()
end

local tracerColor = Color(255, 255, 255)

-- Returns false if done rendering
function render.DrawTracer(startpos, endpos, velocity, length, scale, time, color)
	local dir = endpos - startpos
	local distance = dir:Length()
	dir:Normalize()

	-- Minimum length
	if distance <= 128 then
		return false
	end

	local lifetime = (distance + length) / velocity

	if time > lifetime then
		return false
	end

	local startDistance = velocity * time
	local endDistance = startDistance - length

	startDistance = math.Clamp(startDistance, 0, distance)
	endDistance = math.Clamp(endDistance, 0, distance)

	if startDistance == 0 and endDistance == 0 then
		return true
	end

	local offset = math.abs(startDistance - endDistance) / length

	local origin = EyePos()

	-- Is this backwards? I don't know
	local endPoint = startpos + dir * startDistance
	local startPoint = startpos + dir * endDistance

	local lineDir = endPoint - startPoint
	local viewDir = endPoint - origin

	local cross = lineDir:Cross(viewDir)
	cross:Normalize()

	tracerColor:Set(color or color_white)

	render.DrawBeam(startPoint, endPoint, scale * 2, 0, offset, tracerColor)

	tracerColor:SetBrightness(0.25)

	render.DrawBeam(startPoint, endPoint, scale * 4, 0, offset, tracerColor)

	return true
end
