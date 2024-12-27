local meta = CustomMetaTable("Inventory")

function meta:OnRemove()
	for _, item in pairs(self.Items) do
		item:Remove()
	end

	if SERVER then
		netstream.Send(self.Receivers, "RemoveInventory", self.ID)
	end
end

function meta:ItemsChanged()
	self:RecalculateWeight()

	if CLIENT then
		self:CallPanels("Populate", self)
	end
end
