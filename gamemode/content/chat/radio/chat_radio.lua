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

CLASS.MessageFormat = "<c=%s>[%s] %s: %s"

if CLIENT then
	function CLASS:OnReceive(data)
		return string.format(self.MessageFormat, self.Color, data.Channel, data.Name, data.Text)
	end
end

if SERVER then
	function CLASS:GetRadioTargets(ply, settings)
		local targets = {ply}

		for _, target in player.Iterator() do
			if not IsValid(target) then
				continue
			end

			local enabled, encryption, speaker = target:CanHearRadio(settings.Frequency)

			if not enabled then
				continue
			end

			-- Encryption being true signals the target has AdminRadio enabled and should not be subject to encryption
			if encryption and encryption != true then
				-- Verify encryption == settings.Encryption
				-- This will eventually require garbling the output if encrypted
			end

			if speaker then
				table.Add(targets, self:GetLocalTargets(target, settings))
			end

			targets[#targets + 1] = target
		end

		return targets
	end

	function CLASS:GetLocalTargets(ply, settings)
		local targets = Chat.GetTargets(ply:EyePos(), self.Range or 0, self.MuffledRange or 0, self.Hearable)

		for i, target in ipairs(targets) do
			local enabled = target:CanHearRadio(settings.Frequency)

			if not enabled then
				continue
			end

			targets[i] = nil
		end

		return targets
	end

	function CLASS:Parse(ply, lang, cmd, text)
		local settings = ply:ActiveRadioSettings()

		if not settings then
			ply:SendChat("ERROR", "You don't have a configured radio equipped!")
			
			return
		end

		local radioTargets = self:GetRadioTargets(ply, settings)
		local localTargets = self:GetLocalTargets(ply, settings)

		local preset = Radio.GetPreset(settings.Preset)
		local channel = preset and preset.Name or settings.Frequency .. " MHz"

		Chat.Send(self.Name, {
			Name    = ply:VisibleRPName(),
			Lang    = lang,
			Text    = text,
			Channel = channel
		}, radioTargets)

		Chat.Send(self.LocalName, {
			Name = ply:VisibleRPName(),
			Lang = lang,
			Text = text
		}, localTargets)

		if self.LogCategory then
			Log.Write("chat_" .. self.LogCategory, self, ply, Language.Get(lang).Name, text)
		end
	end
end
