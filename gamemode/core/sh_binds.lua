module("Binds", package.seeall)

List = {}

function Add(index, name, default, callback, hint)
	table.insert(List, {
		Setting = index .. "Keybind",
		Callback = callback
	})

	Settings.Add(index .. "Keybind", {
		Name = name,
		Hint = hint,
		Private = true,
		Default = default,
		Validate = {
			validate.Min(BUTTON_CODE_NONE),
			validate.Max(BUTTON_CODE_LAST)
		},
		Panel = "CC_Setting_Keybind"
	}, "Keybinds")
end

function GM:PlayerButtonDown(ply, button)
	for _, data in ipairs(List) do
		if button == ply:GetSetting(data.Setting) then
			data.Callback(ply)

			return
		end
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

		if ply:InVehicle() then
			return
		end

		if WeaponSelect.Bind(bind, down) then return true end
	end

	local states = {}

	local function initMode(mode)
		if mode == KEYMODE_HOLD then
			return {}
		elseif mode == KEYMODE_TOGGLE then
			return {Toggle = false, Last = false}
		elseif mode == KEYMODE_SMART then
			return {Toggle = false, Start = 0, Last = false}
		end
	end

	local function updateKeymode(key, cmd, mode)
		local state = states[key]

		if not state or state.Mode != mode then
			states[key] = initMode(mode)
			state = states[key]
			state.Mode = mode
		end

		if mode == KEYMODE_HOLD then
			return
		elseif mode == KEYMODE_TOGGLE then
			local down = cmd:KeyDown(key)

			if not down and state.Last then
				state.Toggle = not state.Toggle
			end

			state.Last = down
		elseif mode == KEYMODE_SMART then
			local down = cmd:KeyDown(key)
			local last = state.Last

			-- Pressed
			if down and not last then
				state.Start = CurTime()
				state.Toggle = not state.Toggle
			end

			-- Released
			if (not down and last) and (CurTime() - state.Start >= Settings.Get("KeySensitivity") or not system.HasFocus()) then
				state.Toggle = false
			end

			state.Last = down
		end

		if state.Toggle then
			cmd:AddKey(key)
		end
	end

	local dir = Vector()
	local last = {0, 0, 0, 0}

	function GM:CreateMove(cmd)
		updateKeymode(IN_DUCK, cmd, Settings.Get("CrouchKeymode"))
		updateKeymode(IN_SPEED, cmd, Settings.Get("SprintKeymode"))
		updateKeymode(IN_WALK, cmd, Settings.Get("FreelookKeymode"))

		if Settings.Get("AutoWalk") then
			local sensitivity = Settings.Get("KeySensitivity")
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
		ui.Open("Scoreboard")
	end

	function GM:ScoreboardHide()
		ui.Close("Scoreboard")
	end
else
	function GM:ShowHelp(ply)
		ply:OpenGUI("HelpMenu")
	end

	function GM:ShowTeam(ply)
		ply:OpenGUI("CharacterSelect")
	end

	function GM:ShowSpare1(ply)
		if ply:HasCharacter() then
			ply:OpenGUI("PlayerMenu")
		end
	end

	function GM:ShowSpare2(ply)
		if ply:IsAdmin() then
			ply:OpenGUI("AdminMenu")
		end
	end
end
