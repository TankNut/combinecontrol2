function GM:PlayerBindPress(ply, bind, down)
	if not ply:HasCharacter() then
		return true
	end

	if Chat.Bind(bind, down) then return true end
	if WeaponSelect.Bind(bind, down) then return true end

	if down and string.find(bind, "showspare2") and LocalPlayer():IsAdmin() then

		self:CreateAdminMenu()
		return true

	end

	if down and string.find(bind, "rp_toggleholster") then
		if LocalPlayer():PassedOut() then return end
		if LocalPlayer():TiedUp() then return end

		net.Start("nToggleHolster")
		net.SendToServer()

		local weapon = LocalPlayer():GetActiveWeapon()

		if IsValid(weapon) then
			if weapon.TRP then
				RunConsoleCommand("impulse", 30)
			end

			if weapon.ToggleHolster then
				weapon:ToggleHolster()
			end

			if weapon.Holsterable then
				LocalPlayer():SetHolstered(not LocalPlayer():Holstered())
			else
				LocalPlayer():SetHolstered(false)
			end

		end

		return true

	end

	if ply.FreezeTime and CurTime() < ply.FreezeTime then

		if down and string.find(bind, "+jump") then

			return true

		end

		if down and string.find(bind, "+duck") then

			return true

		end

	end

	if down and string.find(bind, "+attack") and LocalPlayer():TiedUp() then

		return true

	end

	if down and string.find(bind, "+reload") and LocalPlayer():TiedUp() then

		return true

	end

	return hook.Run("CC.CL.PlayerBindPress", ply, bind, down)
end

function GM:ToggleHolsterThink()
	if not self.ToggleHolsterPressed then self.ToggleHolsterPressed = false end

	if vgui.CursorVisible() then self.ToggleHolsterPressed = false return end

	if input.IsKeyDown(KEY_B) and not self.ToggleHolsterPressed then
		self.ToggleHolsterPressed = true

		if LocalPlayer():PassedOut() then return end
		if LocalPlayer():TiedUp() then return end

		net.Start("nToggleHolster")
		net.SendToServer()

		local weapon = LocalPlayer():GetActiveWeapon()

		if IsValid(weapon) then
			if weapon.Holsterable then
				LocalPlayer():SetHolstered(not LocalPlayer():Holstered())
			else
				LocalPlayer():SetHolstered(false)
			end

			if weapon.ToggleHolster then
				weapon:ToggleHolster()
			end
		end
	elseif not input.IsKeyDown(KEY_B) and self.ToggleHolsterPressed then
		self.ToggleHolsterPressed = false
	end
end
