local BaseClass = inherit.Get("item", "base")

ITEM.Internal = true

ITEM.Category = "Resource"
ITEM.Customizable = false

ItemDataFunc("Amount", 1)

GM:Include("sh_actions.lua")

function ITEM:GetName()
	local name = BaseClass.GetName(self)
	local amount = self:GetAmount()

	if amount > 1 then
		return string.format("%s x%s", name, amount)
	end

	return name
end

function ITEM:GetWeight(amount)
	return BaseClass.GetWeight(self) * (amount or self:GetAmount())
end

function ITEM:OnAmountChanged(old, new)
	local inventory = self:GetInventory()

	if inventory then
		inventory:RecalculateWeight()
	end
end

if SERVER then
	function ITEM:ProcessArguments(args)
		local amount = math.Round(tonumber(args) or 1)

		if amount > 0 then
			self:SetAmount(amount)
		end
	end

	function ITEM:SetAmount(amount)
		self:SetData("Amount", amount)

		if self:GetAmount() <= 0 then
			self:Delete()
		end
	end

	function ITEM:AddAmount(amount)
		self:SetAmount(self:GetAmount() + amount)
	end

	function ITEM:Split(amount)
		if amount >= self:GetAmount() then
			return self
		end

		self:AddAmount(-amount)

		local item = self:IsTemporaryItem() and Item.CreateTemp(self.ClassName) or Item.Create(self.ClassName)
		item:SetAmount(amount)

		return item
	end
end

-- Slightly different implementation because we might disappear when getting added to an inventory
function ITEM:SetInventory(inventory)
	local receivers

	if SERVER then
		if IsValid(self.Entity) then
			self.Entity.Item = nil
			self.Entity:Remove()
			self.Entity = nil
		end

		receivers = self:GetReceivers()
	end

	if inventory then
		-- Deviating here
		local existing = inventory:FindItem(self.ClassName, self:IsTemporaryItem())

		if existing then
			existing:AddAmount(self:GetAmount())
			self:Delete()

			return
		end
	end

	self:ClearInventory()

	if inventory then
		inventory:AddItem(self)
	end

	if SERVER then
		self:UpdateNetworking(receivers)

		if inventory then
			async.Start(self.SaveLocation, self)
		end
	end

	if inventory then
		self:InventoryAdded(inventory)

		inventory:ItemsChanged()
	end
end
