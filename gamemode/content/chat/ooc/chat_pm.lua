CLASS.Name = "Private Message"
CLASS.Description = "Sends a private message to a specific player."
CLASS.Typing = "Typing..."

CLASS.Commands = {"pm"}

CLASS.Tabs = TAB_PM
CLASS.Log = "ooc"
CLASS.LogFiles = {"ooc", "pm"}

CLASS.Color = Color(160, 255, 160)

if CLIENT then
	function CLASS:OnReceive(data)
		local format = "<c=%s>[PM %s %s] %s"
		local direction = "from"

		if data.Sent then
			direction = "to"
		end

		return string.format(format, self.Color, direction, data.Name, data.Text)
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
		target.ReplyTarget = ply

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
		return string.format("[PM] %s -> %s: %s", ply:VisibleRPName(), data.Target:VisibleRPName(), data.Text), {
			Log.Character(ply),
			Log.Character(data.Target),
			ChatType = "pm"
		}
	end
end
