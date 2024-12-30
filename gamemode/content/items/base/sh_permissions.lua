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
