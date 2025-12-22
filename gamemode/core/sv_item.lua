module("Item", package.seeall)

EphemeralCache = EphemeralCache or {}
TempIndex = TempIndex or 0

local PLAYER = FindMetaTable("Player")
local logger = log.Create("items")

function Create(class, args)
	assert(List[class], "Attempt to create unknown item type: " .. class)

	local _, id = GAMEMODE.Database:Query("INSERT INTO `rp_items` (`Class`, `Created_At`) VALUES (:class, :time)", {
		class = class,
		time = os.time()
	})

	local item = Item.Instance(class, id)
	item:OnCreated()

	if args then
		item:ProcessArguments(args)
	end

	return item
end

function CreateTemp(class, args)
	assert(List[class], "Attempt to create unknown item type: " .. class)

	TempIndex = TempIndex - 1

	local item = Item.Instance(class, TempIndex)
	item:OnCreated()

	if args then
		item:ProcessArguments(args)
	end

	return item
end

function CreateEphemeral(class, data, pos, ang, time, limit, group)
	group = group or class

	if limit then
		if not EphemeralCache[group] then
			EphemeralCache[group] = {}
		end

		if table.Count(EphemeralCache[group]) >= limit then
			return
		end
	end

	local item = CreateTemp(class, data)
	local ent = item:SetWorldItem(pos, ang)

	ent.Ephemeral = true

	if limit then
		ent.EphemeralGroup = group

		EphemeralCache[group][ent] = true
	end

	ent.ExpireTimer = time and math.ceil(time / 30) or 10 -- 5 minutes by default
	ent.ExpireCounter = 0
end

function LoadWorld()
	local query = GAMEMODE.Database:Query("SELECT * FROM `rp_items` WHERE `StoreType` = :storeType AND `StoreID` = :storeId AND `Deleted_At` IS NULL", {
		storeType = INV_WORLD,
		storeId = game.GetMapOverride()
	})

	local i = 0

	for _, data in ipairs(query) do
		if not List[data.Class] then
			continue
		end

		local item = Item.Instance(data.Class, data.id, data.CustomData and sfs.decode(data.CustomData) or nil)
		local mapData = sfs.decode(data.MapData)

		i = i + 1

		item:SetWorldItem(mapData.Pos, mapData.Ang, mapData.Frozen)
		item:Load()
		item:OnLoaded()
	end

	logger:Info("Loaded %s world items", i)
end

function PLAYER:GiveItem(class, args)
	local item = Create(class, args)

	item:SetInventory(self:GetInventory())

	return item
end

function PLAYER:GiveTempItem(class, args)
	local item = CreateTemp(class, args)

	item:SetInventory(self:GetInventory())

	return item
end
