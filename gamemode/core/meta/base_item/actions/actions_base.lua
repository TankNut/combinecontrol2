ITEM.Actions.Pickup = {
	ServerOnly = true,

	CanRun = function(self, ply)
		return hook.Run("CanPickupItem", ply, self)
	end,
	Callback = function(self, ply)
		Log.Write("item_pickup", ply, self)

		self:SetInventory(ply:GetInventory())
	end
}

ITEM.Actions.Examine = {
	ClientOnly = true,
	Priority = ITEM_ACTION_EXAMINE,

	Context = table.Lookup({
		"RightClick"
	}),

	Client = function(self, ply)
		GUI.Open("ItemPopup", self)
	end
}

ITEM.Actions.Drop = {
	Priority = 1,

	Context = table.Lookup({
		"RightClick"
	}),

	CanRun = function(self, ply)
		return hook.Run("CanDropItem", ply, self)
	end,
	Callback = function(self, ply)
		Log.Write("item_drop", ply, self)

		self:SetWorldItem(Item.GetDropPosition(ply), Angle(0, ply:EyeAngles().y, 0))
	end
}

ITEM.Actions.Destroy = {
	Context = table.Lookup({
		"RightClick"
	}),

	CanRun = function(self, ply)
		return hook.Run("CanDestroyItem", ply, self)
	end,
	Client = function(self, ply)
		return not Settings.Get("ConfirmItemDestruction") or GUI.Open("Input", "confirm", "Destroy Item", {
			Prompt = string.format("Are you sure you'd like to destroy your %s?", self:GetName()),
		})
	end,
	Callback = function(self, ply)
		Log.Write("item_destroy", ply, self)

		self:Delete()
	end
}
