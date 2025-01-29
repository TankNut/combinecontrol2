local PANEL = {}

function PANEL:Init()
	self.Header = self:Add("DButton")
	self.Header:Dock(TOP)
	self.Header:SetFont("CombineControl.LabelGiant")
	self.Header:SetContentAlignment(4)
	self.Header:SetTextInset(10, 0)
	self.Header:SetTall(35)

	self.Header.DoClick = function()
		self:Toggle()
	end
end

function PANEL:Setup(data)
	self.Expanded = true

	self.Header:SetText(data.Name)

	local alt = false

	for _, setting in ipairs(data) do
		local panel = self:Add(setting.Panel)

		panel:Dock(TOP)
		panel:SetAlt(alt)
		panel:Configure(setting)

		alt = not alt
	end

	self:InvalidateLayout()
end

function PANEL:Toggle()
	self.Expanded = not self.Expanded
	self:SetTall(self.Expanded and self.MaxSize or self.Header:GetTall())
end

function PANEL:PerformLayout(w, h)
	if self.Expanded then
		self:SizeToChildren(false, true)
		self.MaxSize = h
	end
end

derma.DefineControl("CC_Settings_Category", "", PANEL, "Panel")
