CLASS.Base = "Radio"

CLASS.Name        = "Radio Yell"
CLASS.Description = "Yell something over your radio."

CLASS.Commands = {"radioyell", "ry"}

CLASS.Range        = 800
CLASS.MuffledRange = 400

CLASS.LocalName = "Yell"

if CLIENT then
	function CLASS:OnReceive(data)
		return string.format("<c=%s><b>[%s] %s: %s", self.Color, data.Channel, data.Name, data.Text)
	end
end
