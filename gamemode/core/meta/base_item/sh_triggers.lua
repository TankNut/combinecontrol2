function ITEM:Load()
	if self:IsEquipped() then
		Inventory.Equipment[self:GetPlayer()][self:GetEquipmentSlot()] = self

		if SERVER then
			self:AddBuffs()
		end
	end
end

function ITEM:OnLoaded()
	if SERVER and self:IsEquipped() then
		self:CheckEquipmentSlot()
	end
end

function ITEM:OnRemove()
	local ply = self:GetPlayer()

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

-- Added to an inventory, called after it happens
function ITEM:InventoryAdded(inventory)
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

function ITEM:OnUnequipped(ply)
	if SERVER then
		if self.GetModelData or self.PostModelData then
			ply:UpdateAppearance()
		end

		if self.Armor > 0 then
			ply:UpdateArmor()
		end

		self:RemoveBuffs()
	end

	self:GetInventory():RecalculateWeight()
end

function ITEM:OnEquipmentSlotChanged(old, new)
	local ply = self:GetPlayer()

	if new then
		self:OnEquipped(ply, new)
	else
		self:OnUnequipped(ply)
	end

	if old then Inventory.Equipment[ply][old] = nil end
	if new then Inventory.Equipment[ply][new] = self end
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

		local ply = self:GetPlayer()

		for _, buff in ipairs(old) do
			ply:RemoveBuff(buff, 1)
		end

		for _, buff in ipairs(new) do
			ply:AddBuff(buff)
		end
	end
end
