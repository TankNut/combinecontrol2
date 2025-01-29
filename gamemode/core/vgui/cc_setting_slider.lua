local PANEL = {}

local sliderWidth = 300
local overlap = 250

function PANEL:Init()
	self.Slider = self:Add("DNumSlider")
	self.Slider:SetWide(sliderWidth + overlap)

	self.Slider.OnValueChanged = function(_, val)
		self.Save:SetDisabled(val == self:GetSetting())
	end

	self.Slider.PerformLayout = function(pnl, w, h)
		pnl.Label:SetWide(overlap)
	end

	self.Save = self:Add("DButton")
	self.Save:DockMargin(0, 1, 5, 1)
	self.Save:Dock(RIGHT)
	self.Save:SetText("Save")
	self.Save:SizeToContentsX(20)

	self.Save.DoClick = function(pnl)
		self:SaveSetting(self.Slider:GetValue())
		pnl:SetDisabled(true)
	end
end

function PANEL:ApplySetting(value)
	self.Slider:SetValue(value)
	self.Save:SetDisabled(true)
end

function PANEL:PerformLayout(w, h)
	self.Slider:MoveRightOf(self.Label, -overlap)
	self.Slider:CenterVertical(0.5)
end

function PANEL:Setup(args)
	args = args or {}

	self.Slider:SetMin(args.Min or 0)
	self.Slider:SetMax(args.Max or 1)
	self.Slider:SetDecimals(args.Decimals or 0)
end

derma.DefineControl("CC_Setting_Slider", "", PANEL, "CC_Setting")
