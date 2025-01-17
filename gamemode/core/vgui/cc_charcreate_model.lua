local PANEL = {}

function PANEL:Init()
	self.Scroll = self.Canvas:Add("DHorizontalScroller")
	self.Scroll:Dock(FILL)

	self:SetTall(56)
end

function PANEL:Setup(args, val)
	for _, mdl in ipairs(args.Models) do
		local icon = self.Scroll:Add("SpawnIcon")

		icon:SetSize(56, 56)
		icon:SetModel(mdl)
		icon:SetTooltip()

		icon.DoClick = function()
			self:SetOption(mdl)
		end

		self.Scroll:AddPanel(icon)
	end

	if not val then
		self:SetOption(args.Models[1])
	end
end

derma.DefineControl("CC_CharCreate_Model", "", PANEL, "CC_CharCreate")
