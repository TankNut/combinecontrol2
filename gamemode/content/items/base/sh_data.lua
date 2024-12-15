function ITEM:GetData(key, fallback)
	if self.Data[key] != nil then
		return self.Data[key]
	end

	return fallback
end

function ITEM:SetData(key, val)
	local old = self.Data[key]
	local hookName = "On" .. key .. "Changed"

	self.Data[key] = val

	if self[hookName] then
		self[hookName](self, old, val)
	end

	if CLIENT then
		self.ReloadTooltip = true

		if self:IsSelected() and IsValid(self.Icon) then
			self.Icon:DoClick()
		end
	else
		async.Start(self.SaveData, self)

		local inventory = self.Inventory

		if inventory and inventory.StoreType == INV_PLAYER then
			netstream.Send(inventory.Entity, "UpdateItemData", self.ID, key, val)
		end
	end
end

function ITEM:GetName() return self:GetData("Name", self.Name) end
function ITEM:GetDescription() return self:GetData("Description", self.Description) end

function ITEM:GetModel() return self:GetData("Model", self.Model) end
function ITEM:GetSkin() return self:GetData("Skin", self.Skin) end

function ITEM:GetWeight()
	local weight = self:GetData("Weight", self.Weight)

	if self:IsEquipped() then
		weight = weight * self:GetData("WeightMultiplier", self.WeightMultiplier)
	end

	return weight
end

function ITEM:GetArmor() return self:GetData("Armor", self.Armor) end

function ITEM:GetRarity()
	return self:GetData("Rarity", self.Rarity)
end

function ITEM:GetRarityData()
	return Item.Rarities[self:GetRarity()] or Item.Rarities[RARITY_COMMON]
end
