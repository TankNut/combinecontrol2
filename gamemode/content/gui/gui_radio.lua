DEFINE_BASECLASS("CC_Frame")

local PANEL = {}
local cache = {}

function PANEL:Init()
	local padding = ui.Scale(10)

	self:SetSize(ui.Scale(335), ui.Scale(137))
	self:DockPadding(padding, padding, padding, padding)

	self:SetCloseOnPause()
	self:SetTopBar("Radio Configuration")
	self:SetDraggable(true)

	self:Populate()

	self:MakePopup()
	self:Center()
end

function PANEL:Populate()
	local margin, height = ui.Scale(5), ui.Scale(20)

	self.Channel = 1

	self:PopulateNavigation(margin, height)
	self:PopulateFrequency(margin, height)
	self:PopulateEncryption(margin, height)
	self:PopulateButtons(margin, height)
end

function PANEL:CreatePanel(key, dock, margin, height)
	local panel = self:Add("Panel")
	panel:DockMargin(0, 0, 0, margin)
	panel:Dock(dock)
	panel:SetTall(height)

	self[key .. "Panel"] = panel

	return panel
end

function PANEL:PopulateNavigation(margin, height)
	local panel = self:CreatePanel("Navigation", TOP, margin, height)

	local function addButton(key, dock, text, delta)
		local button = panel:Add("DButton")
		button:Dock(dock)
		button:SetText(text)
		button.DoClick = function(pnl)
			self.Channel = self.Channel + delta
			self:Refresh()
		end

		self[key] = button
	end

	addButton("Left", LEFT, "<", -1)
	addButton("Right", RIGHT, ">", 1)

	local indicator = panel:Add("DLabel")
	indicator:Dock(FILL)
	indicator:SetContentAlignment(5) -- 5 == Align center
	indicator:SetText("Channel: 1")

	self.Indicator = indicator
end

function PANEL:PopulateFrequency(margin, height)
	local panel = self:CreatePanel("Frequency", TOP, margin, height)

	local title = panel:Add("DLabel")
	title:DockMargin(0, 0, margin, 0)
	title:Dock(LEFT)
	title:SetWide(ui.Scale(60))
	title:SetContentAlignment(6) -- 6 == Align middle-right
	title:SetText("Frequency")

	local preset = panel:Add("DComboBox")
	preset:DockMargin(margin, 0, 0, 0)
	preset:Dock(RIGHT)
	preset:SetWide(ui.Scale(160))

	local frequency = panel:Add("DTextEntry")
	frequency:DockMargin(margin, 0, 0, 0)
	frequency:Dock(FILL)
	frequency:SetUpdateOnType(true)

	preset.OnSelect = function(pnl, val, name, enum)
		local settings = self:GetSettings()
		local data = Radio.GetPreset(enum) or {}

		settings.Frequency = data.Frequency
		settings.Preset = enum

		if not enum then
			settings.Enabled = nil
			settings.Speaker = nil
			if self.ActiveChannel == self.Channel then self.ActiveChannel = 0 end
		end

		self:RefreshFrequency(settings)
		self:RefreshButtons(settings)
	end

	frequency.AllowInput = function(pnl, char)
		if #pnl:GetValue() >= 3 then
			return true
		end

		if not string.find("01234567890", char) then
			return true
		end
	end

	frequency.OnValueChange = function(pnl, val)
		local settings = self:GetSettings()
		val = tonumber(val) or 0

		if val == 0 and not settings.Preset then
			settings.Frequency = nil
			settings.Enabled = nil
			settings.Speaker = nil
			if self.ActiveChannel == self.Channel then self.ActiveChannel = 0 end
		elseif val < 999 and val > 0 then
			settings.Frequency = val
			settings.Preset = nil

			self:RefreshPresets(settings)
		end

		self:RefreshButtons(settings)
	end

	self.Preset = preset
	self.Frequency = frequency
end

function PANEL:PopulateEncryption(margin, height)
	-- PLACEHOLDER
end

