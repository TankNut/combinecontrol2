CLASS.Base = "Radio"

CLASS.Name        = "Radio Dispatch"
CLASS.Description = "Speak to a radio group."
CLASS.Typing      = "Dispatching..."

CLASS.Commands = {"rdis", "rdispatch"}

CLASS.Hearable = false

if SERVER then
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
			ply:SendChat("ERROR", string.format("Invalid radio group. Try: %s", table.concat(table.SetToArray(Radio.Groups), ", ")))

			return
		end

		local targets = self:GetTargets(ply, group)
		local data = {
			Name    = ply:VisibleRPName(),
			Lang    = lang,
			Text    = message,
			Channel = string.format("%s-DISPATCH", group:upper())
		}

		Chat.Send(self.Name, data, targets)

		Log.Write("chat_" .. self.LogCategory, self, data, jammed, ply)
	end
end
