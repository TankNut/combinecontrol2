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

function INVENTORY:GetPlayer()
	if self.StoreType == INV_PLAYER or self.StoreType == INV_STASH then
		return Entity(self.Parent)
	end
end

function INVENTORY:GetItem()
	if self.StoreType == INV_ITEM then
		return Item.Get(self.Parent)
	end
end

function INVENTORY:GetEntity()
	if self.StoreType == INV_ENTITY then
		return Entity(self.Parent)
	end
end

function INVENTORY:GetMaxWeight()
	if self.StoreType == INV_PLAYER then
		return self:GetPlayer():MaxInventoryWeight()
	elseif self.StoreType == INV_ITEM then
		return self:GetItem():GetMaxWeight()
	end

	return 0
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

	function INVENTORY:Clear()
		self:Remove()
	end
end
