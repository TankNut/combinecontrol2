CLASS.Name = "Event"
CLASS.Description = "Describe a global event."
CLASS.Typing = "Eventing..."

CLASS.Commands = {"ev"}

CLASS.Tabs = TAB_IC
CLASS.Log = "ic"
CLASS.LogFiles = {"ic"}

CLASS.Color = Color(0, 191, 255)

if CLIENT then
	function CLASS:OnReceive(data)
		return string.format("<c=%s>[EVENT] ** %s", self.Color, data.Text), string.format("<c=%s>[EVENT] (%s) ** %s", self.Color, data.Name, data.Text)
	end
end

if SERVER then
	function CLASS:Parse(ply, lang, cmd, text)
		return {
			Name = ply:VisibleRPName(),
			Text = text
		}
	end

	function CLASS:WriteLog(data, ply)
		return string.format("[EVENT] (%s) ** %s", ply:VisibleRPName(), data.Text), {
			Log.Character(ply),
			ChatType = "event"
		}
	end
end
