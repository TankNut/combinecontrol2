function ITEM:IsTemporaryItem()
	return self.ID < 0
end

function ITEM:GetPlayer()
	local inventory = self:GetInventory()

	if inventory then
		return inventory:GetPlayer()
	end
end

function ITEM:GetItem()
	local inventory = self:GetInventory()

	if inventory then
		return inventory:GetItem()
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
end
