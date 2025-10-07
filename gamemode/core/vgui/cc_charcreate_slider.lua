DEFINE_BASECLASS("CC_CharCreate")

local PANEL = {}

function PANEL:Init()
	self.TranslatedLabel = self.Canvas:Add("DLabel")

	self.Slider = self.Canvas:Add("DNumSlider")
	self.Slider:SetWide(ui.Scale(250))

	self.Slider.OnValueChanged = function(_, val)
		val = math.Round(self.Slider:GetValue(), self.Slider:GetDecimals())

		self.TranslatedLabel:SetText(self.TranslateLabel(val))

		self:SetOption(val)
	end

	self.Slider.PerformLayout = function(pnl, w, h)
		pnl.Label:SetWide(0)
		pnl.TextArea:SetWide(0)
	end
end

function PANEL:Setup(args, val)
	args = args or {}

	if args.TranslateLabel then
		self.TranslateLabel = args.TranslateLabel or function(v)
			return v
		end
	end

	self.Slider:SetMin(args.Min or 0)
	self.Slider:SetMax(args.Max or 1)
	self.Slider:SetDecimals(args.Decimals or 0)
	self.Slider:SetValue(val or args.Default or args.Min or 0)
	self.Slider.Slider:SetNotches(args.Notches or 1)
end

function PANEL:PerformLayout(w, h)
	BaseClass.PerformLayout(self, w, h)

	self.TranslatedLabel:MoveRightOf(self.Slider, ui.Scale(5))
	self.TranslatedLabel:StretchToParent(nil, ui.Scale(5), 0, nil)
end

vgui.Register("CC_CharCreate_Slider", PANEL, "CC_CharCreate")
