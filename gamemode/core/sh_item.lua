module("Item", package.seeall)

List = List or {}
Spawnable = Spawnable or {}

All = All or {}

-- Deliberate, we want to clear this every autorefresh
ActionCache = {}

Rarities = {
	[RARITY_COMMON]    = {Name = "Common",    Color = Color("rarity_common")},
	[RARITY_UNCOMMON]  = {Name = "Uncommon",  Color = Color("rarity_uncommon")},
	[RARITY_RARE]      = {Name = "Rare",      Color = Color("rarity_rare")},
	[RARITY_EPIC]      = {Name = "Epic",      Color = Color("rarity_epic")},
	[RARITY_LEGENDARY] = {Name = "Legendary", Color = Color("rarity_legendary")},
	[RARITY_ARTIFACT]  = {Name = "Artifact",  Color = Color("rarity_artifact")},
	[RARITY_DEVELOPER] = {Name = "Developer", Color = Color("rarity_developer")}
}

local PLAYER = FindMetaTable("Player")
local logger = log.Create("items")

function Register(name, item)
	item.Name = item.Name or name

	logger:Info("Registered: %s%s", name, item.Base and " : " .. item.Base or "")

	-- Done to prevent the var from getting inherited
	local internal = item.Internal; item.Internal = nil

	if item.Model and not util.IsValidModel(item.Model) then
		logger:Warning("Item '%s' tried to register an invalid model: %s", name, item.Model)

		item.Model = Model("models/props_lab/cactus.mdl")
	end

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

		shared(path)

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
		__tostring = function(self)
			return self:ToString()
		end
	})

	logger:Debug("Instance: %s", instance)

	All[id] = instance

	instance:Initialize()

	return instance
end

function Get(id)
	return All[id]
end

local fields = {
	"ClassName",
	"Name"
}

local function checkName(item, name)
	if not name then
		return true
	end

	name = string.lower(name)

	local ok = false

	for _, field in ipairs(fields) do
		local lower = string.lower(item[field])

		if name == lower then
			return true, true
		end

		if not ok and string.find(lower, name, 1, true) then
			ok = true
		end
	end

	if not ok then
		local rarity = Rarities[item.Rarity]

		for _, tag in ipairs(table.Add({rarity.Name, item.Category}, item.Tags)) do
			if string.find(string.lower(tag), name, 1, true) then
				return true
			end
		end
	end

	return ok
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

function PLAYER:HasKey(keyType, id)
	for _, item in pairs(self:GetItems()) do
		if item.TryKey and item:TryKey(keyType, id) then
			return true
		end
	end

	return false
end

function PLAYER:RunItemHooks(name, ...)
	for _, item in pairs(self:GetItems()) do
		if item[name] then
			item[name](item, self, ...)
		end
	end
end

function GM:CanSpawnItem(ply, itemClass)
	if itemClass.Rarity == RARITY_DEVELOPER and not ply:IsDeveloper() then
		return false
	end

	return true
end

function GM:CanDropItem(ply, item)
	local ok, err = item:CanInteract(ply)

	if not ok then
		return false, err
	end

	return item:CanDrop(ply)
end

function GM:CanDestroyItem(ply, item)
	local ok, err = item:CanInteract(ply)

	if not ok then
		return false, err
	end

	return item:CanDestroy(ply)
end

function GM:CanEquipItem(ply, item)
	local ok, err = item:CanInteract(ply)

	if not ok then
		return false, err
	end

	if item:IsEquipped() then
		return false, "This item is already equipped!"
	end

	if #item:GetCompatibleSlots() < 1 then
		return false, "You don't have any equipment slots to put this in!"
	end

	return item:CanEquip(ply)
end

function GM:CanUseEquipmentSlot(ply, item, slot)
	if not ply:HasEquipmentSlot(slot) then
		return false, "Your character doesn't support that equipment slot!"
	end

	local existing = ply:GetEquipment(slot)

	if existing and not hook.Run("CanUnequipItem", ply, existing) then
		return false, "You cannot equip this because of your " .. existing:GetName() .. "!"
	end

	return true
end

function GM:CanUnequipItem(ply, item)
	local ok, err = item:CanInteract(ply)

	if not ok then
		return false, err
	end

	if not item:IsEquipped() then
		return false, "This item isn't equipped!"
	end

	return item:CanUnequip(ply)
end

function GM:CanCustomizeItem(ply, item)
	local ok, err = item:CanInteract(ply)

	if not ok then
		return false, err
	end

	if not item.Customizable then
		return false
	end

	local config = Config.Get("ToolTrust")
	local trust = ply:GetToolTrust()

	if trust < config.ItemCustomization then
		return false
	end

	return true
end
