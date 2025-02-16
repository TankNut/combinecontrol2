ITEM.Actions.Store = {
	Hidden = true,

	Validate = function(self, ply, id)
		local inventory = Inventory.Get(id)

		if not inventory then
			return false, "This inventory doesn't exist!"
		end

		return hook.Run("CanStoreItem", ply, self, inventory)
	end,
	Callback = function(self, ply, id)
		self:SetInventory(Inventory.Get(id))
	end
}

ITEM.Actions.Take = {
	Hidden = true,

	CanRun = function(self, ply)
		return hook.Run("CanTakeItem", ply, self)
	end,
	Callback = function(self, ply)
		self:SetInventory(ply:GetInventory())
	end
}
