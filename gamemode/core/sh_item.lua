module("Item", package.seeall)

List = List or {}
Spawnable = Spawnable or {}

All = All or {}

-- Deliberate, we want to clear this every autorefresh
ActionCache = {}

Rarities = {
	[RARITY_COMMON] = {Name = "Common", Color = Color(200, 200, 200):Register({"rarity_common", "rarity_1"})},
	[RARITY_UNCOMMON] = {Name = "Uncommon", Color = Color(30, 255, 0):Register({"rarity_uncommon", "rarity_2"})},
	[RARITY_RARE] = {Name = "Rare", Color = Color(0, 112, 221):Register({"rarity_rare", "rarity_3"})},
	[RARITY_EPIC] = {Name = "Epic", Color = Color(163, 53, 238):Register({"rarity_epic", "rarity_4"})},
	[RARITY_LEGENDARY] = {Name = "Legendary", Color = Color(255, 128, 0):Register({"rarity_legendary", "rarity_5"})},
	[RARITY_ARTIFACT] = {Name = "Artifact", Color = Color(255, 50, 50):Register({"rarity_artifact", "rarity_6"})},
	[RARITY_DEVELOPER] = {Name = "Developer", Color = Color(0, 204, 255):Register({"rarity_developer", "rarity_7"})}
}

local PLAYER = FindMetaTable("Player")
local logger = log.Create("items")

function Register(name, item)
	item.Name = item.Name or name

	logger:Info("Registered: %s%s", name, item.Base and " : " .. item.Base or "")

	-- Done to prevent the var from getting inherited
	local internal = item.Internal; item.Internal = nil

	List[name] = inherit.Register("item", name, item, item.Base or "base")

	if not internal then
		Spawnable[name] = List[name]
	end
end

function RegisterFolder(dir)
	file.Iterate(dir, "shared.lua", "LUA", function(path, folder)
		local name = string.FileName(path)

		if name == "shared" then
			name = string.FileName(folder)
		end

		_G.ITEM = {}

		GM:IncludeShared(path)

		Register(string.gsub(name, "^item_", ""), ITEM)

		ITEM = nil
	end)
end

function OnReloaded()
	for _, item in pairs(All) do
		item:OnReloaded()
	end
end

function Instance(class, id, data)
	class = assert(List[class], "Attempt to instance unknown item type: " .. class)

	if All[id] then
		logger:Warning("Tried to instance already loaded item: %s", All[id])

		return All[id]
	end

	local instance = setmetatable({
		ID = id,
		Data = data or {}
	}, {
		__index = class,
		__tostring = function(self) return string.format("Item [%s][%s]", self.ID, self.ClassName) end
	})

	logger:Debug("Instance: %s", instance)

	All[id] = instance

	instance:Initialize()

	return instance
end

function Get(id)
	return All[id]
end

local function checkName(item, name)
	if not name then
		return true
	end

	if item == name then
		-- Direct match
		return true, true
	end

	name = string.lower(name)

	if string.find(item.ClassName, name, 1, true) then
		return true
	end

	local rarity = Rarities[item.Rarity]

	for _, tag in ipairs(table.Add({rarity.Name, item.Category}, item.Tags)) do
		if string.find(string.lower(tag), name, 1, true) then
			return true
		end
	end

	return false
end

function Find(ply, name)
	local items = {}

	for class, item in SortedPairs(Spawnable) do
		local ok, match = checkName(item, name)

		if not ok then
			continue
		end

		if match then
			return {[class] = item}
		end

		if hook.Run("CanSpawnItem", ply, item) then
			items[class] = item
		end
	end

	return items
end

function GetDropPosition(ply)
	local tr = util.TraceLine({
		start = ply:GetShootPos(),
		endpos = ply:GetShootPos() + ply:GetAimVector() * 50,
		filter = ply
	})

	return tr.HitPos + tr.HitNormal * 10
end

function PLAYER:HasEquipmentSlot(slot)
	return table.HasValue(self:RunCharFlag("EquipmentSlots"), slot)
end

function GM:CanSpawnItem(ply, itemClass)
	if itemClass.Rarity == RARITY_DEVELOPER and not ply:IsDeveloper() then
		return false
	end

	return true
end

function GM:CanInteractWithItem(ply, item)
	if not ply:CanAct() then
		return false, "You cannot do this right now!"
	end

	if item:GetStoreType() == INV_PLAYER and item:GetPlayer() == ply then
		return true
	end

	return false, "You can only interact with items in your own inventory!"
end

function GM:CanDropItem(ply, item)
	local ok, err = hook.Run("CanInteractWithItem", ply, item)

	if not ok then
		return false, err
	end

	return item:CanDrop(ply)
end

function GM:CanDestroyItem(ply, item)
	local ok, err = hook.Run("CanInteractWithItem", ply, item)

	if not ok then
		return false, err
	end

	return item:CanDestroy(ply)
end

function GM:CanEquipItem(ply, item)
	local ok, err = hook.Run("CanInteractWithItem", ply, item)

	if not ok then
		return false, err
	end

	if item:IsEquipped() then
		return false, "This item is already equipped!"
	end

	if #item:GetEquipmentSlots() < 1 then
		return false, "You don't have any equipment slots to put this in!"
	end

	return item:CanEquip(ply)
end

function GM:CanUseEquipmentSlot(ply, slot)
	if not ply:HasEquipmentSlot(slot) then
		return false, "Your character doesn't support that equipment slot!"
	end

	local item = ply:GetEquipment(slot)

	if item and not hook.Run("CanUnequipItem", ply, item) then
		return false, "You cannot equip this because of your " .. item:GetName() .. "!"
	end

	return true
end

function GM:CanUnequipItem(ply, item)
	local ok, err = hook.Run("CanInteractWithItem", ply, item)

	if not ok then
		return false, err
	end

	if not item:IsEquipped() then
		return false, "This item isn't equipped!"
	end

	return item:CanUnequip(ply)
end

function GM:CanOpenItemContainer(ply, item)
	local ok, err = hook.Run("CanInteractWithItem", ply, item)

	if not ok then
		return false, err
	end

	return item:CanSearchContents(ply)
end

function GM:CanTakeItem(ply, item)
	local storeType = item:GetStoreType()

	if storeType == INV_ITEM then
		return hook.Run("CanOpenItemContainer", ply, item:GetItem())
	end

	return false, "You cannot take this item!"
end

function GM:CanStoreItem(ply, item, inventory)
	if inventory.StoreType == INV_ITEM then
		local container = inventory:GetItem()

		if container == item then
			return false, "You cannot store an item inside of itself!"
		end

		if container:IsTemporaryItem() and not item:IsTemporaryItem() then
			return false, "You cannot store non-temporary items in this!"
		end

		local ok, err = hook.Run("CanOpenItemContainer", ply, container)

		if not ok then
			return false, err
		end
	end

	return item:CanStore(ply, inventory)
end
