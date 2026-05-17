CLASS.Name = "GENERIC"

CLASS.Color = Color(200, 200, 200)

if CLIENT then
	function CLASS:OnReceive(data)
		return string.format("<c=%s>%s", data.Color or self.Color, data.Text)
	end
end
