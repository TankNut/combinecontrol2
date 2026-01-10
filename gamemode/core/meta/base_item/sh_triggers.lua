function ITEM:Load()
	if self:IsEquipped() then
		Inventory.Equipment[self:GetParent()][self:GetEquipmentSlot()] = self
	end
end

function ITEM:OnLoaded()
	if SERVER and self:IsEquipped() then
		self:AddBuffs()
	end
end

function ITEM:OnRemove()
	local ply = self:GetParent()

	if self:IsEquipped() and IsValid(ply) then
		Inventory.Equipment[ply][self:GetEquipmentSlot()] = nil

		if SERVER then
			self:RemoveBuffs()
		end
	end

	if CLIENT then
		self:RemovePanels()
	end
end

function ITEM:OnReloaded()
end

if SERVER then
	function ITEM:OnDelete()
	end
end

function ITEM:OnDropped()
end

-- Removed from an inventory, called before it actually happens
function ITEM:InventoryRemoved(inventory)
	if SERVER and self:IsEquipped() then
		self:SetEquipmentSlot(nil)
	end
end

-- Removed from an inventory, called after it happens
function ITEM:PostInventoryRemoved(inventory)
	if SERVER and inventory.StoreType == INV_PLAYER and (self.GetModelData or self.PostModelData) then
		inventory:GetParent():UpdateAppearance()
	end
end

-- Added to an inventory, called after it happens
function ITEM:InventoryAdded(inventory)
	if SERVER and inventory.StoreType == INV_PLAYER and (self.GetModelData or self.PostModelData) then
		inventory:GetParent():UpdateAppearance()
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

		self:AddBuffs()
	end

	self:GetInventory():RecalculateWeight()
end

function ITEM:OnUnequipped(ply, replacement)
	if SERVER then
		if self:HasModelData() and (not replacement or not replacement:HasModelData()) then
			ply:UpdateAppearance()
		end

		if self.Armor > 0 then
			ply:UpdateArmor()
		end

		self:RemoveBuffs()
	end

	if not replacement then
		self:GetInventory():RecalculateWeight()
	end
end

function ITEM:OnEquipmentSlotChanged(old, new)
	local ply = self:GetParent()

	if old then
		Inventory.Equipment[ply][old] = nil

		if CLIENT then
			self:OnUnequipped(ply)
		end
	end

	if new then
		Inventory.Equipment[ply][new] = self

		if CLIENT then
			self:OnEquipped(ply, new)
		end
	end
end

function ITEM:OnWeightChanged(old, new)
	local inventory = self:GetInventory()

	if inventory then
		inventory:RecalculateWeight()
	end
end

function ITEM:OnWeightMultiplierChanged(old, new)
	local inventory = self:GetInventory()

	if inventory and self:IsEquipped() then
		inventory:RecalculateWeight()
	end
end

if SERVER then
	function ITEM:OnBuffsChanged(old, new)
		if not self:IsEquipped() then
			return
		end

		local ply = self:GetParent()

		for _, buff in ipairs(old) do
			ply:RemoveBuff(buff)
		end

		for _, buff in ipairs(new) do
			ply:AddBuff(buff)
		end
	end
end
