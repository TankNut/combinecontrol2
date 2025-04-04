CLASS.Name = "Say"
CLASS.Description = "Speak, the default chat command."
CLASS.Typing = "Talking..."

CLASS.Commands = {"say"}

CLASS.UseLanguage = true
CLASS.Hearable = true

CLASS.Range = 400
CLASS.MuffledRange = 150

CLASS.Tabs = TAB_IC
CLASS.Log = "ic"
CLASS.LogFiles = {"ic"}

CLASS.Color = Color(91, 166, 221)
CLASS.LanguageColor = Color(255, 167, 73)

if CLIENT then
	function CLASS:OnReceive(data)
		if data.Form then -- We don't understand them
			return string.format("<c=%s>%s %s.", self.LanguageColor, data.Name, data.Form)
		else -- We do understand them
			if data.Lang == lp:RunCharFlag("BaseLanguage") then
				return string.format("<c=%s>%s: %s", self.Color, data.Name, data.Text)
			else
				return string.format("<c=%s>[%s] %s: %s", self.LanguageColor, Language.Get(data.Lang).Name, data.Name, data.Text)
			end
		end
	end
end

if SERVER then
	function CLASS:FormatUnknownLanguage(str, lang)
		local override = Language.GetOverride(lang, "Say")

		if override then
			return override
		end

		local lastCharacter = string.Right(str, 1)
		local form = "says"

		if lastCharacter == "?" then
			form = "asks"
		elseif lastCharacter == "!" then
			form = "exclaims"
		end

		return form .. " something in " .. Language.Get(lang).Unknown
	end

	function CLASS:Parse(ply, lang, cmd, text)
		local targets = self:GetTargets(ply)

		local valid = {}
		local invalid = {}

		for _, target in pairs(targets) do
			if target == ply or target:CanUnderstandLanguage(lang) then
				table.insert(valid, target)
			else
				table.insert(invalid, target)
			end
		end

		if self.Log then
			Log.Write("chat_" .. self.Log, self, ply, Language.Get(lang).Name, text)
		end

		-- No reason to check for an empty table since we're always sending the valid version to ourselves
		Chat.Send(self.Name, {
			Name = ply:VisibleRPName(),
			Lang = lang,
			Text = text
		}, valid)

		if not table.IsEmpty(invalid) then
			local form = self:FormatUnknownLanguage(text, lang)

			Chat.Send(self.Name, {
				Name = ply:VisibleRPName(),
				Form = form
			}, invalid)
		end
	end

	function CLASS:WriteLog(ply, lang, text)
		return string.format("[%s] %s: %s", lang, ply:VisibleRPName(), text), {
			Log.Character(ply),
			ChatType = "say",
			Language = lang
		}
	end
end
