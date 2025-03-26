local lookX, lookY = 0, 0
local baseAng, freeAng = Angle(), Angle()

local function lerpMod(from, to, delta)
	from[1] = Lerp(delta, from[1], to[1])
	from[2] = Lerp(delta, from[2], to[2])
	from[3] = Lerp(delta, from[3], to[3])

	if isangle(from) then
		for i = 1, 3 do
			from[i] = math.NormalizeAngle(from[i])
		end
	end
end

local function approachMod(from, to, speed)
	local diff = to - from
	local ratio = math.max(math.abs(diff[1]), math.abs(diff[2]), math.abs(diff[3]))

	from[1] = math.Approach(from[1], to[1], speed * (diff[1] / ratio))
	from[2] = math.Approach(from[2], to[2], speed * (diff[2] / ratio))
	from[3] = math.Approach(from[3], to[3], speed * (diff[3] / ratio))
end

local function active()
	if not lp:KeyDown(IN_WALK) or lp:ShouldDrawLocalPlayer() then
		return false
	end

	return true
end

hook.Add("CalcView", "freelook", function(ply, origin, angles, fov)
	if active() then
		freeAng = Angle(lookY, -lookX, 0)
	else
		lerpMod(freeAng, angle_zero, 0.15)
		approachMod(freeAng, angle_zero, 0.15 * 0.01)

		lookY = 0
		lookX = 0
	end

	if not active() and math.abs(freeAng.p) < 0.05 and math.abs(freeAng.y) < 0.05 then
		baseAng = angles + freeAng
		freeAng = angle_zero

		lookX = 0
		lookY = 0

		return
	end

	angles.p = angles.p + freeAng.p
	angles.y = angles.y + freeAng.y
end)

hook.Add("CalcViewModelView", "freelook", function(wep, vm, oPos, oAng, pos, ang)
	local view = render.GetViewSetup()
	local ratio = view.aspect + (view.fov_unscaled / view.fovviewmodel_unscaled)

	ang.p = ang.p + freeAng.p / ratio
	ang.y = ang.y + freeAng.y / ratio
end)

hook.Add("InputMouseApply", "freelook", function(cmd, x, y, ang)
	if not active() then
		return
	end

	baseAng.z = 0

	cmd:SetViewAngles(baseAng)

	lookX = lookX + x * 0.02
	lookY = lookY + y * 0.02

	if lookX + lookY != 0 then
		local dist = math.sqrt(math.abs(lookX * lookX + lookY * lookY))
		local scale = math.min(60, dist) / dist

		lookX = lookX * scale
		lookY = lookY * scale
	end

	return true
end)

hook.Add("StartCommand", "freelook", function(ply, cmd)
	if not ply:Alive() or not active() then return end

	if ply:KeyDown(IN_WALK) then
		cmd:RemoveKey(IN_ATTACK)
	end
end)
