CLASS.Base = "Radio"

CLASS.Name        = "Radio Dispatch"
CLASS.Description = "Speak to a radio group."
CLASS.Typing      = "Dispatching..."

CLASS.Commands = {"rdis", "rdispatch"}

CLASS.Hearable = false

CLASS.MessageFormat = "<c=%s>[%s] DISPATCH: %s"
CLASS.ConsoleFormat = "<c=%s>[%s] DISPATCH (%s): %s"

if CLIENT then
	function CLASS:OnReceive(data)
		local color, group, name, text = self.Color, data.Group, data.Name, data.Text

		local primary   = string.format(self.MessageFormat, color, group, text)
		local secondary = string.format(self.ConsoleFormat, color, group, name, text)

		return primary, secondary
	end
end

if SERVER then
	function CLASS:GetDispatchTargets(ply, group)
		local targets = {ply}

		for _, target in player.Iterator() do
			if not IsValid(target) then
				continue
			end

			if not target:CanHearDispatch(group) then
				continue
			end

			targets[#targets + 1] = target
		end

		return targets
	end

	function CLASS:Parse(ply, lang, cmd, text)
		-- TODO: Allow player faction leadership to use this command.
		if not ply:IsAdmin() then
			ply:SendChat("ERROR", "You need to be an admin to do this!")

			return
		end

		-- Separate the first word from the rest
		local group, message = text:match("(%S+)(.*)")
		message = message:Trim()

		-- TODO: Default to the player's active channel's group, if applicable
		if not Radio.IsValidGroup(group) then
			ply:SendChat("ERROR", string.format("Invalid radio group. Try: %s", table.concat( Radio.GetGroups(), ", ") ))

			return
		end

		local targets = self:GetDispatchTargets(ply, group)
		local data = {
			Name = ply:VisibleRPName(),
			Lang = lang,
			Text = message,
			Group = group:upper()
		}

		Chat.Send(self.Name, data, targets)

		Log.Write("chat_" .. self.LogCategory, self, data, ply)
	end

	function CLASS:WriteLog(data, ply)
		return string.format("[%s] DISPATCH (%s): %s", data.Group, ply:VisibleRPName(), data.Text), {
			Log.Character(ply),
			ChatType = "radio"
		}
	end
end
