CLASS.Name = "Personal Event"
CLASS.Description = "Describe a personal event to a specific player."
CLASS.Typing = "Eventing..."

CLASS.Commands = {"pev"}

CLASS.Tabs = TAB_IC
CLASS.LogCategory = "ic"
CLASS.LogFiles = {"ic"}

CLASS.Color = Color(225, 205, 130)

if CLIENT then
	function CLASS:OnReceive(data)
		if data.Sent then
			return string.format("<c=%s>[EVENT to %s] ** %s", self.Color, data.Name, data.Text)
		end

		return string.format("<c=%s>[EVENT] ** %s", self.Color, data.Text), string.format("<c=%s>[PERSONAL EVENT] (%s) ** %s", self.Color, data.Name, data.Text)
	end
end

if SERVER then
	function CLASS:Parse(ply, lang, cmd, text)
		local quoted = text[1] == '"'
		local needle = quoted and '"' or "%S+"
		local startIndex = quoted and 2 or 1
		local _, endIndex = string.find(text, needle, startIndex)

		if endIndex == nil then
			ply:SendChat("ERROR", "No targets found")

			return
		end

		local ok, target = console.FindPlayer(ply, string.Trim(string.sub(text, startIndex, endIndex - (quoted and 1 or 0))), {
			NoSelfTarget = true,
			SingleTarget = true
		})

		if not ok then
			ply:SendChat("ERROR", target)

			return
		end

		text = string.Trim(string.sub(text, endIndex + 1))

		Log.Write("chat_" .. self.Log, self, {
			Target = target,
			Text = text
		}, ply)

		netstream.Send(ply, "SendChat", {
			__Type = self.Name,
			Sent = true,
			Name = target:VisibleRPName(),
			Text = text
		})
		netstream.Send(target, "SendChat", {
			__Type = self.Name,
			Name = ply:VisibleRPName(),
			Text = text
		})

		return
	end

	function CLASS:WriteLog(data, ply)
		return string.format("[PERSONAL EVENT] %s -> %s: %s", ply:VisibleRPName(), data.Target:VisibleRPName(), data.Text), {
			Log.Character(ply),
			Log.Character(data.Target),
			ChatType = "event"
		}
	end
end
