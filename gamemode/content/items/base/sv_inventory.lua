function ITEM:IsDropped()
	return IsValid(self.Entity)
end

function ITEM:RemoveFromCurrent(keepEntity)
	if not keepEntity and IsValid(self.Entity) then
		self.Entity.Item = nil
		self.Entity:Remove()
		self.Entity = nil
	end

	local inventory = self.Inventory

	if inventory then
		inventory:ItemRemoved(self)
	end

	self.Inventory = nil

	return inventory
end

function ITEM:MoveTo(inventory, loaded)
	local old = self:RemoveFromCurrent()

	inventory:ItemAdded(self, loaded)

	self.Inventory = inventory
	self:OnMove(old, inventory, loaded)

	if not loaded then
		async.Start(self.SaveLocation, self)
	end
end

function ITEM:Drop(pos, ang, frozen, loaded)
	local old = self:RemoveFromCurrent(true)

	self:OnMove(old, nil)

	local ent = IsValid(self.Entity) and self.Entity or ents.Create("cc_item")

	ent:SetPos(pos)
	ent:SetAngles(ang)

	if not IsValid(self.Entity) then
		self:SetItemAppearance(ent)

		ent.Item = self
		ent:SetItemName(self:GetData("Name", self.Name))
		ent:SetItemWeight(self:GetWeight())

		ent:Spawn()
		ent:Activate()

		self.Entity = ent
	end

	if not frozen then
		ent:PhysWake()
	end

	ent:SaveMoved()

	if not loaded then
		async.Start(self.SaveLocation, self)
	end
end

function ITEM:Cleanup()
end

function ITEM:OnMove(old, new, loaded)
end
