CLASS.Name = "ADMINWARN"

CLASS.LogCategory = "admin"

CLASS.Color = Color(200, 0, 0)

if CLIENT then
	function CLASS:OnReceive(data)
		return string.format("<giant><c=%s>%s", self.Color, data.Text)
	end
end
