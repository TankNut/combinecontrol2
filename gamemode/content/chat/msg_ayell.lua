CLASS.Name = "ADMINYELL"

CLASS.LogCategory = "admin"
CLASS.LogFiles = {"ooc", "admin"}

CLASS.Color = Color(232, 20, 20)
CLASS.ConsoleColor = Color(255, 0, 0)

if CLIENT then
	function CLASS:OnReceive(data)
		return string.format("<massive>%s: <c=%s>%s", data.Name, self.Color, data.Text), string.format("<massive>%s: [ANGRY] <c=%s>%s", data.Name, self.ConsoleColor, data.Text)
	end

	function CLASS:WriteLog(data, ply)
		return string.format("[ANGRY] %s: %s", ply:VisibleRPName(), data.Text), {
			Log.Character(ply),
			ChatType = "ayell"
		}
	end
end
