CLASS.Name = "Long It"
CLASS.Description = "Describe something from a 3rd person perspective at a greater distance."
CLASS.Typing = "Emoting..."

CLASS.Commands = {"lit"}

CLASS.Range = 800
CLASS.MuffledRange = 400

CLASS.Tabs = TAB_IC
CLASS.LogCategory = "ic"

CLASS.Color = Color(131, 196, 251)

if CLIENT then
	function CLASS:OnReceive(data)
		return string.format("<c=%s>** %s **", self.Color, data.Text), string.format("<c=%s>[L](%s) ** %s **", self.Color, data.Name, data.Text)
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
		return string.format("[L](%s) ** %s **", ply:VisibleRPName(), data.Text), {
			Log.Player(ply),
			ChatType = "it"
		}
	end
end
