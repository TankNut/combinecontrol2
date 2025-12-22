local INVENTORY = CustomMetaTable("Inventory")

GM:Include("cl_networking.lua")

GM:Include("sh_find.lua")

GM:Include("sh_items.lua")
GM:Include("sh_triggers.lua")

GM:Include("sv_networking.lua")

function INVENTORY:Initialize()
	self.Items = {}
	self.Weight = 0

	if CLIENT then
		self.Panels = {}
	else
		self.Listeners = {}
		self.Receivers = {}
	end
end

function INVENTORY:GetParent()
	if self.StoreType == INV_PLAYER or self.StoreType == INV_STASH or self.StoreType == INV_ENTITY then
		return Entity(self.Parent)
	elseif self.StoreType == INV_ITEM then
		return Item.Get(self.Parent)
	end
end

function INVENTORY:CanAccess(ply)
	local storeType = self.StoreType
	local parent = self:GetParent()

	if storeType == INV_PLAYER then
		return ply == parent, "You cannot access another player's inventory!"
	elseif storeType == INV_STASH then
		if ply != parent then
			return false, "You cannot access another player's stash!"
		end

		return ply:CanAccessStash()
	elseif storeType == INV_ITEM then
		local ok, err = parent:CanInteract(ply)

		if not ok then
			return ok, err
		end

		return parent:CanAccessInventory(ply)
	elseif storeType == INV_ENTITY then
		if not ply:WithinInteractRange(parent) then
			return false, "You're too far away!"
		end

		return parent:CanAccessInventory(ply)
	end

	return false
end

function INVENTORY:CanAccept(item, noWeightCheck)
	if not noWeightCheck and item:GetWeight() > self:AvailableSpace() then
		return false, self.StoreType == INV_PLAYER and "You can't carry any more items!" or "There's no room to fit this item!"
	end

	return true
end

function INVENTORY:GetMaxWeight()
	if self.StoreType == INV_PLAYER then
		return self:GetParent():MaxInventoryWeight()
	elseif self.StoreType == INV_ITEM then
		return self:GetParent():GetMaxWeight()
	end

	return 0
end

function INVENTORY:AvailableSpace()
	local max = self:GetMaxWeight()

	-- Players can freely cross their max so we just pretend their threshold is infinite until then
	if max == 0 or (self.StoreType == INV_PLAYER and self.Weight < max) then
		return math.huge
	end

	return max - self.Weight
end

function INVENTORY:Remove()
	self:OnRemove()

	Inventory.All[self.ID] = nil
end

if CLIENT then
	function INVENTORY:CallPanels(func, ...)
		for panel in pairs(self.Panels) do
			panel[func](panel, ...)
		end
	end
else
	function INVENTORY:Think()
		self:UpdateListeners()
	end
end
