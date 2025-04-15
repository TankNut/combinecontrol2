local INVENTORY = CustomMetaTable("Inventory")

function INVENTORY:OnRemove()
	for _, item in pairs(self.Items) do
		item:Remove()
	end

	if CLIENT then
		local panels = GUI.Get("InventoryPopup")

		for _, panel in pairs(panels) do
			if IsValid(panel) and panel.Inventory == self then
				panel:Remove()
			end
		end
	else
		netstream.Send(self.Receivers, "RemoveInventory", self.ID)
	end
end

function INVENTORY:ItemsChanged()
	self:RecalculateWeight()

	if CLIENT then
		self:CallPanels("Populate", self)
	end
end

function INVENTORY:WeightChanged()
	if self.StoreType == INV_PLAYER then
		self:GetPlayer():SetInventoryWeight(self.Weight)
	elseif self.StoreType == INV_ITEM then
		local item = self:GetItem()

		if item:GetData("Weight", 0) != self.Weight then
			item:SetData("Weight", self.Weight)
		end
	end
end
