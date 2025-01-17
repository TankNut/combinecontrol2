local PANEL = {}

function PANEL:Init()
	self.Layout = self.Canvas:Add("DTileLayout")
	self.Layout:SetBaseSize(56)
	self.Layout:Dock(FILL)
end

function PANEL:Setup(args, val)
	for _, mdl in ipairs(args.Models) do
		local icon = vgui.Create("SpawnIcon")

		icon:SetSize(56, 56)
		icon:SetModel(mdl)
		icon:SetTooltip()

		icon.DoClick = function()
			self:SetOption(mdl)
		end

		self.Layout:Add(icon)
	end

	if not val then
		self:SetOption(args.Models[1])
	end
end

derma.DefineControl("CC_CharCreate_Model", "", PANEL, "CC_CharCreate")
