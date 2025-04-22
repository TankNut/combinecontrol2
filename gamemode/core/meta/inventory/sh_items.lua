local INVENTORY = CustomMetaTable("Inventory")

function INVENTORY:AddItem(item)
	self.Items[item.ID] = item

	item.InventoryID = self.ID
end

function INVENTORY:RemoveItem(item)
	self.Items[item.ID] = nil

	item.InventoryID = nil
end

function INVENTORY:RecalculateWeight()
	local weight = 0

	for _, item in pairs(self.Items) do
		weight = weight + item:GetWeight()
	end

	if weight != self.Weight then
		self.Weight = weight
		self:WeightChanged()
	end
end

if CLIENT then
	function INVENTORY:LoadItems(items)
		for _, data in ipairs(items) do
			local item = Item.Instance(data[1], data[2], data[3])

			self:AddItem(item)

			item:Load()
		end

		self:ItemsChanged()

		for _, item in pairs(self.Items) do
			item:OnLoaded()
		end
	end
else
	function INVENTORY:LoadItems()
		local query = GAMEMODE.Database:Query("SELECT * FROM `rp_items` WHERE `StoreType` = :storeType AND `StoreID` = :storeId AND `Deleted_At` IS NULL", {
			storeType = self.StoreType,
			storeId = self.StoreID
		})

		for _, data in ipairs(query) do
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
