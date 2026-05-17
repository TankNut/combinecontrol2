CLASS.Name = "CONSOLE"

CLASS.Color = Color(200, 200, 200)

if CLIENT then
	function CLASS:OnReceive(data)
		scribe.Parse(string.format("<c=%s>%s", self.Color, data.Text)):PrintToConsole()
	end
end
