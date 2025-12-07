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

		local frequency = settings.Frequency
		local jammed = Radio.IsJammed(frequency)

		local name = jammed and "Unknown" or ply:VisibleRPName()
		local radioText = jammed and string.Gibberish(text, 50) or text

		local radioTargets = self:GetRadioTargets(ply, settings)
		local localTargets = self:GetLocalTargets(ply, settings)

		local preset = Radio.GetPreset(settings.Preset)
		local channel = preset and preset.Name or string.format("%s MHz", frequency)

		local radioData = {
			Name    = name,
			Lang    = lang,
			Text    = radioText,
			Channel = channel
		}
		local localData = {
			Name    = name,
			Lang    = lang,
			Text    = text,
			Channel = channel
		}

		Chat.Send(self.Name, radioData, radioTargets)
		Chat.Send(self.LocalName, localData, localTargets)

		Log.Write("chat_" .. self.LogCategory, self, localData, jammed, ply)
	end

	function CLASS:WriteLog(data, jammed, ply)
		return string.format(self.LogFormat, data.Channel, jammed and "Jammed" or "Unjammed", Language.Get(data.Lang).Name, ply:VisibleRPName(), data.Text), {
			Log.Character(ply),
			ChatType = "radio"
		}
	end
end
