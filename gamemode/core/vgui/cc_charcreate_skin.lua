local PANEL = {}

function PANEL:Init()
	self.Scroll = self.Canvas:Add("DHorizontalScroller")
	self.Scroll:Dock(FILL)

	self:SetTall(56)
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
	self.Scroll:Clear()

	for i = 0, util.GetModelSkins(mdl) - 1 do
		local icon = self.Scroll:Add("SpawnIcon")

		icon:SetSize(56, 56)
		icon:SetModel(mdl, i)
		icon:SetTooltip(false)

		icon.DoClick = function()
			self:SetOption(i)
		end

		self.Scroll:AddPanel(icon)
	end
end

function PANEL:OnOptionChanged(key, val)
	if key == self.WatchedKey then
		self:SetOption(0)
		self:Populate(val)
	end
end

derma.DefineControl("CC_CharCreate_Skin", "", PANEL, "CC_CharCreate")
