function GM:CalcView(ply, pos, ang, fov, znear, zfar)
	local view = {
		origin = pos,
		angles = ang,
		fov = fov,
		znear = znear,
		zfar = zfar,
		drawviewer = false
	}

	local vehicle = ply:GetVehicle()

	if IsValid(vehicle) then
		return hook.Run("CalcVehicleView", vehicle, ply, view)
	end

	if ply:IsRagdolled() then
		local ragdoll = ply:GetRagdoll()
		local mins, maxs = ragdoll:GetRenderBounds()
		local radius = (mins - maxs):Length()

		local start = ragdoll:GetPos() + Vector(0, 0, 10)
		local target = start + view.angles:Forward() * -radius

		local tr = util.TraceHull({
			start = start,
			endpos = target,
			filter = {ragdoll, ply},
			mins = Vector(-4, -4, -4),
			maxs = Vector(4, 4, 4)
		})

		view.origin = tr.HitPos

		return view
	end

	return view
end

function GM:ShouldDoThirdPerson(ply)
	if not ply:Alive() or ply:IsRagdolled() then
		return false
	end

	local weapon = ply:GetActiveWeapon()

	if IsValid(weapon) and weapon.ShouldDoThirdPerson then
		local val = weapon:ShouldDoThirdPerson()

		if val != nil then
			return val
		end
	end

	if ply:GetMoveType() == MOVETYPE_NOCLIP then
		return false
	end

	if ply:GetViewEntity() != ply then
		return false
	end

	if ply:InVehicle() then
		return false
	end

	return Settings.Get("Thirdperson")
end

function GM:ShouldDrawLocalPlayer(ply)
	if ply:GetViewEntity() != ply then
		return true
	end

	return hook.Run("ShouldDoThirdPerson", ply)
end
