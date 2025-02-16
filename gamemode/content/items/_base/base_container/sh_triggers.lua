local BaseClass = inherit.Get("item", "base")

function ITEM:OnRemove()
	if SERVER then
		self.Contents:Remove()
	end

	BaseClass.OnRemove(self)
end

if SERVER then
	function ITEM:OnDelete()
		for _, item in pairs(self.Contents.Items) do
			item:Delete()
		end
	end
end

function ITEM:OnDropped()
	BaseClass.OnDropped(self)

	if SERVER then
		self.Contents:UpdateReceivers()
	end
end

function ITEM:InventoryAdded(inventory)
	BaseClass.InventoryAdded(self, inventory)

	if SERVER then
		self.Contents:UpdateReceivers()
	end
end

function ITEM:OnBaseWeightChanged(old, new)
	local inventory = self:GetInventory()

	if inventory then
		inventory:RecalculateWeight()
	end
end
