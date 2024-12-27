local meta = CustomMetaTable("Inventory")

function meta:AddItem(item)
	self.Items[item.ID] = item

	item.InventoryID = self.ID
end

function meta:RemoveItem(item)
	self.Items[item.ID] = nil

	item.InventoryID = nil
end

function meta:RecalculateWeight()
	local weight = 0

	for _, item in pairs(self.Items) do
		weight = weight + item:GetWeight()
	end

	self.Weight = weight
end

if CLIENT then
	function meta:LoadItems(items)
		for _, item in ipairs(items) do
			self:AddItem(Item.Instance(item[1], item[2], item[3]))
		end

		self:ItemsChanged()

		for _, item in pairs(self.Items) do
			item:OnLoaded()
		end
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

			self:AddItem(Item.Instance(data.Class, data.id, data.CustomData and sfs.decode(data.CustomData) or nil))
		end

		self:ItemsChanged()

		for _, item in pairs(self.Items) do
			item:OnLoaded()
		end
	end
end
