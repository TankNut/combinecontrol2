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
	else
		async.Start(self.SaveData, self)

		local inventory = self:GetInventory()

		if inventory and table.Count(inventory.Receivers) > 0 then
			netstream.Send(table.GetKeys(inventory.Receivers), "SetItemData", self.ID, key, val)
		end
	end
end

function ITEM:GetName() return self:GetData("Name", self.Name) end
function ITEM:GetDescription() return self:GetData("Description", self.Description) end

function ITEM:GetModel() return self:GetData("Model", self.Model) end
function ITEM:GetSkin() return self:GetData("Skin", self.Skin) end

function ITEM:GetWeight()
	return self:GetData("Weight", self.Weight)
end

function ITEM:GetArmor() return self:GetData("Armor", self.Armor) end

function ITEM:GetRarity()
	return self:GetData("Rarity", self.Rarity)
end

function ITEM:GetRarityData()
	return Item.Rarities[self:GetRarity()] or Item.Rarities[RARITY_COMMON]
end
