CLASS.Base = "Say"

CLASS.Name = "Yell"
CLASS.Description = "Yell something at the top of your lungs."
CLASS.Typing = "Yelling..."

CLASS.Commands = {"yell", "y"}

CLASS.UseLanguage = true
CLASS.Hearable = true

CLASS.Range = 800
CLASS.MuffledRange = 400

CLASS.Tabs = TAB_IC
CLASS.LogCategory = "ic"

CLASS.Color = Color(255, 50, 50)
CLASS.LanguageColor = Color(255, 167, 73)

if CLIENT then
	function CLASS:OnReceive(data)
		if data.Form then -- We don't understand them
			return string.format("<c=%s><b>%s %s.", self.LanguageColor, data.Name, data.Form)
		else -- We do understand them
			if data.Lang == lp:RunCharFlag("BaseLanguage") then
				return string.format("<c=%s><b>%s: [YELL] %s", self.Color, data.Name, data.Text)
			else
				return string.format("<c=%s><b>[%s] %s: [YELL] %s", self.LanguageColor, Language.Get(data.Lang).Name, data.Name, data.Text)
			end
		end
	end
end

if SERVER then
	function CLASS:FormatUnknownLanguage(str, lang)
		local override = Language.GetOverride(lang, "Yell")

		if override then
			return override
		end

		return string.format("yells something in %s!", Language.Get(lang).Unknown)
	end

	function CLASS:WriteLog(ply, lang, text)
		return string.format("[%s] %s: [YELL] %s", lang, ply:VisibleRPName(), text), {
			Log.Player(ply),
			ChatType = "yell",
			Language = lang
		}
	end
end
