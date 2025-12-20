DEFINE_BASECLASS("CC_Frame")

local PANEL = {}

function PANEL:Init()
	self:SetSize(ui.Scale(250), ui.Scale(70))
	self:SetDraggable(true)

	self:SetCloseOnPause()

	self.Label = self:Add("DLabel")
	self.Label:SetContentAlignment(4)

	self.Slider = self:Add("DNumSlider")
	self.Slider:SetDecimals(0)
	self.Slider:SetMin(1)
	self.Slider.PerformLayout = function(pnl, w, h)
		pnl.Label:SetWide(0)
		pnl.TextArea:SetWide(0)
	end

	self.Slider.OnValueChanged = function(_, val)
		self.Label:SetText(math.Round(val) .. "/" .. self.Slider:GetMax())
	end

	self.Submit = self:Add("DButton")
	self.Submit:SetTall(ui.Scale(22))
	self.Submit:SetText("Submit")

	self.Submit.DoClick = function()
		async.Handle(self.Coroutine, self.Slider:GetValue())

		self:Remove()
	end
end

function PANEL:Setup(verb, item, max)
	self.Coroutine = coroutine.running()
	self.Item = item

	self:SetTopBar(verb .. " Item: " .. item:GetName())

	self.Slider:SetMax(max)
	self.Slider:SetValue(self.Slider:GetMax())
end

function PANEL:PerformLayout(w, h)
	BaseClass.PerformLayout(self, w, h)

	local offset = ui.Scale(10)
	local spacing = ui.Scale(5)

	self.Submit:AlignBottom(offset)
	self.Submit:AlignRight(offset)

	self.Slider:StretchToParent(offset, offset + 24, offset + spacing + self.Label:GetWide(), nil)

	self.Label:SetY(self.Slider:GetY())
	self.Label:SetTall(self.Slider:GetTall())
	self.Label:MoveRightOf(self.Slider, spacing)
	self.Label:StretchToParent(nil, offset + 24, offset, nil)
end

vgui.Register("GUI_DropAmount", PANEL, "CC_Frame")

ui.Register("ItemDropAmount", function(verb, item, max)
	local panel = vgui.Create("GUI_DropAmount")

	panel:Setup(verb, item, max)

	panel:MakePopup()
	panel:Center()

	return coroutine.yield()
end)
