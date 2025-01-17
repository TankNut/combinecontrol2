local PANEL = {}

function PANEL:Init()
	self.Entry = self.Canvas:Add("DTextEntry")
	self.Entry:DockMargin(0, 0, 0, 5)
	self.Entry:Dock(FILL)
	self.Entry:SetMultiline(true)
	self.Entry:SetUpdateOnType(true)

	self.Entry.OnValueChange = function(_, val)
		self:SetOption(val)
	end

	self:SetTall(150)
end

function PANEL:Setup(args, val)
	if val then
		self.Entry:SetText(val)
	else
		self:SetOption("")
	end
end

derma.DefineControl("CC_CharCreate_Multiline", "", PANEL, "CC_CharCreate")
