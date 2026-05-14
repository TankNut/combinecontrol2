local folderEntrypoints = {
	["/cl_init.lua"] = client,
	["/shared.lua"] = shared,
	["/init.lua"] = server
}

local function loadFolder(folder, tableName, folderName, registerFunc)
	folder = folder .. folderName .. "/"
	local files, folders = file.Find(folder .. "*", "LUA")

	for _, path in ipairs(files) do
		if string.GetExtensionFromFilename(path) != "lua" then
			continue
		end

		local name = string.Filename(path)

		_G[tableName] = {
			Folder = folderName .. "/" .. name
		}

		shared(folder .. path)

		local t = _G[tableName]
		_G[tableName] = nil

		scripted_ents.Register(t, name)
	end

	for _, name in ipairs(folders) do
		_G[tableName] = {
			Folder = folderName .. "/" .. name
		}

		for filepath, func in pairs(folderEntrypoints) do
			local path = folder .. name .. filepath

			if file.Exists(path, "LUA") then
				func(path)
			end
		end

		local t = _G[tableName]
		_G[tableName] = nil

		registerFunc(t, name)
	end
end

function GM:RegisterContent(folder)
	Animation.RegisterFolder(folder .. "animations/")
	CharacterCreate.RegisterFolder(folder .. "chartypes/")
	CharacterFlag.RegisterFolder(folder .. "flags/")
	CharacterGen.RegisterFolder(folder .. "chargens/")
	Chat.RegisterFolder(folder .. "chat/")
	Item.RegisterFolder(folder .. "items/")
	Hud.RegisterFolder(folder .. "hud/")
	buff.RegisterFolder(folder .. "buffs/")

	loadFolder(folder, "ENT", "entities", scripted_ents.Register)
	loadFolder(folder, "SWEP", "weapons", weapons.Register)
	loadFolder(folder, "EFFECT", "effects", effects.Register)
end
