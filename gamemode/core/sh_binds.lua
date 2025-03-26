function GM:PlayerButtonDown(ply, button)
	if button == ply:GetSetting("WeaponHolsteringKey") then
		local weapon = ply:GetActiveWeapon()

		if weapon:IsType("weapon_cc_base") then
			weapon:ToggleHolster()
		end

		return
	end

	if SERVER then
		numpad.Activate(ply, button)
	end
end

if CLIENT then
	function GM:PlayerBindPress(ply, bind, down)
		if not ply:HasCharacter() then
			return true
		end

		if Chat.Bind(bind, down) then return true end
		if WeaponSelect.Bind(bind, down) then return true end
	end

	local toggle = {}
	local lastToggle = {}

	local function toggleKey(key, cmd)
		local down = cmd:KeyDown(key)

		if not down and lastToggle[key] and system.HasFocus() then
			toggle[key] = not toggle[key]
		end

		if toggle[key] then
			cmd:AddKey(key)
		end

		lastToggle[key] = down
	end

	local dir = Vector()
	local last = {0, 0, 0, 0}

	function GM:CreateMove(cmd)
		if Settings.Get("ToggleCrouch") then toggleKey(IN_DUCK, cmd) end
		if Settings.Get("ToggleSprint") then toggleKey(IN_SPEED, cmd) end
		if Settings.Get("ToggleFreelook") then toggleKey(IN_WALK, cmd) end

		if Settings.Get("AutoWalk") then
			local sensitivity = Settings.Get("StickyKeySensitivity")
			local curTime = CurTime()
			local move = Vector(cmd:GetForwardMove(), cmd:GetSideMove())

			if cmd:CommandNumber() != 0 then
				for k, v in ipairs({IN_MOVELEFT, IN_FORWARD, IN_MOVERIGHT, IN_BACK}) do
					if not lp:KeyPressed(v) then
						continue
					end

					local axis = (k % 2) + 1

					local timeSince = curTime - last[k]
					local lastMove = dir[axis]

					if dir[axis] == 0 and timeSince < sensitivity then
						dir[axis] = move[axis]
						last[k] = 0
					else
						dir[axis] = 0
					end

					if lastMove == 0 and dir[axis] == 0 then
						last[k] = curTime
					end
				end
			end

			if dir.x != 0 then cmd:SetForwardMove(dir.x) end
			if dir.y != 0 then cmd:SetSideMove(dir.y) end
		end
	end

	function GM:ScoreboardShow()
		GUI.Open("Scoreboard")
	end

	function GM:ScoreboardHide()
		GUI.Close("Scoreboard")
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

	function GM:ShowSpare2(ply)
		if ply:IsAdmin() then
			ply:OpenGUI("AdminMenu")
		end
	end
end
