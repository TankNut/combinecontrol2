local closeMenu = function(self, ply, ...)
	if Settings.Get("EquipTogglesMenu") then
		GUI.Close("PlayerMenu")
	end

	return ...
end

local openMenu = function(ply)
	if ply:GetSetting("EquipTogglesMenu") then
		ply:OpenGUI("PlayerMenu")
	end
end

ITEM.Actions.Equip = {
	Priority = 10,

	CanRun = function(self, ply)
		return hook.Run("CanEquipItem", ply, self) and #self:GetEquipmentSlots() == 1
	end,
	Progress = function(self, ply)
		return {
			Name = string.format("Equipping %s...", self:GetName()),
			EndTime = CurTime() + self:GetEquipTime(),
			Validate = {progress.Player(ply, {Alive = true})},
			Callback = CLIENT and stub or nil
		}
	end,
	Client = closeMenu,
	Callback = function(self, ply)
		self:SetEquipmentSlot(self:GetEquipmentSlots()[1])
		openMenu(ply)
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
	Progress = function(self, ply)
		return {
			Name = string.format("Equipping %s...", self:GetName()),
			EndTime = CurTime() + self:GetEquipTime(),
			Validate = {progress.Player(ply, {Alive = true})},
			Callback = CLIENT and stub or nil
		}
	end,
	Validate = function(self, ply, slot)
		if not slot then
			return false, "You need to specify an equipment slot!"
		end

		return hook.Run("CanUseEquipmentSlot", ply, self, slot)
	end,
	Client = closeMenu,
	Callback = function(self, ply, slot)
		self:SetEquipmentSlot(slot)
		openMenu(ply)
	end
}

ITEM.Actions.Unequip = {
	Priority = 10,

	CanRun = function(self, ply)
		return hook.Run("CanUnequipItem", ply, self)
	end,
	Progress = function(self, ply)
		return {
			Name = string.format("Unequipping %s...", self:GetName()),
			EndTime = CurTime() + self:GetUnequipTime(),
			Validate = {progress.Player(ply, {Alive = true})},
			Callback = CLIENT and stub or nil
		}
	end,
	Client = closeMenu,
	Callback = function(self, ply)
		self:SetEquipmentSlot(nil)
		openMenu(ply)
	end
}
