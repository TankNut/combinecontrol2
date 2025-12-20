function ITEM:CanDrop(ply)
	if self:IsEquipped() then
		return false, "You cannot drop equipped items!"
	end

	return true
end

function ITEM:CanDestroy(ply)
	if self:IsEquipped() then
		return false, "You cannot destroy equipped items!"
	end

	return true
end

function ITEM:CanEquip(ply)
	return true
end

function ITEM:CanUnequip(ply)
	return true
end

function ITEM:CanStore(ply, inventory)
	if self:IsEquipped() then
		return false, "You cannot store equipped items!"
	end

	return true
end

function ITEM:CanBeMoved()
	if self:IsEquipped() then
		return false, "Unequip it first!"
	end

	return true
end

function ITEM:CanInteract(ply)
	if not ply:CanAct() then
		return false, "You cannot do this right now!"
	end

	if self:GetStoreType() == INV_PLAYER and self:GetParent() == ply then
		return true
	end

	return false, "You can only interact with items in your own inventory!"
end

function ITEM:CheckMove(ply, destination, noWeightCheck)
	local ok, err = self:CanBeMoved()
	if not ok then return false, err end

	local inventory = self:GetInventory()

	if not inventory then
		return false, "This item isn't in an inventory!"
	end

	ok, err = inventory:CanAccess(ply)
	if not ok then return false, err end

	if not destination then
		return false, "Invalid destination!"
	end

	ok, err = destination:CanAccess(ply)
	if not ok then return false, err end

	ok, err = destination:CanAccept(self, noWeightCheck)
	if not ok then return false, err end

	return true
end
