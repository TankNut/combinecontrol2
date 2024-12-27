ITEM.Actions = {}

ITEM.Actions.Equip = {
	Priority = 10,

	CanRun = function(self, ply)
		return hook.Run("CanEquipItem", ply, self) and #self:GetEquipmentSlots() == 1
	end,
	Callback = function(self, ply)
		self:SetEquipmentSlot(self:GetEquipmentSlots()[1])
	end
}

ITEM.Actions.EquipSlot = {
	Priority = 10,

	CanRun = function(self, ply)
		return hook.Run("CanEquipItem", ply, self) and #self:GetEquipmentSlots() > 1
	end,
	SubOptions = function(self, ply)
		local options = {}

		for _, slot in ipairs(self:GetEquipmentSlots()) do
			table.insert(options, {
				Name = "Equip as: " .. EquipmentSlot(slot),
				Value = slot
			})
		end

		return options
	end,
	Callback = function(self, ply, slot)
		if not slot then
			return false, "You need to specify an equipment slot!"
		end

		local ok, err = hook.Run("CanUseEquipmentSlot", ply, self, slot)

		if not ok then
			return false, err
		end

		self:SetEquipmentSlot(slot)
	end
}

ITEM.Actions.Unequip = {
	Categories = {Rightclick = true, InventoryButton = true},
	Priority = 10,

	CanRun = function(self, ply)
		return hook.Run("CanUnequipItem", ply, self)
	end,
	Callback = function(self, ply)
		self:SetEquipmentSlot(nil)
	end
}
