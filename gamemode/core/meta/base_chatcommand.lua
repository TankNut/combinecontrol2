local CLASS = {}

CLASS.Name = "Unnamed Command"
CLASS.Description = "No description set."
CLASS.Typing = nil -- The text to display when someone is typing this command
CLASS.Radio = false -- Whether to use the radio animation when typing

CLASS.Commands = {}
CLASS.Aliases = {}

CLASS.UseLanguage = false
CLASS.Hearable = false -- Whether entities can hear us
CLASS.Cast = false

CLASS.Range = nil
CLASS.MuffledRange = nil

CLASS.Tabs = nil
CLASS.Log = nil

if CLIENT then
	function CLASS:OnReceive(data)
	end
end

if SERVER then
	function CLASS:GetTargets(ply, data)
		local targets = {ply}
		local global = true

		if self.Range or self.MuffledRange then
			global = false

			targets = table.Add(targets, Chat.GetTargets(ply:EyePos(), self.Range or 0, self.MuffledRange or 0, self.Hearable))
		end

		if self.Cast then
			global = false

			targets = table.Add(targets, Chat.GetTargets(ply:GetEyeTrace().HitPos, self.Range or 0, self.MuffledRange or 0, self.Hearable))
		end

		return global and player.GetAll() or table.Unique(targets)
	end

	function CLASS:Parse(ply, lang, cmd, text)
		return true
	end

	function CLASS:Handle(ply, lang, cmd, text)
		-- Todo: config option
		text = string.Escape(string.sub(text, 1, 500))

		if self.UseLanguage then
			-- Should only happen if they don't have a language at all
			if not lang then
				ply:SendChat("ERROR", "You cannot speak!")

				return
			elseif not hook.Run("CanSpeakLanguage", ply, lang) then
				ply:SendChat("ERROR", "You don't speak this language!")

				return
			end
		end

		local data = self:Parse(ply, lang, cmd, text)

		if data == nil then
			return
		end

		data.__Type = self.Name

		if self.Log then
			Log.Write("chat_" .. self.Log, self, data, ply)
		end

		netstream.Send(self:GetTargets(ply, data), "SendChat", data)
	end

	function CLASS:WriteLog(data, ply)
		return
	end
end

inherit.Register("chat", "base", CLASS)
