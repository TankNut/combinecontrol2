local PANEL = {}

function PANEL:Init()
	local width = ui.Scale(115)

	self:DockMargin(0, 0, 0, ui.Scale(15))
	self:Dock(TOP)

	self.Left = self:Add("Panel")
	self.Left:SetWide(width)

	self.Label = self.Left:Add("DLabel")
	self.Label:SetWide(width)
	self.Label:SetFont("CombineControl.LabelGiant")
	self.Label:SetWrap(true)
	self.Label:SetAutoStretchVertical(true)

	self.Tooltip = self.Left:Add("DLabel")
	self.Tooltip:SetWide(width)
	self.Tooltip:SetFont("CombineControl.LabelTiny")
	self.Tooltip:SetTextColor(Color("cc_disabled"))
	self.Tooltip:SetWrap(true)
	self.Tooltip:SetAutoStretchVertical(true)

	self.Canvas = self:Add("Panel")

	self.Canvas.PerformLayout = function(pnl, w, h)
		pnl:SizeToChildren(false, true)
	end
end

function PANEL:SetTitle(title)
	self.Label:SetText(title)
end

function PANEL:SetTooltip(text)
	self.Tooltip:SetText(text)
end

function PANEL:GetOption()
	return self.CharCreate.Options[self.ID]
end

function PANEL:SetOption(val)
	self.CharCreate:SetOption(self.ID, val)
end

function PANEL:Setup(args, val, options)
end

function PANEL:PerformSetup(args, val, options)
	self:Setup(args, val, options)
end

function PANEL:PerformLayout(w, h)
	self.Tooltip:MoveBelow(self.Label, ui.Scale(5))

	self.Canvas:MoveRightOf(self.Left, ui.Scale(10))
	self.Canvas:StretchToParent(nil, nil, 0, nil)

	self.Left:SizeToChildren(false, true)

	self:SizeToChildren(false, true)
end

function PANEL:OnOptionChanged(key, val)
end

vgui.Register("CC_CharCreate", PANEL, "Panel")
