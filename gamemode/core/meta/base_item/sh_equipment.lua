function ITEM:GetEquipmentSlot()
	return self:GetData("EquipmentSlot", false)
end

function ITEM:GetEquipmentSlots()
	local slots = {}
	local flagSlots = self:GetPlayer():RunCharFlag("EquipmentSlots")

	for _, slot in ipairs(flagSlots) do
		if self.EquipmentLookup[slot] then
			table.insert(slots, slot)
		end
	end

	return slots
end

function ITEM:IsEquipped()
	return tobool(self:GetEquipmentSlot())
end

function ITEM:CheckEquipment()
	local slot = self:GetEquipmentSlot()

	if not table.HasValue(self:GetEquipmentSlots(), slot) then
		self:SetEquipmentSlot(nil)

		return
	end

	Inventory.Equipment[self:GetPlayer()][slot] = self

	return true
end

if SERVER then
	function ITEM:SetEquipmentSlot(slot)
		local ply = self:GetPlayer()

		if slot then
			local item = ply:GetEquipment(slot)

			if item then
				item:SetEquipmentSlot(ply, nil)
			end
		end

		self:SetData("EquipmentSlot", slot)
	end

	function ITEM:AddBuffs()
		local ply = self:GetPlayer()

		for _, buff in ipairs(self.Buffs) do
			ply:AddBuff(buff)
		end
	end

	function ITEM:RemoveBuffs()
		local ply = self:GetPlayer()

		for _, buff in ipairs(self.Buffs) do
			ply:RemoveBuff(buff, 1)
		end
	end
end
