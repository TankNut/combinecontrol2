CLASS.Name = "Reply"
CLASS.Description = "Replies to the last PM you received."
CLASS.Typing = "Typing..."

CLASS.Commands = {"reply"}

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
		local target = ply.ReplyTarget

		if not IsValid(target) then
			ply:SendChat("ERROR", "No targets found")

			return
		end

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
