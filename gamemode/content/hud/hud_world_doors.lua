HUD.Name = "Door Labels"

HUD.Setting = "DoorLabels"

local function getTrace(ent, reversed)
	local center = ent:WorldSpaceCenter()
	local trace = {
		endpos = center,
		filter = ent,
		whitelist = true
	}

	local size = ent:OBBMins() - ent:OBBMaxs()

	size.x = math.abs(size.x)
	size.y = math.abs(size.y)
	size.z = math.abs(size.z)

	local offset
	local width = 0

	if size.z < size.x and size.z < size.y then
		offset = ent:GetUp() * size.z
		width = size.y
	elseif size.x < size.y then
		offset = ent:GetForward() * size.x
		width = size.y
	elseif size.y < size.x then
		offset = ent:GetRight() * size.y
		width = size.x
	end

	trace.start = center + (reverse and -offset or offset)

	return util.TraceLine(trace), math.abs(width)
end

function HUD:GetTextPosition(ent)
	local tr, width = getTrace(ent)

	if tr.Entity != ent then
		tr, width = getTrace(ent, true)

		if tr.Entity != ent then
			return
		end
	end

	local eye = EyePos()

	local center = ent:WorldSpaceCenter()

	local len = (center - tr.HitPos):Length() + 1

	local pos1 = center - (len * tr.HitNormal)
	local pos2 = center + (len * tr.HitNormal)

	local pos = nil
	local ang = tr.HitNormal:Angle()

	ang:RotateAroundAxis(ang:Forward(), 90)

	if pos1:DistToSqr(eye) < pos2:DistToSqr(eye) then
		ang:RotateAroundAxis(ang:Right(), 90)
		pos = pos1
	else
		ang:RotateAroundAxis(ang:Right(), -90)
		pos = pos2
	end

	return pos, ang, width
end

function HUD:PostDrawTranslucentRenderables(depth, skybox)
	if skybox then
		return
	end

	surface.SetFont("CombineControl.World")

	local eye = lp:EyePos()
	local max = Config.Get("EntityRange")
	local min = max * 0.4

	for ent in EntityCache.Iterator("doors") do
		if ent:IsDormant() then
			continue
		end

		local title, subtitle = Doors.GetText(ent)

		if #title == 0 and #subtitle == 0 then
			continue
		end

		local pos, ang, width = self:GetTextPosition(ent)

		if not pos then
			continue
		end

		local alpha = math.ClampedRemap(eye:Distance(ent:WorldSpaceCenter()), max, min, 0, 255)

		local w1, h = surface.GetFontSize("CombineControl.World", title)
		local w2 = surface.GetFontSize("CombineControl.World", subtitle)

		if #title > 0 then
			local scale = math.min((width * 0.6) / w1, 0.04)

			cam.Start3D2D(pos, ang, scale)
				draw.SimpleTextOutlined(title, "CombineControl.World", 0, -h, Color("cc_normal", alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, alpha))
			cam.End3D2D()
		end

		if #subtitle > 0 then
			local scale = math.min((width * 0.6) / w2, 0.02)

			cam.Start3D2D(pos, ang, scale)
				draw.SimpleTextOutlined(subtitle, "CombineControl.World", 0, 0, Color("cc_primary", alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, alpha))
			cam.End3D2D()
		end
	end
end

