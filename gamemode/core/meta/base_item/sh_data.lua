local logger = log.Create("items")

function ITEM:GetData(key, fallback)
	if self.Data[key] != nil then
		return self.Data[key]
	end

	return fallback
end

function ITEM:SetData(key, val)
	local old = self.Data[key]
	local hookName = "On" .. key .. "Changed"

	logger:Debug("Data: %s -> [%s] = '%s'", self, key, val)

	self.Data[key] = val

	if self[hookName] then
		self[hookName](self, old, val)
	end

	if CLIENT then
		self.Tooltip = nil
		self:TriggerPanelUpdate()
	else
		async.Start(self.SaveData, self)

		local inventory = self:GetInventory()

		if inventory and table.Count(inventory.Receivers) > 0 then
			netstream.Send(inventory.Receivers, "ItemData", self.ID, key, val)
		end
	end
end

function ITEM:GetName() return self:GetData("Name", self.Name) end
function ITEM:GetDescription()
	local description = {self:GetData("Description", self.Description), "<reset>"}

	if self:IsEquipped() then
		table.insert(description, string.format("\n\n<col=lime>Equipped as %s</col>", EquipmentSlot(self:GetEquipmentSlot())))
	end

	return table.concat(description)
end

function ITEM:GetRarity() return self:GetData("Rarity", self.Rarity) end
function ITEM:GetRarityData() return Item.Rarities[self:GetRarity()] end

function ITEM:GetWeight()
	local weight = self:GetData("Weight", self.Weight)

	if self:IsEquipped() then
		weight = weight * self:GetData("WeightMultiplier", self.WeightMultiplier)
	end

	return weight
end

function ITEM:GetArmor()
	return self:IsEquipped() and self.Armor or 0
end

function ITEM:GetCategory() return self:GetData("Category", self.Category) end
function ITEM:GetTags()
	local tags = {self:GetRarityData().Name, self:GetCategory()}

	for _, tag in ipairs(self:GetData("Tags", self.Tags)) do
		table.insert(tags, tag)
	end

	return tags
end

if CLIENT then
	function ITEM:GetIconCamera()
		return Angle(self:GetData("IconAngle", self.IconAngle)), self:GetData("IconFOV", self.IconFOV)
	end
else
	function ITEM:GetBuffs()
		return self:GetData("Buffs", self.Buffs)
	end
end

function ITEM:GetEquipTime()
	return self:GetData("EquipTime", self.EquipTime)
end

function ITEM:GetUnequipTime()
	return self:GetData("UnequipTime", self.UnequipTime)
end
