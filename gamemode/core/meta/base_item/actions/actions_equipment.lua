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
	Validate = function(self, ply, slot)
		if not slot then
			return false, "You need to specify an equipment slot!"
		end

		return hook.Run("CanUseEquipmentSlot", ply, self, slot)
	end,
	Callback = function(self, ply, slot)
		self:SetEquipmentSlot(slot)
	end
}

ITEM.Actions.Unequip = {
	Priority = 10,

	CanRun = function(self, ply)
		return hook.Run("CanUnequipItem", ply, self)
	end,
	Callback = function(self, ply)
		self:SetEquipmentSlot(nil)
	end
}
