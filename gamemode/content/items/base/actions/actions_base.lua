ITEM.Actions.Pickup = {
	ServerOnly = true,

	CanRun = function(self, ply)
		return hook.Run("CanPickupItem", ply, self)
	end,
	Callback = function(self, ply)
		self:SetInventory(ply:GetInventory())
	end
}

ITEM.Actions.Drop = {
	Priority = 1,

	CanRun = function(self, ply)
		return hook.Run("CanDropItem", ply, self)
	end,
	Callback = function(self, ply)
		self:SetWorldItem(Item.GetDropPosition(ply), Angle(0, ply:EyeAngles().y, 0), false)
	end
}

ITEM.Actions.Destroy = {
	CanRun = function(self, ply)
		return hook.Run("CanDestroyItem", ply, self)
	end,
	Callback = function(self, ply)
		self:Delete()
	end
}
