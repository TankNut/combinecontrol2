function ITEM:GetReceivers()
	local inventory = self:GetInventory()

	return inventory and inventory.Receivers or {}
end

function ITEM:CompareReceivers(old, new)
	local add = {}
	local move = {}
	local remove = {}

	for ply in pairs(old) do
		if new[ply] then
			table.insert(move, ply)
		else
			table.insert(remove, ply)
		end
	end

	for ply in pairs(new) do
		if not old[ply] then
			table.insert(add, ply)
		end
	end

	return add, move, remove
end

function ITEM:UpdateNetworking(old)
	local inventory = self:GetInventory()
	local add, move, remove = self:CompareReceivers(old, self:GetReceivers())

	if #add > 0 then
		netstream.Send(add, "AddItem", self.ClassName, self.ID, self.Data, inventory.ID)
	end

	if #move > 0 then
		netstream.Send(move, "MoveItem", self.ID, inventory.ID)
	end

	if #remove > 0 then
		netstream.Send(remove, "RemoveItem", self.ID)
	end
end
