module("Item", package.seeall)

List = List or {}
Spawnable = Spawnable or {}

All = All or {}

-- Deliberate, we want to clear this every autorefresh
ActionCache = {}

Rarities = {
	[RARITY_COMMON] = {Name = "Common"},
	[RARITY_UNCOMMON] = {Name = "Uncommon", Color = Color(30, 255, 0)},
	[RARITY_RARE] = {Name = "Rare", Color = Color(0, 112, 221)},
	[RARITY_EPIC] = {Name = "Epic", Color = Color(163, 53, 238)},
	[RARITY_LEGENDARY] = {Name = "Legendary", Color = Color(255, 128, 0)},
	[RARITY_ARTIFACT] = {Name = "Artifact", Color = Color(255, 50, 50)},
	[RARITY_DEV] = {Name = "Developer", Color = Color(0, 204, 255)}
}

local meta = FindMetaTable("Player")

function Register(name, item)
	item.ClassName = name
	item.ThisClass = "item_" .. name
	item.Name = item.Name or name

	-- Done to prevent the var from getting inherited
	local internal = item.Internal; item.Internal = nil

	if name != "base" then
		setmetatable(item, {
			__index = baseclass.Get(item.Base and "item_" .. item.Base or "item_base"),
		})
	end

	baseclass.Set(item.ThisClass, item)

	List[name] = baseclass.Get(item.ThisClass)

	if not internal then
		Spawnable[name] = baseclass.Get(item.ThisClass)
	end
end

function RegisterFile(path)
	_G.ITEM = {}

	GM:Include(path)

	Register(string.gsub(string.FileName(path), "^item_", ""), ITEM)

	ITEM = nil
end

function RegisterFolder(basePath)
	local function load(path)
		local files, folders = file.Find(path .. "*", "LUA")

		for _, v in ipairs(files) do
			local filePath = path .. v

			if string.GetExtensionFromFilename(filePath) != "lua" then
				continue
			end

			RegisterFile(filePath)
		end

		for _, v in ipairs(folders) do
			local folderPath = path .. v
			local filePath = folderPath .. "/shared.lua"

			if file.Exists(filePath, "LUA") then
				_G.ITEM = {}

				GM:Include(filePath)

				Register(string.gsub(string.FileName(folderPath), "^item_", ""), ITEM)

				ITEM = nil
			else
				load(folderPath .. "/")
			end
		end
	end

	load(basePath)
end

function Load()
	RegisterFolder(engine.ActiveGamemode() .. "/gamemode/content/items/")
end

function Instance(class, id, data)
	assert(not All[id], "Attempt to instance an already loaded item ID: " .. id)
	class = assert(List[class], "Attempt to instance unknown item type: " .. class)

	local instance = setmetatable({
		ID = id,
		Data = data or {}
	}, {
		__index = class,
		__tostring = function(self) return string.format("Item [%s][%s]", self.ID, self.ClassName) end
	})

	All[id] = instance

	instance:Initialize()

	return instance
end

function Get(id)
	return All[id]
end

function GetDropPosition(ply)
	local tr = util.TraceLine({
		start = ply:GetShootPos(),
		endpos = ply:GetShootPos() + ply:GetAimVector() * 50,
		filter = ply
	})

	return tr.HitPos + tr.HitNormal * 10
end

function meta:HasEquipmentSlot(slot)
	return table.HasValue(self:RunCharFlag("EquipmentSlots"), slot)
end

function GM:CanInteractWithItem(ply, item)
	return item:CanInteract(ply)
end

function GM:CanPickupItem(ply, item)
	if ply:IsTemporaryCharacter() and not item:IsTemporaryItem() then
		return false, "You can't pick up normal items as a temporary character!"
	end

	if ply:InventoryWeight() + item:GetWeight() > ply:MaxInventoryWeight() then
		return false, "That's too heavy for you to carry!"
	end

	return true
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

function GM:CanUseEquipmentSlot(ply, slot)
	if not ply:HasEquipmentSlot(slot) then
		return false, "Your character doesn't support that equipment slot!"
	end

	local item = ply:GetEquipment(slot)

	if item and not hook.Run("CanUnequipItem", ply, item) then
		return false, "You cannot equip this because of your " .. item:GetName()
	end

	return true
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

	return item:CanEquip(ply, slot)
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
