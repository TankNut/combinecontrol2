module("Item", package.seeall)

TempIndex = TempIndex or 0

local meta = FindMetaTable("Player")

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
		item:RemoveFromCurrent()
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

		item:SetDropped(mapData.Pos, mapData.Ang, mapData.Frozen, true)
	end
end

function meta:GiveItem(class, data)
	local item = Create(class, data)

	item:SetInventory(self:GetInventory())
end

netstream.Hook("ItemAction", function(ply, id, name, ...)
	local item = Get(id)

	if not item then
		return
	end

	local action = item:GetActions()[name]

	if action.ServerOnly then
		return
	end

	item:HandleServerAction(ply, name, action, ...)
end)
