module("Item", package.seeall)

TempIndex = TempIndex or 0

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

function Delete(id)
	local item = All[id]

	if item then
		item:RemoveFromInventory()
	end

	async.Start(function()
		local query = GAMEMODE.Database:Delete("rp_items")
			query:WhereEqual("id", id)
		query:Execute()
	end)
end

function LoadWorld()
	local query = GAMEMODE.Database:Select("rp_items")
		query:WhereEqual("StoreType", INV_WORLD)
		query:WhereEqual("StoreID", game.GetMap())

	for _, data in ipairs(query:Execute()) do
		local item = Item.Instance(data.Class, data.id, data.CustomData and sfs.decode(data.CustomData) or nil)
		local mapData = sfs.decode(data.MapData)

		item:Drop(mapData.Pos, mapData.Ang, mapData.Frozen, true)
	end
end

function GM:CanTakeItem(ply, item)
	if ply:IsTemporaryCharacter() and not item:IsTemporaryItem() then
		return false, "You cannot pick up normal items as a temporary character!"
	end

	if ply:InventoryWeight() + item:GetWeight() > ply:MaxInventoryWeight() then
		return false, "You don't have any space left in your inventory!"
	end

	return true
end
