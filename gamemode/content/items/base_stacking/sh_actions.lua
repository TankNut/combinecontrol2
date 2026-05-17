local function drop(self, ply)
	Log.Write("item_drop", ply, self)

	self:SetWorldItem(Item.GetDropPosition(ply), Angle(0, ply:EyeAngles().y, 0))
end

local function dropAmount(self, ply, amount)
	if amount >= self:GetAmount() then
		drop(self, ply)
	else
		drop(self:Split(amount), ply)
	end
end

ITEM.Actions = {}
ITEM.Actions.Drop = {
	Priority = ITEM_ACTION_DROP,

	Context = table.Lookup({"RightClick"}),

	CanRun = function(self, ply)
		return hook.Run("CanDropItem", ply, self)
	end,

	Validate = function(self, ply, amount)
		return validate.Value(amount, {
			validate.Number(),
			validate.Min(1),
			validate.Max(self:GetAmount())
		})
	end,

	Client = function(self, ply)
		if self:GetAmount() == 1 then
			return true, 1
		end

		return true, ui.Open("ItemDropAmount", "Drop", self, self:GetAmount())
	end,
	Callback = function(self, ply, amount)
		dropAmount(self, ply, math.Round(amount))
	end
}

ITEM.Actions.DropOne = {
	Name = "Drop\tDrop One",
	Priority = ITEM_ACTION_DROP - 1,

	Context = table.Lookup({"RightClick"}),

	CanRun = function(self, ply)
		return hook.Run("CanDropItem", ply, self) and self:GetAmount() > 1
	end,
	Callback = function(self, ply)
		dropAmount(self, ply, 1)
	end
}

ITEM.Actions.DropHalf = {
	Name = "Drop\tDrop Half",
	Priority = ITEM_ACTION_DROP - 2,

	Context = table.Lookup({"RightClick"}),

	CanRun = function(self, ply)
		return hook.Run("CanDropItem", ply, self) and self:GetAmount() > 1
	end,
	Callback = function(self, ply)
		dropAmount(self, ply, math.Round(self:GetAmount() * 0.5))
	end
}

ITEM.Actions.DropAll = {
	Name = "Drop\tDrop All",
	Priority = ITEM_ACTION_DROP - 3,

	Context = table.Lookup({"RightClick"}),

	CanRun = function(self, ply)
		return hook.Run("CanDropItem", ply, self) and self:GetAmount() > 1
	end,
	Callback = drop
}

ITEM.Actions.Move = {
	Hidden = true,

	Validate = function(self, ply, id, amount)
		local inventory = Inventory.Get(id)
		local ok, err = self:CheckMove(ply, inventory, true)

		if not ok then
			return false, err
		end

		amount = math.Round(math.min(amount, self:GetAmount()))

		if inventory:AvailableSpace() < self:GetWeight(amount) then
			return false, inventory.StoreType == INV_PLAYER and "You can't carry any more items!" or "There's no room to fit this item!"
		end

		return true
	end,

	Client = function(self, ply, id)
		local inventory = Inventory.Get(id)
		local space = inventory:AvailableSpace()

		local baseWeight = self:GetWeight(1)

		if space < baseWeight then
			return false, inventory.StoreType == INV_PLAYER and "You can't carry any more items!" or "There's no room to fit this item!"
		end

		local max = math.min(space / baseWeight)

		if max == 1 or self:GetAmount() == 1 then
			return true, id, 1
		end

		return true, id, ui.Open("ItemDropAmount", "Move", self, math.min(max, self:GetAmount()))
	end,
	Callback = function(self, ply, id, amount)
		local inventory = Inventory.Get(id)

		amount = math.Round(math.min(amount, self:GetAmount()))

		if amount == self:GetAmount() then
			self:SetInventory(inventory)
		else
			self:Split(amount):SetInventory(inventory)
		end
	end
}
