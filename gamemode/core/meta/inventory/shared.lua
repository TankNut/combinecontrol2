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
	else
		self.Listeners = {}
		self.Receivers = {}

		self:LoadItems()
		self:UpdateReceivers()
	end
end

-- Todo: Do we want to separate this into separate functions for the different storage types so we don't get an entity when trying to get a player?
function meta:GetParent()
	if self.StoreType == INV_PLAYER or self.StoreType == INV_STASH or self.StoreType == INV_CONTAINER then
		return Entity(self.Parent)
	elseif self.StoreType == INV_ITEM then
		return Item.Get(self.Parent)
	end
end

function meta:GetMaxWeight()
	if self.StoreType == INV_PLAYER then
		return self:GetParent():MaxInventoryWeight()
	end

	return 0
end

function meta:CanInteract(ply)
	if self.StoreType == INV_PLAYER then
		return self:GetParent() == ply, "You cannot interact with other people's inventories!"
	end

	return false
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
