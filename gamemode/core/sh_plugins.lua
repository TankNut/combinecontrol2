function GM:LoadPlugins()
	local files, folders = file.Find(PluginFolder .. "*", "LUA")
	local plugins = {}

	for _, path in ipairs(files) do
		if string.sub(path, -4) != ".lua" then
			continue
		end

		table.insert(plugins, path)
	end

	for _, path in ipairs(folders) do
		table.insert(plugins, path)
	end

	table.sort(plugins)

	for _, path in ipairs(plugins) do
		if string.sub(path, -4) == ".lua" then
			self:Include(PluginFolder .. path)
		else
			self:LoadPluginFolder(path)
		end
	end
end

function GM:LoadPluginFolder(path)
	local folder = PluginFolder .. path .. "/"

	if file.Exists(folder .. "_plugin.lua", "LUA") then
		self:Include(folder .. "_plugin.lua", "LUA")

		return
	end

	hook.Run("RegisterContent", path)

	GM:IncludeFolder(folder)
end
