local PANEL = {}
DEFINE_BASECLASS("DPanel")

function PANEL:Init()
	self.Weight = self:Add("CCProgressBar")
	self.Weight:DockMargin(0, 10, 0, 0)
	self.Weight:Dock(BOTTOM)
	self.Weight:SetTall(20)

	self.Scroll = self:Add("DScrollPanel")
	self.Scroll:Dock(FILL)

	self.Layout = self.Scroll:Add("DTileLayout")
	self.Layout:Dock(FILL)
	self.Layout:SetBaseSize(48)
	self.Layout:SetBorder(3)
	self.Layout:SetSpaceX(3)
	self.Layout:SetSpaceY(3)
end

function PANEL:PerformLayout(w, h)
	self.Weight:SetPos(0, h - 20)
end

function PANEL:Populate(inventory)
	inventory.Panels[self] = true

	self.Inventory = inventory
	self.Layout:Clear()

	for _, item in pairs(inventory.Items) do
		local icon = vgui.Create("CCItemIcon")
		icon:SetItem(item)

		self.Layout:Add(icon)
		self:OnIconAdded(icon)
	end

	self:Sort()
	self:UpdateWeight()
end

function PANEL:OnIconAdded(icon)
end

function PANEL:UpdateWeight()
	local weight = self.Inventory.Weight
	local max = self.Inventory:GetMaxWeight()

	if max == 0 then
		self.Weight:SetProgress(1)
		self.Weight:SetProgressText("Weight: " .. weight)
	else
		self.Weight:SetProgress(weight / max)
		self.Weight:SetProgressText(string.format("Weight: %s/%s", weight, max))
	end
end

function PANEL:OnRemove()
	self.Inventory.Panels[self] = nil
end

function PANEL:Sort()
	local children = self.Layout:GetChildren()

	for _, v in pairs(children) do
		v:SetParent(nil)
	end

	table.sort(children, function(a, b)
		a = a.Item
		b = b.Item

		if a:IsTemporaryItem() != b:IsTemporaryItem() then
			return b:IsTemporaryItem() and true or false
		end

		return a.ID < b.ID
	end)

	for _, v in pairs(children) do
		self.Layout:Add(v)
	end
end

function PANEL:Paint(w, h)
	derma.SkinHook("Paint", "ItemList", self, w, h - 30)
end

derma.DefineControl("CCItemList", "", PANEL, "DPanel")
