local prefixes = {
	["sh_"] = shared,
	["cl_"] = client,
	["cc_"] = client,
	["gui_"] = client,
	["sv_"] = server
}

function GM:Include(path)
	local filename = string.Filename(path)

	for prefix, func in pairs(prefixes) do
		if string.sub(filename, 1, #prefix) == prefix then
			return func(path)
		end
	end

	return shared(path)
end

function GM:IncludeFolder(dir, entrypoint)
	file.Iterate(dir, entrypoint, "LUA", function(path)
		self:Include(path)
	end)
end

function GM:IncludeRecursive(dir, entrypoint)
	file.IterateRecursive(dir, entrypoint, "LUA", function(path)
		self:Include(path)
	end)
end

GM.PluginFolders = {}

function GM:LoadPlugins()
	local files, folders = file.Find(PluginFolder .. "*", "LUA")
	local plugins = {}

	for _, path in ipairs(files) do
		if string.GetExtensionFromFilename(path) != "lua" then
			continue
		end

		table.insert(plugins, path)
	end

	for _, path in ipairs(folders) do
		table.insert(plugins, path)
	end

	table.sort(plugins)

	for _, path in ipairs(plugins) do
		if string.GetExtensionFromFilename(path) == "lua" then
			self:Include(PluginFolder .. path)
		else
			self:LoadPluginFolder(path)
		end
	end
end

function GM:LoadPluginFolder(path)
	local folder = PluginFolder .. path .. "/"

	if file.Exists(folder .. "_plugin.lua", "LUA") then
		shared(folder .. "_plugin.lua", "LUA")
	else
		GM:IncludeFolder(folder)
	end

	table.insert(self.PluginFolders, folder)

	hook.Call("RegisterContent", self, folder)
end

function GM:LoadContentFolders()
	hook.Call("LoadContent", GM, BaseContentFolder)

	for _, folder in ipairs(self.PluginFolders) do
		hook.Call("LoadContent", GM, folder)
	end

	hook.Call("LoadContent", GM, ContentFolder)
end

function GM:LoadContent(folder)
	Animation.RegisterFolder(folder .. "animations/")
	CharacterCreate.RegisterFolder(folder .. "chartypes/")
	CharacterFlag.RegisterFolder(folder .. "flags/")
	CharacterGen.RegisterFolder(folder .. "chargens/")
	Chat.RegisterFolder(folder .. "chat/")
	Item.RegisterFolder(folder .. "items/")
	Hud.RegisterFolder(folder .. "hud/")
	buff.RegisterFolder(folder .. "buffs/")
end

-- Loading external utilities
shared("utils/_utils.lua")

-- Constants and config module
shared("enums.lua")
shared("config.lua")

-- Gamemode config acts as a fallback for cc2_config
GM:IncludeFolder(engine.ActiveGamemode() .. "/gamemode/config/")
GM:IncludeFolder("cc2_config/")

-- Define a bunch of folder constants
BaseContentFolder = engine.ActiveGamemode() .. "/gamemode/content/"
ContentFolder = "cc2_content/"
PluginFolder = "cc2_plugins/"
DataFolder = "combinecontrol-2/" .. Config.Get("InternalName") .. "/"

-- Include gamemode core
shared("core/_core.lua")
shared(BaseContentFolder .. "_content.lua")

-- Load external content
GM:LoadPlugins()
shared(ContentFolder .. "_content.lua")

Language.Load()

-- Run all register functions
GM:LoadContentFolders()

-- Set so we can avoid duplicate loads for some gmod-specific things
Loaded = true
