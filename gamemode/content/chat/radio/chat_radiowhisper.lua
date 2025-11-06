CLASS.Base = "Radio"

CLASS.Name        = "Radio Whisper"
CLASS.Description = "Quietly whisper over your radio."

CLASS.Commands = {"radiowhisper", "rw"}

CLASS.Range = 150

CLASS.LocalName = "Whisper"

if CLIENT then
	function CLASS:OnReceive(data)
		return string.format("<c=%s><i>[%s] %s: %s", self.Color, data.Channel, data.Name, data.Text)
	end
end
