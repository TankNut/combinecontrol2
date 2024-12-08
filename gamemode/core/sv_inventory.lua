module("Inventory", package.seeall)

List = List or {}
Equipment = Equipment or {}

local meta = CustomMetaTable("Inventory")
local pmeta = FindMetaTable("Player")

function Create(storeType, storeID, ent)
	local instance = setmetatable({
		Items = {},
		StoreType = storeType,
		StoreID = storeID,
		Weight = 0,
		Entity = ent
	}, meta)

	instance:LoadItems()

	return instance
end

function Init(ply)
	List[ply] = {}
	Equipment[ply] = {}
end

function Clear(ply)
	for _, inv in pairs(List[ply]) do
		inv:Cleanup()
	end

	List[ply] = nil
	Equipment[ply] = nil
end

function Load(ply)
	for _, inv in pairs(List[ply]) do
		inv:Cleanup()
	end

	table.Empty(Equipment[ply])

	List[ply] = {
		Main = Create(INV_PLAYER, ply:CharID(), ply),
		Stash = Create(INV_STASH, ply:CharID(), ply)
	}
end

function pmeta:GetInventory()
	return List[self].Main
end

function pmeta:GetStash()
	return List[self].Stash
end

function pmeta:GetItems()
	return Inventory.List[self].Main.Items
end

function pmeta:GetEquipment(slot)
	if slot then
		return Equipment[self][slot]
	else
		return Equipment[self]
	end
end

function meta:LoadItems()
	local query = GAMEMODE.Database:Select("rp_items")
		query:WhereEqual("StoreType", self.StoreType)
		query:WhereEqual("StoreID", self.StoreID)

	for _, data in ipairs(query:Execute()) do
		if not Item.List[data.Class] then
			continue
		end

		local item = Item.Instance(data.Class, data.id, data.CustomData and sfs.decode(data.CustomData) or nil)

		item:SetInventory(self, true)
	end
end

function meta:Cleanup()
	for _, item in pairs(self.Items) do
		item:Cleanup()
	end
end

function meta:ItemRemoved(item)
	self.Items[item.ID] = nil

	if self.StoreType == INV_PLAYER then
		netstream.Send(self.Entity, "RemoveItem", item.ID)
	end

	self:RecalculateWeight()
end

function meta:ItemAdded(item, loaded)
	self.Items[item.ID] = item

	if self.StoreType == INV_PLAYER then
		netstream.Send(self.Entity, "AddItem", item.ClassName, item.ID, item.Data)
	end

	self:RecalculateWeight()
end

function meta:RecalculateWeight()
	local weight = 0

	for _, item in pairs(self.Items) do
		weight = weight + item:GetWeight()
	end

	self.Weight = weight

	if self.StoreType == INV_PLAYER then
		self.Entity:SetInventoryWeight(weight)
	end
end
