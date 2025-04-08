CLASS.Base = "Say"

CLASS.Name = "Whisper"
CLASS.Description = "Quietly whisper to people close to you."
CLASS.Typing = "Whispering..."

CLASS.Commands = {"whisper", "w"}

CLASS.UseLanguage = true
CLASS.Hearable = true

CLASS.Range = 150

CLASS.Tabs = TAB_IC
CLASS.LogCategory = "ic"

CLASS.Color = Color(91, 166, 221)
CLASS.LanguageColor = Color(255, 167, 73)

if CLIENT then
	function CLASS:OnReceive(data)
		if data.Form then -- We don't understand them
			return string.format("<c=%s><i>%s %s.", self.LanguageColor, data.Name, data.Form)
		else -- We do understand them
			if data.Lang == lp:RunCharFlag("BaseLanguage") then
				return string.format("<c=%s><i>%s: [WHISPER] %s", self.Color, data.Name, data.Text)
			else
				return string.format("<c=%s><i>(%s) %s: [WHISPER] %s", self.LanguageColor, Language.Get(data.Lang).Name, data.Name, data.Text)
			end
		end
	end
end

if SERVER then
	function CLASS:FormatUnknownLanguage(str, lang)
		local override = Language.GetOverride(lang, "Whisper")

		if override then
			return override
		end

		return "whispers something in " .. Language.Get(lang).Unknown
	end

	function CLASS:WriteLog(ply, lang, text)
		return string.format("[%s] %s: [WHISPER] %s", lang, ply:VisibleRPName(), text), {
			Log.Character(ply),
			ChatType = "whisper",
			Language = lang
		}
	end
end
