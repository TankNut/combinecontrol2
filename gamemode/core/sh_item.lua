module("Item", package.seeall)

List = List or {}
All = All or setmetatable({}, {
	__mode = "v"
})

local meta = FindMetaTable("Player")

PlayerVar.Add("InventoryWeight", {Default = 0})
PlayerVar.Add("MaxInventoryWeight", {Default = 0})

function Register(name, item)
	item.ClassName = name

	if not List[name] then
		List[name] = item
	end

	if name != "base" then
		setmetatable(item, {
			__index = baseclass.Get(item.Base or "item_base")
		})
	end

	baseclass.Set("item_" .. name, item)
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
	if All[id] then
		return All[id]
	end

	class = assert(List[class], "Attempt to instance unknown item type: " .. class)

	local instance = setmetatable({
		ID = id,
		Data = data or {}
	}, {
		__index = class
	})

	All[id] = instance

	return instance
end

function Get(id)
	return All[id]
end

function meta:GetItems()
	if CLIENT and self == lp then
		return Inventory
	elseif SERVER then
		return Inventory.List[self].Main.Items
	end

	return {}
end
