function ITEM:GetEquipmentSlot()
	return self:GetData("EquipmentSlot", false)
end

function ITEM:GetCompatibleSlots()
	local slots = {}
	local ply = self:GetPlayer()

	if IsValid(ply) then
		local flagSlots = ply:RunCharFlag("EquipmentSlots")

		for _, slot in ipairs(flagSlots) do
			if self.EquipmentLookup[slot] then
				table.insert(slots, slot)
			end
		end
	end

	return slots
end

function ITEM:IsEquipped()
	return tobool(self:GetEquipmentSlot())
end

function ITEM:CheckEquipmentSlot()
	if not table.HasValue(self:GetCompatibleSlots(), self:GetEquipmentSlot()) then
		self:SetEquipmentSlot(nil)
	end
end

if SERVER then
	function ITEM:SetEquipmentSlot(slot)
		local ply = self:GetPlayer()

		if slot then
			local item = ply:GetEquipment(slot)

			if item then
				item:SetEquipmentSlot(nil)
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
			ply:RemoveBuff(buff)
		end
	end
end
