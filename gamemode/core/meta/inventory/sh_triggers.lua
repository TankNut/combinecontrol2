local meta = CustomMetaTable("Inventory")

function meta:OnRemove()
	for _, item in pairs(self.Items) do
		item:Remove()
	end

	if CLIENT then
		local panel = GUI.Get("InventoryPopup")

		if IsValid(panel) and panel.Inventory == self then
			panel:Remove()
		end
	else
		netstream.Send(self.Receivers, "RemoveInventory", self.ID)
	end
end

function meta:ItemsChanged()
	self:RecalculateWeight()

	if CLIENT then
		self:CallPanels("Populate", self)
	end
end

function meta:WeightChanged()
	if self.StoreType == INV_PLAYER then
		self:GetPlayer():SetInventoryWeight(self.Weight)
	elseif self.StoreType == INV_ITEM then
		local item = self:GetItem()

		if item:GetData("Weight", 0) != self.Weight then
			item:SetData("Weight", self.Weight)
		end
	end
end
