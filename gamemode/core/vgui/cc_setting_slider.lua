local PANEL = {}

local sliderWidth = 250

function PANEL:Init()
	self.Slider = self:Add("DNumSlider")
	self.Slider:SetWide(sliderWidth)

	self.Slider.OnValueChanged = function(_, val)
		val = math.Round(self.Slider:GetValue(), self.Slider:GetDecimals())

		self.Save:SetDisabled(val == self:GetSetting())
	end

	self.Slider.PerformLayout = function(pnl, w, h)
		pnl.Label:SetWide(0)
	end

	self.Save = self:Add("DButton")
	self.Save:DockMargin(0, 1, 5, 1)
	self.Save:Dock(RIGHT)
	self.Save:SetText("Save")
	self.Save:SizeToContentsX(20)

	self.Save.DoClick = function(pnl)
		local val = math.Round(self.Slider:GetValue(), self.Slider:GetDecimals())

		self:SaveSetting(val)
		pnl:SetDisabled(true)
	end
end

function PANEL:ApplySetting(value)
	self.Slider:SetValue(value)
	self.Save:SetDisabled(true)
end

function PANEL:PerformLayout(w, h)
	self.Slider:MoveRightOf(self.Label)
	self.Slider:CenterVertical(0.5)
end

function PANEL:Setup(args)
	args = args or {}

	self.Slider:SetMin(args.Min or 0)
	self.Slider:SetMax(args.Max or 1)
	self.Slider:SetDecimals(args.Decimals or 0)
	self.Slider.Slider:SetNotches(args.Notches or 1)
end

derma.DefineControl("CC_Setting_Slider", "", PANEL, "CC_Setting")
