module("Inventory", package.seeall)

All = All or {}
Equipment = Equipment or {}

PlayerVar.Add("InventoryWeight", {Default = 0})
PlayerVar.Add("MaxInventoryWeight", {Default = 0})

PlayerVar.Add("InventoryID", {Default = 0})
PlayerVar.Add("StashID", {Default = 0})

local INVENTORY = CustomMetaTable("Inventory")
local PLAYER = FindMetaTable("Player")

function Create(id, storeType, storeID, parentID, items)
	if not id then
		id = #All + 1
	end

	assert(not All[id], "Attempt to instance an already loaded inventory ID: " .. id)

	local instance = setmetatable({
		ID = id,
		StoreType = storeType,
		StoreID = storeID,
		Parent = parentID
	}, INVENTORY)

	All[id] = instance

	instance:Initialize()

	local parent = instance:GetParent()

	if storeType == INV_PLAYER then
		parent:SetInventoryID(id)
	elseif storeType == INV_STASH then
		parent:SetStashID(id)
	elseif storeType == INV_ITEM then
		parent.Contents = instance
	elseif storeType == INV_ENTITY then
		parent:SetInventoryID(id)
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

			inventory:Remove()
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
