function GM:ToggleHolsterThink()
	if not self.ToggleHolsterPressed then self.ToggleHolsterPressed = false end

	if vgui.CursorVisible() then self.ToggleHolsterPressed = false return end

	if input.IsKeyDown(KEY_B) and not self.ToggleHolsterPressed then
		self.ToggleHolsterPressed = true

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
