function ITEM:CanInteract(ply)
	local inventory = self:GetInventory()

	if not inventory then
		return false, "You cannot interact with this item!"
	end

	return inventory:CanInteract(ply)
end

function ITEM:CanDrop(ply)
	return true
end

function ITEM:CanDestroy(ply)
	return true
end

function ITEM:CanEquip(ply, slot)
	return true
end

function ITEM:CanUnequip(ply)
	return true
end
