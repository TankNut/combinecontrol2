CLASS.Name = "Local OOC"
CLASS.Description = "Local out-of-character chat."
CLASS.Typing = "Typing..."

CLASS.Commands = {"looc"}
CLASS.Aliases = {"[[", ".//"}

CLASS.Range = 400

CLASS.Tabs = TAB_LOOC
CLASS.Log = "ooc"
CLASS.LogFiles = {"ooc"}

CLASS.Color = Color(138, 185, 209)

if CLIENT then
	function CLASS:OnReceive(data)
		return string.format("<c=%s>%s: [LOCAL-OOC] %s", self.Color, data.Name, data.Text)
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
		return string.format("[LOOC] %s: %s", ply:VisibleRPName(), data.Text), {
			Log.Character(ply),
			ChatType = "looc"
		}
	end
end
