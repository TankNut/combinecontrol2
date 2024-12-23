local meta = CustomMetaTable("Inventory")

function meta:AddItem(item, loading)
	self.Items[item.ID] = item

	if not loading then
		self:RecalculateWeight()

		if CLIENT then
			self:CallPanels("Populate", self)
		end
	end
end

function meta:RemoveItem(item, unloading)
	if item:IsEquipped() then
		item:SetEquipmentSlot(nil)
	end

	self.Items[item.ID] = nil

	if not unloading then
		self:RecalculateWeight()

		if CLIENT then
			self:CallPanels("Populate", self)
		end
	end
end

if CLIENT then
	function meta:LoadItems(items)
		for _, item in ipairs(items) do
			Item.Instance(item[1], item[2], item[3]):SetInventory(self, true)
		end

		self:RecalculateWeight()
	end
else
	function meta:LoadItems()
		local query = GAMEMODE.Database:Select("rp_items")
		query:WhereEqual("StoreType", self.StoreType)
		query:WhereEqual("StoreID", self.StoreID)

		for _, data in ipairs(query:Execute()) do
			if not Item.List[data.Class] then
				continue
			end

			local item = Item.Instance(data.Class, data.id, data.CustomData and sfs.decode(data.CustomData) or nil)

			item:SetInventory(self, true)
		end

		self:RecalculateWeight()
	end
end
