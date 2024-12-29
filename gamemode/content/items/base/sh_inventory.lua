function ITEM:GetInventory()
	if self.InventoryID then
		return Inventory.Get(self.InventoryID)
	end
end

function ITEM:ClearInventory()
	local inventory = self:GetInventory()

	if inventory then
		self:InventoryRemoved(inventory)

		inventory:RemoveItem(self)
	end
end

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

	self:ClearInventory()

	if inventory then
		inventory:AddItem(self)

		self:InventoryAdded(inventory)
	end

	if SERVER then
		self:UpdateNetworking(receivers)

		if inventory then
			async.Start(self.SaveLocation, self)
		end
	end
end

if SERVER then
	function ITEM:SetWorldItem(pos, ang, frozen)
		self:SetInventory(nil)

		local ent = self.Entity

		if not IsValid(self.Entity) then
			ent = ents.Create("cc_item")
			ent:SetModel(self:GetModel())

			--self:SetItemAppearance(ent)

			ent.Item = self
			ent:SetItemName(self:GetName())
			ent:SetItemWeight(self:GetWeight())

			ent:Spawn()
			ent:Activate()

			self.Entity = ent

			self:OnDropped()
		end

		ent:SetPos(pos)
		ent:SetAngles(ang)

		if not frozen then
			ent:PhysWake()
		end

		ent:SaveMoved()
	end
end
