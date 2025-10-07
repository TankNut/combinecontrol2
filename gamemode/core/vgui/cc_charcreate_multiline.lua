DEFINE_BASECLASS("CC_CharCreate")

local PANEL = {}

function PANEL:Init()
	self.Entry = self.Canvas:Add("DTextEntry")
	self.Entry:SetMultiline(true)
	self.Entry:SetUpdateOnType(true)

	self.Entry.OnValueChange = function(_, val)
		self:SetOption(val)
	end
end

function PANEL:Setup(_, val)
	if val then
		self.Entry:SetText(val)
	else
		self:SetOption("")
	end
end

function PANEL:PerformLayout(w, h)
	BaseClass.PerformLayout(self, w, h)

	self.Entry:SetTall(ui.Scale(150))
	self.Entry:StretchToParent(nil, nil, 0, nil)
end

vgui.Register("CC_CharCreate_Multiline", PANEL, "CC_CharCreate")
