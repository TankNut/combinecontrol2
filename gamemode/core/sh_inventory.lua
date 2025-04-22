module("Inventory", package.seeall)

All = All or {}
Equipment = Equipment or {}

PlayerVar.Add("InventoryWeight", {Default = 0})
PlayerVar.Add("MaxInventoryWeight", {Default = 0})

PlayerVar.Add("InventoryID", {Default = 0})
PlayerVar.Add("StashID", {Default = 0})

local INVENTORY = CustomMetaTable("Inventory")
local PLAYER = FindMetaTable("Player")

function Create(id, storeType, storeID, parent, items)
	if not id then
		id = #All + 1
	end

	assert(not All[id], "Attempt to instance an already loaded inventory ID: " .. id)

	local instance = setmetatable({
		ID = id,
		StoreType = storeType,
		StoreID = storeID,
		Parent = parent
	}, INVENTORY)

	All[id] = instance

	instance:Initialize()

	if storeType == INV_PLAYER then
		instance:GetPlayer():SetInventoryID(id)
	elseif storeType == INV_STASH then
		instance:GetPlayer():SetStashID(id)
	elseif storeType == INV_ITEM then
		instance:GetItem().Contents = instance
	elseif storeType == INV_ENTITY then
		instance:GetEntity():SetInventoryID(id)
	end

	instance:LoadItems(items)

	if SERVER then
		instance:UpdateReceivers()
	end

	return instance
end

function Init(ply)
	Equipment[ply] = {}
end

function Get(id)
	return All[id]
end

function Clear(ply, removed)
	if SERVER then
		for _, id in ipairs({ply:InventoryID(), ply:StashID()}) do
			local inventory = Get(id)

			if not inventory then
				continue
			end

			inventory:Clear()
		end
	end

	if removed then
		Equipment[ply] = nil
	end
end

if SERVER then
	function Load(ply)
		Clear(ply)

		Create(nil, INV_PLAYER, ply:CharID(), ply:EntIndex())
		Create(nil, INV_STASH, ply:CharID(), ply:EntIndex())
	end

	function Think()
		for _, inv in pairs(All) do
			inv:Think()
		end
	end

	netstream.Hook("ClearInventoryListener", function(ply, id)
		Get(id):RemoveListener(ply)
	end)
end

function PLAYER:GetInventory()
	return Get(self:InventoryID())
end

function PLAYER:GetStash()
	return Get(self:StashID())
end

function PLAYER:GetItems()
	return self:GetInventory().Items
end

function PLAYER:GetEquipment(slot)
	if slot then
		return Equipment[self][slot]
	else
		return Equipment[self]
	end
end

function GM:OnInventoryWeightChanged(ply, old, new, loaded)
	if CLIENT then
		local inventory = ply:GetInventory()

		if inventory then
			inventory:CallPanels("UpdateWeight")
		end
	end
end

function GM:OnMaxInventoryWeightChanged(ply, old, new, loaded)
	if CLIENT then
		local inventory = ply:GetInventory()

		if inventory then
			inventory:CallPanels("UpdateWeight")
		end
	end
end

function GM:CanAccessInventory(ply, inventory)
	-- Sanity check
	if not inventory then
		return false
	end

	local storeType = inventory.StoreType

	if storeType == INV_PLAYER then
		return ply == inventory:GetPlayer()
	elseif storeType == INV_STASH then
		return ply == inventory:GetPlayer() and ply:CanAccessStash()
	elseif storeType == INV_ITEM then
		local item = inventory:GetItem()

		return hook.Run("CanInteractWithItem", ply, item) and item:CanAccessInventory(ply)
	elseif storeType == INV_ENTITY then
		local ent = inventory:GetEntity()

		return ply:WithinInteractRange(ent) and ent:CanAccessInventory(ply)
	end

	return false
end
