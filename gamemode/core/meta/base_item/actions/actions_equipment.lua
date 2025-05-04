local closeMenu = function(self, ply, ...)
	if Settings.Get("EquipTogglesMenu") then
		GUI.Close("PlayerMenu")
	end

	return true, ...
end

local openMenu = function(ply)
	if ply:GetSetting("EquipTogglesMenu") then
		ply:OpenGUI("PlayerMenu")
	end
end

ITEM.Actions.Equip = {
	Priority = ITEM_ACTION_EQUIP,

	Context = table.Lookup({
		"RightClick", "Examine"
	}),

	CanRun = function(self, ply)
		return hook.Run("CanEquipItem", ply, self) and #self:GetCompatibleSlots() == 1
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
		self:SetEquipmentSlot(self:GetCompatibleSlots()[1])
		Log.Write("item_equip", ply, self)
		openMenu(ply)
	end
}

ITEM.Actions.EquipSlot = {
	Name = "Equip as",
	Priority = ITEM_ACTION_EQUIP,

	Context = table.Lookup({
		"RightClick", "Examine"
	}),

	CanRun = function(self, ply)
		return hook.Run("CanEquipItem", ply, self) and #self:GetCompatibleSlots() > 1
	end,
	SubOptions = function(self)
		local options = {}

		for _, slot in ipairs(self:GetCompatibleSlots()) do
			table.insert(options, {
				Name = string.FirstToUpper(EquipmentSlot(slot)),
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
			return false, "You have to specify an equipment slot!"
		end

		return hook.Run("CanUseEquipmentSlot", ply, self, slot)
	end,
	Client = closeMenu,
	Callback = function(self, ply, slot)
		self:SetEquipmentSlot(slot)
		Log.Write("item_equip", ply, self)
		openMenu(ply)
	end
}

ITEM.Actions.Unequip = {
	Priority = ITEM_ACTION_EQUIP,

	Context = table.Lookup({
		"RightClick", "Examine"
	}),

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
		Log.Write("item_unequip", ply, self)
		openMenu(ply)
	end
}
