function ITEM:IsTemporaryItem()
	return self.ID < 0
end

function ITEM:GetParent()
	local inventory = self:GetInventory()

	if inventory then
		return inventory:GetParent()
	end
end

function ITEM:GetStoreType()
	local inventory = self:GetInventory()

	return inventory and inventory.StoreType or INV_WORLD
end

if SERVER then
	function ITEM:IsDropped()
		return IsValid(self.Entity)
	end

	function ITEM:HasModelData()
		return self.GetModelData or self.PostModelData
	end
end

function ITEM:GetAmount()
	return 1
end
