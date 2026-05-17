CLASS.Name = "OOC"
CLASS.Description = "Global out-of-character chat."
CLASS.Typing = "Typing..."

CLASS.Commands = {"ooc"}
CLASS.Aliases = {"//"}

CLASS.Tabs = TAB_OOC
CLASS.LogCategory = "ooc"

CLASS.Color = Color(200, 0, 0)

if CLIENT then
	function CLASS:OnReceive(data)
		return string.format("<c=%s>[OOC]</c> <c=%s>%s</c>: %s", self.Color, data.Color, data.Name, data.Text)
	end
end

if SERVER then
	function CLASS:Parse(ply, lang, cmd, text)
		if ply:OOCMuted() == 1 then
			ply:SendChat("ERROR", "You are muted from OOC chat.")

			return
		end

		if not ply:IsAdmin() then
			local delay = GAMEMODE:OOCDelay()

			if delay == -1 then
				ply:SendChat("ERROR", "OOC chat is currently disabled.")

				return
			elseif delay > 0 then
				local time = (ply.LastOOC or 0) + delay

				if time > CurTime() then
					ply:SendChat("ERROR", "You must wait " .. string.NiceTime(time - CurTime()) .. " to use OOC chat again.")

					return
				end
			end
		end

		ply.LastOOC = CurTime()

		return {
			Name = ply:VisibleRPName(),
			Color = team.GetColor(ply:Team()),
			Text = text
		}
	end

	function CLASS:WriteLog(data, ply)
		return string.format("[OOC] %s: %s", ply:VisibleRPName(), data.Text), {
			Log.Player(ply),
			ChatType = "ooc"
		}
	end
end
