local meta = CustomMetaTable("Inventory")

GM:Include("cl_networking.lua")

GM:Include("sh_items.lua")
GM:Include("sh_triggers.lua")

GM:Include("sv_networking.lua")

function meta:Initialize()
	self.Items = {}
	self.Weight = 0

	if CLIENT then
		self.Panels = {}

		if self.StoreType == INV_ITEM then
			self:GetItem().Contents = self
		end
	else
		self.Listeners = {}
		self.Receivers = {}

		self:LoadItems()
		self:UpdateReceivers()
	end
end

function meta:GetPlayer()
	if self.StoreType == INV_PLAYER or self.StoreType == INV_STASH then
		return Entity(self.Parent)
	end
end

function meta:GetItem()
	if self.StoreType == INV_ITEM then
		return Item.Get(self.Parent)
	end
end

function meta:GetEntity()
	if self.StoreType == INV_CONTAINER then
		return Entity(self.Parent)
	end
end

function meta:GetMaxWeight()
	if self.StoreType == INV_PLAYER then
		return self:GetPlayer():MaxInventoryWeight()
	elseif self.StoreType == INV_ITEM then
		return self:GetItem():GetMaxWeight()
	end

	return 0
end

function meta:Remove()
	self:OnRemove()

	Inventory.All[self.ID] = nil
end

if CLIENT then
	function meta:CallPanels(func, ...)
		for panel in pairs(self.Panels) do
			panel[func](panel, ...)
		end
	end
end
