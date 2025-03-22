module("Item", package.seeall)

EphemeralCache = EphemeralCache or {}
TempIndex = TempIndex or 0

local PLAYER = FindMetaTable("Player")
local logger = log.Create("items")

function Create(class, data)
	assert(List[class], "Attempt to create unknown item type: " .. class)

	local query = GAMEMODE.Database:Insert("rp_items")
		query:Insert("Class", class)

		if data then
			query:Insert("CustomData", sfs.encode(data))
		end
	local _, id = query:Execute()

	return Item.Instance(class, id, data)
end

function CreateTemp(class, data)
	assert(List[class], "Attempt to create unknown item type: " .. class)

	TempIndex = TempIndex - 1

	return Item.Instance(class, TempIndex, data)
end

function CreateEphemeral(class, data, pos, ang, time, limit, group)
	group = group or class

	if not EphemeralCache[group] then
		EphemeralCache[group] = {}
	end

	if limit and table.Count(EphemeralCache[group]) >= limit then
		return
	end

	local item = CreateTemp(class, data)
	local ent = item:SetWorldItem(pos, ang)

	ent.Ephemeral = true
	ent.EphemeralGroup = group

	if limit then
		EphemeralCache[group][ent] = true
	end

	ent.ExpireTimer = time and math.ceil(time / 30) or 10 -- 5 minutes by default
	ent.ExpireCounter = 0
end

function LoadWorld()
	local query = GAMEMODE.Database:Select("rp_items")
		query:WhereEqual("StoreType", INV_WORLD)
		query:WhereEqual("StoreID", game.GetMapOverride())

	local i = 0

	for _, data in ipairs(query:Execute()) do
		if not List[data.Class] then
			continue
		end

		local item = Item.Instance(data.Class, data.id, data.CustomData and sfs.decode(data.CustomData) or nil)
		local mapData = sfs.decode(data.MapData)

		i = i + 1

		item:SetWorldItem(mapData.Pos, mapData.Ang, mapData.Frozen)
		item:OnLoaded()
	end

	logger:Info("Loaded %s world items", i)
end

function PLAYER:GiveItem(class, data)
	assert(not self:IsTemporaryCharacter(), "Attempt to give a normal item to a temp character")

	local item = Create(class, data)

	item:SetInventory(self:GetInventory())

	return item
end

function PLAYER:GiveTempItem(class, data)
	local item = CreateTemp(class, data)

	item:SetInventory(self:GetInventory())

	return item
end

function GM:CanPickupItem(ply, item)
	if not item:IsDropped() then
		return false, "You cannot pick up items that aren't on the ground!"
	end

	if ply:IsTemporaryCharacter() and not item:IsTemporaryItem() then
		return false, "You can't pick up normal items as a temporary character!"
	end

	if ply:InventoryWeight() > ply:MaxInventoryWeight() then
		return false, "That's too heavy for you to carry!"
	end

	return true
end
