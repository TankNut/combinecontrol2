local PANEL = {}

function PANEL:Init()
	self.Layout = self.Canvas:Add("DTileLayout")
	self.Layout:SetBaseSize(56)
	self.Layout:Dock(FILL)
end

function PANEL:Setup(args, val, options)
	self.WatchedKey = args.Option

	if not val then
		self:SetOption(0)
	end

	local mdl = options[self.WatchedKey]

	if mdl then
		self:Populate(mdl)
	end
end

function PANEL:Populate(mdl)
	self.Layout:Clear()

	for i = 0, util.GetModelSkins(mdl) - 1 do
		local icon = vgui.Create("SpawnIcon")

		icon:SetSize(56, 56)
		icon:SetModel(mdl, i)
		icon:SetTooltip(false)

		icon.DoClick = function()
			self:SetOption(i)
		end

		self.Layout:Add(icon)
	end

	self:InvalidateLayout()
end

function PANEL:OnOptionChanged(key, val)
	if key == self.WatchedKey then
		self:SetOption(0)
		self:Populate(val)
	end
end

derma.DefineControl("CC_CharCreate_Skin", "", PANEL, "CC_CharCreate")
