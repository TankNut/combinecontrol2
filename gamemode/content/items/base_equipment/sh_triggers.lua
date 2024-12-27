function ITEM:OnLoaded()
	if self:IsEquipped() then
		self:CheckEquipment()
	end
end

function ITEM:OnRemove()
	if self:IsEquipped() then
		Inventory.Equipment[self:GetOwner()][self:GetEquipmentSlot()] = nil
	end
end

function ITEM:InventoryRemoved(inventory)
	if SERVER and self:IsEquipped() then
		self:SetEquipmentSlot(nil)
	end
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

	self:GetInventory():RecalculateWeight()
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

	self:GetInventory():RecalculateWeight()
end

function ITEM:OnEquipmentSlotChanged(old, new)
	local ply = self:GetOwner()

	if new then
		self:OnEquipped(ply, new)
	else
		self:OnUnequipped(ply)
	end

	if old then Inventory.Equipment[ply][old] = nil end
	if new then Inventory.Equipment[ply][new] = self end
end
