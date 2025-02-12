if CLIENT then
	function GM:PlayerBindPress(ply, bind, down)
		if not ply:HasCharacter() then
			return true
		end

		if Chat.Bind(bind, down) then return true end
		if WeaponSelect.Bind(bind, down) then return true end

		if down and string.find(bind, "rp_toggleholster") then
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

		return hook.Run("CC.CL.PlayerBindPress", ply, bind, down)
	end
else
	function GM:ShowHelp(ply)
		ply:OpenGUI("HelpMenu")
	end

	function GM:ShowTeam(ply)
		ply:OpenGUI("CharacterSelect")
	end

	function GM:ShowSpare1(ply)
		ply:OpenGUI("PlayerMenu")
	end
end
