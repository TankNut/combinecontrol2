CLASS.Base = "Say" -- To inherit CLASS:FormatUnknownLanguage

CLASS.Name        = "Radio"
CLASS.Description = "Speak over your radio."
CLASS.Typing      = "Radioing..."
CLASS.Radio       = true

CLASS.Commands = {"radio", "r"}

CLASS.UseLanguage = false -- TODO: Add support for languages
CLASS.Hearable    = true

CLASS.Range        = 400
CLASS.MuffledRange = 150

CLASS.Tabs        = TAB_RADIO
CLASS.LogCategory = "radio"

CLASS.Color         = Color(72, 118, 255)
CLASS.LanguageColor = Color(255, 167, 73)

CLASS.LocalName = "Say"

CLASS.MessageFormat = "<c=%s>[%s] %s: %s"
CLASS.LogFormat     = "[%s] [%s] [%s] %s: %s"
CLASS.LegacyFormat  = "[%s] %s: %s"
CLASS.LegacyFont    = "CombineControl.ChatRadio"

if CLIENT then
	function CLASS:OnReceive(data)
		local channel, name, text = data.Channel, data.Name, data.Text
		local hud = Hud.Get("radio")

		if hud then
			hud:AddMessage(string.format(self.LegacyFormat, channel, name, text), self.LegacyFont)
		end

		return string.format(self.MessageFormat, self.Color, channel, name, text)
	end
end

if SERVER then
	function CLASS:GetTargets(ply, channel, encryption, jammed)
		local good, bad = {}, {}

		for _, target in player.Iterator() do
			if not IsValid(target) then
				continue
			end

			local enabled, speaker, scrambled = Radio.CanHear(target, channel, encryption, jammed)

			if not enabled then
				continue
			end

			if speaker then
				table.Add(scrambled and bad or good, self:GetLocalTargets(target, channel))
			end

			table.insert(scrambled and bad or good, target)
		end

		return good, bad
	end

	function CLASS:GetLocalTargets(ply, frequency)
		local targets = Chat.GetTargets(ply:EyePos(), self.Range or 0, self.MuffledRange or 0, self.Hearable)

		for i, target in ipairs(targets) do
			local enabled = Radio.CanHear(target, frequency)

			if not enabled then
				continue
			end

			targets[i] = nil
		end

		return targets
	end

	function CLASS:Parse(ply, lang, cmd, text)
		local settings, radio = Radio.ActiveSettings(ply)

		if not settings then
			ply:SendChat("ERROR", "You don't have a configured radio equipped!")

			return
		end

		local frequency = settings.Frequency
		local encryption = radio.CanEncrypt and settings.Encryption
		local jammed = Radio.IsJammed(frequency)

		local goodTargets, badTargets = self:GetTargets(ply, frequency, encryption, jammed)
		local localTargets = self:GetLocalTargets(ply, frequency)

		local preset = Radio.GetPreset(settings.Preset)
		local channel = preset and preset.Name or string.format("%s MHz", frequency)
		local name = ply:VisibleRPName()

		local data = {
			Name    = name,
			Lang    = lang,
			Text    = text,
			Channel = channel,
		}

		if #goodTargets > 0 then
			Chat.Send(self.Name, data, goodTargets)
		end

		if #badTargets > 0 then
			Chat.Send(self.Name, {
				Name    = "Unknown",
				Lang    = lang,
				Text    = string.Gibberish(text, 50),
				Channel = channel
			}, badTargets)
		end

		if #localTargets > 0 then
			Chat.Send(self.LocalName, {
				Name    = name,
				Lang    = lang,
				Text    = text
			}, localTargets)
		end

		Log.Write("chat_" .. self.LogCategory, self, data, jammed, ply)
	end

	function CLASS:WriteLog(data, jammed, ply)
		local jam = jammed and "Jammed" or "Unjammed"
		local lang = Language.Get(data.Lang).Name

		return string.format(self.LogFormat, data.Channel, jam, lang, data.Name, data.Text), {
			Log.Player(ply),
			ChatType = "radio"
		}
	end
end
