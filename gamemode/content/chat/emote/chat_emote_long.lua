CLASS.Name = "Long Emote"
CLASS.Description = "Perform an action at a greater distance."
CLASS.Typing = "Emoting..."

CLASS.Commands = {"lme", "lem"}
CLASS.Aliases = {":"}

CLASS.Range = 800
CLASS.MuffledRange = 400

CLASS.Tabs = TAB_IC
CLASS.LogCategory = "ic"
CLASS.LogFiles = {"ic"}

CLASS.Color = Color(131, 196, 251)

if CLIENT then
	function CLASS:OnReceive(data)
		local text = data.Text

		if not string.match(text, "^[,.']") then
			text = " " .. text
		end

		return string.format("<c=%s>** %s%s", self.Color, data.Name, text), string.format("<c=%s>[L] ** %s%s", self.Color, data.Name, text)
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
		local text = data.Text

		if not string.match(text, "^[,.']") then
			text = " " .. text
		end

		return string.format("[L] ** %s%s", ply:VisibleRPName(), text), {
			Log.Character(ply),
			ChatType = "emote"
		}
	end
end
