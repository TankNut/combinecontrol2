local PANEL = {}

AccessorFunc(PANEL, "AutoStretchVertical", "AutoStretchVertical")

function PANEL:SetAlignment(x, y)
	self.AlignmentX = x
	self.AlignmentY = y
end

function PANEL:SetText(text)
	self.Text = text
	self:Rebuild()
end

function PANEL:GetText()
	return self.Text or ""
end

function PANEL:Rebuild()
	local text = self:GetText()

	if text then
		self.Scribe = scribe.Parse(text, self:GetWide())

		if self.AutoStretchVertical then
			self:SizeToContentsY()
		end
	end
end

function PANEL:PerformLayout()
	self:Rebuild()
end

function PANEL:GetContentSize()
	if self.Scribe then
		return self.Scribe:GetSize()
	else
		return 0, 0
	end
end

function PANEL:Paint(w, h)
	if self.Scribe then
		local x = 0
		local y = 0

		if self.AlignmentX == TEXT_ALIGN_CENTER then
			x = w * 0.5
		elseif self.AlignmentX == TEXT_ALIGN_RIGHT then
			x = w
		end

		if self.AlignmentY == TEXT_ALIGN_CENTER then
			y = h * 0.5
		elseif self.AlignmentY == TEXT_ALIGN_BOTTOM then
			y = h
		end

		self.Scribe:Draw(x, y, self:GetAlpha(), self.AlignmentX, self.AlignmentY)
	end
end

vgui.Register("ScribeLabel", PANEL, "DPanel")
