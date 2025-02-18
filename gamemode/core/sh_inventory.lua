module("Inventory", package.seeall)

All = All or {}
Equipment = Equipment or {}

PlayerVar.Add("InventoryWeight", {Default = 0})
PlayerVar.Add("MaxInventoryWeight", {Default = 0})

PlayerVar.Add("InventoryID", {Default = 0})
PlayerVar.Add("StashID", {Default = 0})

local INVENTORY = CustomMetaTable("Inventory")
local PLAYER = FindMetaTable("Player")

function Create(id, storeType, storeID, parent)
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

			if inventory:IsTempInventory() then
				-- Stop sending to the player
				inventory:UpdateReceivers()
			else
				inventory:Remove()
			end
		end
	end

	if removed then
		Equipment[ply] = nil
	end
end

if SERVER then
	function Load(ply)
		Clear(ply)

		ply:SetInventoryID(Create(nil, INV_PLAYER, ply:CharID(), ply:EntIndex()).ID)
		ply:SetStashID(Create(nil, INV_STASH, ply:CharID(), ply:EntIndex()).ID)
	end

	function LoadTemp(ply)
		Clear(ply)

		local data = Character.TempData[-ply:CharID()]
		local inv, stash

		if data.Inventory then
			inv = data.Inventory; Get(inv):UpdateReceivers()
			stash = data.Stash; Get(stash):UpdateReceivers()
		else
			inv = Create(nil, INV_PLAYER, ply:CharID(), ply:EntIndex()).ID
			stash = Create(nil, INV_STASH, ply:CharID(), ply:EntIndex()).ID
		end

		data.Inventory = inv
		data.Stash = stash

		ply:SetInventoryID(inv)
		ply:SetStashID(stash)
	end
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
