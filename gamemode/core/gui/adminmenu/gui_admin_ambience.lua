local PANEL = {}

function PANEL:GetSongTypeFromPreset(preset)
	local types = {
		[SONG_IDLE] = "Idle",
		[SONG_ALERT] = "Alert",
		[SONG_ACTION] = "Action",
		[SONG_STINGER] =  "Stinger"
	}

	return types[preset.Type] or "None"
end

function PANEL:CreateRandomizeButton(label, type)
	local button = self:Add("DButton")

	button:SetText(label)
	button:SetWide(ui.Scale(150))
	button:SetTall(ui.Scale(22))

	local songs = table.Filter(self.SongPresets:GetLines(), function(_, song)
		return song.Preset.Type == type
	end)

	button:SetDisabled(#songs == 0)

	button.DoClick = function()
		self.SongPresets:ClearSelection()
		self.SongPresets:SelectItem(table.Random(songs))
	end

	return button
end

function PANEL:CreateLabel(text, bold, width)
	local label = self:Add("DLabel")

	label:SetFont("CombineControl.LabelMedium" .. (bold and "Bold" or ""))
	label:SetWide(ui.Scale(width or 150))
	label:SetText(text)

	return label
end

function PANEL:SetupCommandButtons(command, list, isPlayButton)
	local types = {"Global", "Local"}
	local w = ui.Scale(70)
	local h = ui.Scale(22)

	for _, commandType in pairs(types) do
		local button = self:Add("DButton")

		button:SetText(commandType)
		button:SetSize(w, h)
		button:SetDisabled(isPlayButton)

		button.DoClick = function()
			if isPlayButton then
				local path = string.Trim(self.Input:GetValue())
				local volume = math.Remap(self.Volume:GetValue(), 1, 200, 0.01, 2)

				RunConsoleCommand(command, string.lower(commandType), path, volume)
			else
				RunConsoleCommand(command, string.lower(commandType))
			end
		end

		table.insert(list, button)
	end
end

function PANEL:Init()
	local baseWidth = ui.Scale(150)
	local height = ui.Scale(22)

	self.StopSound = self:Add("DButton")
	self.StopSound:SetSize(baseWidth, height)
	self.StopSound:SetText("Force Stopsound")

	self.StopSound.DoClick = function()
		RunConsoleCommand("rpa_stopsound")
	end

	self.KillAmbience = self:Add("DButton")
	self.KillAmbience:SetSize(baseWidth, height)
	self.KillAmbience:SetText("Kill Ambience")

	self.KillAmbience.DoClick = function()
		RunConsoleCommand("rpa_killambience")
	end

	self.SongPresets = self:Add("DListView")
	self.SongPresets:SetMultiSelect(false)
	self.SongPresets:AddColumn("Type"):SetFixedWidth(ui.Scale(50))
	self.SongPresets:AddColumn("Length"):SetFixedWidth(ui.Scale(50))
	self.SongPresets:AddColumn("Title")
	self.SongPresets:SetTall(ui.Scale(202))

	for _, preset in ipairs(Ambience.Songs) do
		self.SongPresets:AddLine(self:GetSongTypeFromPreset(preset), string.ToMinutesSeconds(preset.Length), preset.Name).Preset = preset
	end

	self.SongPresets.OnRowRightClick = function(_, _, line)
		local path = line.Preset.Path
		local dmenu = DermaMenu()

		dmenu:AddOption("Preview Selection", function()
			Ambience.PlayPreview(audio, math.Remap(self.Volume:GetValue(), 1, 200, 0.01, 2))
		end):SetIcon("icon16/ipod_cast.png")

		dmenu:AddOption("Play Global Music", function()
			RunConsoleCommand("rpa_music_play", "global", path)
		end):SetIcon("icon16/control_fastforward_blue.png")

		dmenu:AddOption("Play Local Music", function()
			RunConsoleCommand("rpa_music_play", "local", path)
		end):SetIcon("icon16/control_play_blue.png")

		dmenu:AddOption("Play Global Effect", function()
			RunConsoleCommand("rpa_effect_play", "global", path)
		end):SetIcon("icon16/control_fastforward.png")

		dmenu:AddOption("Play Local Effect", function()
			RunConsoleCommand("rpa_effect_play", "local", path)
		end):SetIcon("icon16/control_play.png")

		dmenu:SetSkin("CombineControl")
		dmenu:Open(gui.MousePos())
	end

	self.SongPresets.OnRowSelected = function(_, _, line)
		self.Input:SetValue(line.Preset.Path)
	end

	self.RandomIdle = self:CreateRandomizeButton("Select Random Idle", SONG_IDLE)
	self.RandomAlert = self:CreateRandomizeButton("Select Random Alert", SONG_ALERT)
	self.RandomAction = self:CreateRandomizeButton("Select Random Action", SONG_ACTION)
	self.RandomStinger = self:CreateRandomizeButton("Select Random Stinger", SONG_STINGER)

	self.InputLabel = self:CreateLabel("File Location or URL", true)
	self.Input = self:Add("DTextEntry")
	self.Input:SetTall(ui.Scale(22))
	self.Input:SetUpdateOnType(true)

	self.Input.OnValueChange = function(_, val)
		local disabled = #string.Trim(val) == 0

		self.Preview:SetDisabled(disabled)

		for _, button in pairs(self.PlayMusicButtons) do
			button:SetDisabled(disabled)
		end

		for _, button in pairs(self.PlayEffectButtons) do
			button:SetDisabled(disabled)
		end
	end

	self.Preview = self:Add("DButton")
	self.Preview:SetText("Preview Selection")
	self.Preview:SetSize(baseWidth, height)
	self.Preview:SetDisabled(true)

	self.Preview.DoClick = function()
		local path = string.Trim(self.Input:GetValue())
		local volume = math.Remap(self.Volume:GetValue(), 1, 200, 0.01, 2)

		Ambience.PlayPreview(path, volume)
	end

	self.VolumeLabel = self:CreateLabel("Playback Volume", true)
	self.Volume = self:Add("DNumSlider")
	self.Volume:SetMin(1)
	self.Volume:SetMax(200)
	self.Volume:SetDecimals(0)
	self.Volume:SetValue(100)
	self.Volume.Slider:SetNotches(20)

	self.Volume.PerformLayout = function(pnl, w, h)
		pnl.Label:SetWide(0)
		pnl.TextArea:SetWide(ui.Scale(25))
	end

	self.PlayMusic = self:CreateLabel("Play Music", false, 75)
	self.PlayMusicButtons = {}
	self:SetupCommandButtons("rpa_music_play", self.PlayMusicButtons, true)

	self.StopMusic = self:CreateLabel("Stop Music", false, 75)
	self.StopMusicButtons = {}
	self:SetupCommandButtons("rpa_music_stop", self.StopMusicButtons, false)

	self.PlayEffect = self:CreateLabel("Play Effect", false, 75)
	self.PlayEffectButtons = {}
	self:SetupCommandButtons("rpa_effect_play", self.PlayEffectButtons, true)

	self.StopEffect = self:CreateLabel("Stop Effect", false, 75)
	self.StopEffectButtons = {}
	self:SetupCommandButtons("rpa_effect_stop", self.StopEffectButtons, false)
end

function PANEL:PerformLayout(w, h)
	self.KillAmbience:AlignRight()
	self.KillAmbience:AlignBottom()

	local spacing = ui.Scale(5)
	local stretch = ui.Scale(10)

	self.StopSound:AlignRight()
	self.StopSound:MoveAbove(self.KillAmbience, spacing)

	self.RandomAction:AlignRight()
	self.RandomAction:AlignTop()

	self.RandomIdle:MoveLeftOf(self.RandomAction, spacing)
	self.RandomIdle:AlignTop()

	self.RandomStinger:AlignRight()
	self.RandomStinger:MoveBelow(self.RandomAction, spacing)

	self.RandomAlert:MoveLeftOf(self.RandomStinger, spacing)
	self.RandomAlert:MoveBelow(self.RandomIdle, spacing)

	self.Preview:AlignRight()
	self.Preview:MoveAbove(self.StopSound, spacing)

	self.Input:AlignLeft()
	self.Input:StretchRightTo(self.Preview, stretch)
	self.Input:MoveAbove(self.StopSound, spacing)

	self.InputLabel:AlignLeft()
	self.InputLabel:StretchRightTo(self.Preview, stretch)
	self.InputLabel:MoveAbove(self.Input, spacing)

	self.Volume:MoveRightOf(self.SongPresets, spacing)
	self.Volume:StretchToParent(nil, nil, 0, nil)
	self.Volume:MoveAbove(self.InputLabel, 0)

	self.VolumeLabel:MoveRightOf(self.SongPresets, stretch)
	self.VolumeLabel:MoveAbove(self.Volume, 0)

	self.SongPresets:AlignLeft()
	self.SongPresets:StretchRightTo(self.RandomIdle, stretch)
	self.SongPresets:StretchBottomTo(self.InputLabel, spacing)

	self.PlayMusic:AlignLeft()
	self.PlayMusic:MoveBelow(self.Input, ui.Scale(7))

	local previous = self.PlayMusic

	for _, button in pairs(self.PlayMusicButtons) do
		button:MoveRightOf(previous, spacing)
		button:MoveBelow(self.Input, spacing)

		previous = button
	end

	self.PlayEffect:MoveRightOf(previous, ui.Scale(20))
	self.PlayEffect:MoveBelow(self.Input, ui.Scale(7))

	previous = self.PlayEffect

	for _, button in pairs(self.PlayEffectButtons) do
		button:MoveRightOf(previous, spacing)
		button:MoveBelow(self.Input, spacing)

		previous = button
	end

	self.StopMusic:AlignLeft()
	self.StopMusic:MoveBelow(self.PlayMusic, ui.Scale(12))

	previous = self.StopMusic

	for index, button in pairs(self.StopMusicButtons) do
		button:MoveRightOf(previous, spacing)
		button:MoveBelow(self.PlayMusicButtons[index], spacing)

		previous = button
	end

	self.StopEffect:MoveRightOf(previous, ui.Scale(20))
	self.StopEffect:MoveBelow(self.PlayMusic, ui.Scale(12))

	previous = self.StopEffect

	for index, button in pairs(self.StopEffectButtons) do
		button:MoveRightOf(previous, spacing)
		button:MoveBelow(self.PlayEffectButtons[index], spacing)

		previous = button
	end
end

vgui.Register("CC_AdminMenu_Ambience", PANEL, "Panel")
