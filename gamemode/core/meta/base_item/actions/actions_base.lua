ITEM.Actions.Pickup = {
	ServerOnly = true,

	CanRun = function(self, ply)
		return ply:GetInventory():CanAccept(self)
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
		ui.Open("ItemPopup", self)
	end
}

ITEM.Actions.Move = {
	Hidden = true,

	CanRun = function(self, ply, id)
		return self:CheckMove(ply, Inventory.Get(id))
	end,
	Callback = function(self, ply, id)
		self:SetInventory(Inventory.Get(id))
	end
}

ITEM.Actions.Drop = {
	Priority = ITEM_ACTION_DROP,

	Context = table.Lookup({"RightClick"}),

	CanRun = function(self, ply)
		return hook.Run("CanDropItem", ply, self)
	end,
	Callback = function(self, ply)
		Log.Write("item_drop", ply, self)

		self:SetWorldItem(Item.GetDropPosition(ply), Angle(0, ply:EyeAngles().y, 0))
	end
}

ITEM.Actions.Destroy = {
	Priority = ITEM_ACTION_DESTROY,

	Context = table.Lookup({"RightClick"}),

	CanRun = function(self, ply)
		return hook.Run("CanDestroyItem", ply, self)
	end,
	Client = function(self, ply)
		return not Settings.Get("ConfirmItemDestruction") or ui.Open("Input", "confirm", "Destroy Item", {
			Prompt = string.format("Are you sure you'd like to destroy your %s?", self:GetName()),
		})
	end,
	Callback = function(self, ply)
		Log.Write("item_destroy", ply, self)

		ply:VisibleMessage("NOTICE", string.format("%s destroys their %s", ply:VisibleRPName(), self:GetName()))
		self:Delete()
	end
}
