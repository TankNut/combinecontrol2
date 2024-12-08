ITEM.Actions.Equip = {
	Categories = {Rightclick = true, InventoryButton = true},
	Priority = 10,

	SubOptions = function(self, ply)
		local options = {}

		for _, slot in ipairs(self:GetAvailableEquipmentSlots(ply)) do
			table.insert(options, {
				Name = "Equip as: " .. EquipmentSlot(slot),
				Value = slot
			})
		end

		return options
	end,
	IsAvailable = function(self, ply)
		return hook.Run("CanEquipItem", ply, self)
	end,
	Validate = function(self, ply, slot)
		if not slot then
			return false, "You need to specify an equipment slot!"
		end

		return hook.Run("CanEquipItem", ply, self, slot)
	end,
	Callback = function(self, ply, slot)
		self:SetEquipmentSlot(ply, slot)
	end
}

ITEM.Actions.Unequip = {
	Categories = {Rightclick = true, InventoryButton = true},
	Priority = 10,

	IsAvailable = function(self, ply)
		return hook.Run("CanUnequipItem", ply, self)
	end,
	Validate = function(self, ply)
		return hook.Run("CanUnequipItem", ply, self)
	end,
	Callback = function(self, ply)
		self:SetEquipmentSlot(ply, nil)
	end
}

function ITEM:GetAvailableEquipmentSlots(ply)
	local slots = {}
	local flagSlots = ply:RunCharFlag("EquipmentSlots")

	for _, slot in ipairs(flagSlots) do
		if table.HasValue(self.EquipmentSlots, slot) then
			table.insert(slots, slot)
		end
	end

	return slots
end

function ITEM:GetEquipmentSlot()
	return self:GetData("EquipmentSlot", false)
end

function ITEM:SetEquipmentSlot(ply, slot)
	if slot then
		local conflicts = ply:RunCharFlag("EquipmentConflicts")

		if conflicts[slot] then
			for _, v in pairs(conflicts[slot]) do
				local item = ply:GetEquipment(v)

				if item then
					item:SetEquipmentSlot(ply, nil)
				end
			end
		end

		local item = ply:GetEquipment(slot)

		if item then
			item:SetEquipmentSlot(ply, nil)
		end
	end

	self:SetData("EquipmentSlot", slot)

	if slot then
		self:OnEquipped(ply, slot)
	else
		self:OnUnequipped(ply)
	end
end

function ITEM:IsEquipped()
	return tobool(self:GetEquipmentSlot())
end

function ITEM:OnEquipped(ply, slot)
	if SERVER then
		if self.GetModelData or self.PostModelData then
			ply:UpdateAppearance()
		end

		if self.Armor > 0 then
			ply:UpdateArmor()
		end
	end
end

function ITEM:OnUnequipped(ply)
	if SERVER then
		if self.GetModelData or self.PostModelData then
			ply:UpdateAppearance()
		end

		if self.Armor > 0 then
			ply:UpdateArmor()
		end
	end
end

function ITEM:CanEquip(ply, slot)
	return true
end

function ITEM:CanUnequip(ply)
	return true
end

if CLIENT then
	function ITEM:OnEquipmentSlotChanged(old, new)
		if not self:IsOwner(lp) then
			return
		end

		if new then
			self:OnEquipped(lp, new)
		else
			self:OnUnequipped(lp)
		end
	end
end
