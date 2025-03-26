local PANEL = {}

function PANEL:Init()
	self.Label = self:Add("ScribeLabel")
	self.Label:DockMargin(10, 0, 0, 0)
	self.Label:Dock(LEFT)
	self.Label:SetWide(250)
	self.Label:SetAlignment(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	self.Reset = self:Add("DButton")
	self.Reset:DockMargin(0, 1, 1, 1)
	self.Reset:Dock(RIGHT)
	self.Reset:SetText("Reset")
	self.Reset:SizeToContentsX(20)

	self.Reset.DoClick = function(pnl)
		self:SaveSetting(nil)
		self:LoadSetting()
	end
end

function PANEL:SetAlt(alt)
	local colors = self:GetSkin().Colors

	self:SetBackgroundColor(alt and colors.FillDark or colors.FillMedium)
end

function PANEL:SetTitle(title, dark, hint)
	self.Label:SetText(
		"<font=DermaDefault>" ..
		(dark and "<col=cc_dark>" or "") ..
		title ..
		(hint and "<col=cc_dark> (?)</col>" or ""))
end

function PANEL:GetSetting()
	return Settings.Get(self.Setting.Key)
end

function PANEL:SaveSetting(value)
	local key = self.Setting.Key

	Settings.Set(key, value)

	self.Reset:SetDisabled(self:GetSetting() == self.Setting.Default)
end

function PANEL:Setup(args)
end

function PANEL:ApplySetting(value)
end

function PANEL:LoadSetting()
	self:ApplySetting(self:GetSetting())
end

function PANEL:Configure(setting)
	self.Setting = setting
	self:SetTitle(setting.Name, setting.Dark, setting.Hint)

	if setting.Hint then
		self.Label:SetTooltipPanelOverride("CC_Tooltip")
		self.Label:SetTooltip(setting.Hint)
	end

	local value = self:GetSetting()

	if value == setting.Default then
		self.Reset:SetDisabled(true)
	end

	self:Setup(setting.Args)
	self:LoadSetting()
end

derma.DefineControl("CC_Setting", "", PANEL, "DPanel")