function PANEL:PopulateButtons(margin, height)
	local panel = self:CreatePanel("Buttons", BOTTOM, 0, height)

	local function addOption(key, func)
		local label = panel:Add("DLabel")
		label:DockMargin(0, 0, 0, 0)
		label:Dock(LEFT)
		label:SetWide(ui.Scale(50))
		label:SetContentAlignment(6) -- 6 == Align middle-right
		label:SetText(key)

		local box = panel:Add("DCheckBox")
		box:DockMargin(margin, 0, 0, 0)
		box:Dock(LEFT)
		box:SetWide(height)
		box:SetDisabled(true)
		box.OnChange = function(pnl, val)
			local settings = self:GetSettings()

			func(settings, val)

			self:RefreshButtons(settings)
		end

		self[key] = box
	end

	addOption("Enabled", function(settings, val)
		settings.Enabled = val and true or nil
		settings.Speaker = val and settings.Speaker or nil
		if val == false and self.ActiveChannel == self.Channel then self.ActiveChannel = 0 end
	end)
	addOption("Speaker", function(settings, val)
		settings.Speaker = val and true or nil
	end)
	addOption("Active", function(settings, val)
		self.ActiveChannel = val and self.Channel or 0
	end)

	local save = panel:Add("DButton")
	save:DockMargin(0, 0, 0, 0) -- !
	save:Dock(RIGHT)
	save:SetWide(ui.Scale(75))
	save:SetText("Save")
	save:SetDisabled(true)
	save.DoClick = function(pnl)
		self:Submit()
		pnl:SetDisabled(true)
	end

	self.Save = save
end

function PANEL:Setup(data)
	for key, value in pairs(data) do
		cache[key] = value
	end

	local function setup(settings)
		local tab = {}

		for i = 1, cache.MaxChannels do
			tab[i] = settings[i] or {}
		end

		return tab
	end

	local new = #data.Settings == 0

	cache.Settings = new and setup(data.Settings) or table.FullCopy(data.Settings)
	self.Settings = new and setup(data.Settings) or table.FullCopy(data.Settings)
	self.ActiveChannel = data.ActiveChannel

	self:Refresh()
end

function PANEL:Refresh()
	local settings = self:GetSettings()

	self:RefreshNavigation(self.Channel)
	self:RefreshPresets(settings)
	self:RefreshFrequency(settings)
	self:RefreshEncryption(settings)
	self:RefreshButtons(settings)
end

function PANEL:RefreshNavigation(channel)
	if channel == 1 then
		self.Left:SetDisabled(true)
	else
		self.Left:SetDisabled(false)
	end

	if channel == cache.MaxChannels then
		self.Right:SetDisabled(true)
	else
		self.Right:SetDisabled(false)
	end

	self.Indicator:SetText("Channel: " .. channel)
end

function PANEL:RefreshPresets(settings)
	local presets = cache.RadioPresets
	local disabled = #presets == 0

	self.Preset:Clear()
	self.Preset:SetDisabled(disabled)

	if disabled then
		return
	end

	self.Preset:SetSortItems(false)
	self.Preset:AddChoice("NO PRESET")

	for _, enum in ipairs(presets) do
		local preset = Radio.GetPreset(enum)

		if not preset then
			continue
		end

		self.Preset:AddChoice(preset.Name, enum, enum == settings.Preset)
	end
end

function PANEL:RefreshFrequency(settings)
	if not cache.CanSetFrequency then
		self.Frequency:SetDisabled(true)
		return
	end

	self.Frequency:Clear()
	self.Frequency:SetValue(not settings.Preset and settings.Frequency or "")
end

function PANEL:RefreshEncryption(settings)
	if not cache.CanEncrypt then
		return
	end

	-- PLACEHOLDER
end

function PANEL:RefreshButtons(settings)
	self.Enabled:SetEnabled((settings.Frequency or settings.Preset) and true or false)
	self.Enabled:SetChecked(settings.Enabled and true or false)

	self.Speaker:SetEnabled(settings.Enabled and true or false)
	self.Speaker:SetChecked(settings.Speaker and true or false)

	self.Active:SetEnabled(settings.Enabled and true or false)
	self.Active:SetChecked(settings.Enabled and self.ActiveChannel == self.Channel)

	self.Save:SetDisabled(not self:IsEdited())
end

function PANEL:GetSettings()
	return self.Settings[self.Channel]
end

function PANEL:IsEdited()
	if cache.ActiveChannel != self.ActiveChannel then
		return true
	end

	for channel = 1, cache.MaxChannels do
		local cached, set = cache.Settings[channel], self.Settings[channel]

		for _, option in ipairs(cache.Options) do
			if cached[option] != set[option] then
				return true
			end
		end
	end

	return false
end

function PANEL:Submit()
	cache.Settings = table.FullCopy(self.Settings)
	cache.ActiveChannel = self.ActiveChannel

	netstream.Send("RadioConfiguration", cache.ItemID, cache.ActiveChannel, cache.Settings)

	self:Refresh()
end

vgui.Register("GUI_Radio", PANEL, "CC_Frame")

ui.Register("Radio", function(data)
	local instance = vgui.Create("GUI_Radio")

	instance:Setup(data)

	return instance
end, true)
