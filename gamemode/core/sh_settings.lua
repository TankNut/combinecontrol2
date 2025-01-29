module("Settings", package.seeall)

List = List or {}
Categories = {}

if CLIENT then
	Cache = Cache or {}

	if not sql.TableExists("cc_settings") then
		sql.Query("CREATE TABLE cc_settings (key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL)")
	end
end

local meta = FindMetaTable("Player")
local logger = log.Create("settings")

PlayerVar.Add("StoredSettings", {
	Default = {},
	ServerOnly = true,
	Persist = true,
	Field = "Settings",
	DataType = BLOB()
})

function Add(name, data, category)
	data = {
		Key = name,
		Name = data.Name or name,
		VarName = name .. "Setting",
		Default = data.Default,
		ClientOnly = tobool(data.ClientOnly),
		Private = tobool(data.Private),
		Validate = assert(data.Validate, "Setting is missing validation rules"),
		Category = category or "Misc",
		Panel = data.Panel,
		Args = data.Args
	}

	if not data.ClientOnly then
		PlayerVar.Add(data.VarName, {
			Default = data.Default,
			Private = data.Private
		})

		if SERVER then
			hook.Add("On" .. data.VarName .. "Changed", "Settings", function(ply, old, new, loaded)
				if loaded then
					return
				end

				local settings = ply:StoredSettings()
				settings[name] = new

				ply:SetStoredSettings(settings)
			end)
		end
	end

	local mode = ""

	if data.ClientOnly then
		mode = " client"
	elseif data.Private then
		mode = " private"
	end

	logger:Info("Registered%s setting: %s", mode, name)

	List[name] = data

	if data.Panel then -- Editable in F3
		for _, v in ipairs(Categories) do
			if v.Name == data.Category then
				table.insert(v, data)

				return
			end
		end

		table.insert(Categories, {
			Name = data.Category,
			[1] = data
		})
	end
end

function Load()
	GM:LoadFolder(ContentFolder .. "settings/")

	for _, plugin in ipairs(PluginFolders) do
		GM:LoadFolder(plugin .. "settings/")
	end
end

if CLIENT then
	local function get(data)
		local val = Cache[data.Key]

		if val == nil then
			return util.SafeCopy(data.Default)
		end

		return val
	end

	function LoadClient()
		local sqlData = sql.Query("SELECT * FROM cc_settings")

		if not sqlData then
			return
		end

		local i = 0

		for _, row in pairs(sqlData) do
			local key = row.key
			local data = List[key]

			if not data then
				continue
			end

			local value = sfs.decode(row.value)
			local ok, err = validate.Value(value, data.Validate)

			if not ok then
				logger:Warning("Skipping sqlite row: [%s] = '%s' (%s)",  key, value, err)

				continue
			end

			i = i + 1

			logger:Debug("Load sqlite: [%s] = '%s'", key, value)

			local old = get(data)
			Cache[key] = value
			local new = get(data)

			if istable(old) or new != old then
				hook.Run("On" .. data.VarName .. "Changed", lp, old, new, true)
			end
		end

		logger:Info("Loaded %s settings from sqlite", i)
	end

	function Get(key)
		local data = assert(List[key], "Attempt to get non-existent setting " .. key)

		if data.ClientOnly then
			return get(data)
		else
			return meta[data.VarName](lp)
		end
	end

	function Set(key, value)
		local data = assert(List[key], "Attempt to set non-existent setting " .. key)

		if not validate.Value(value, data.Validate) then
			return
		end

		if data.ClientOnly then
			if value == data.Default then value = nil end

			local old = get(data)
			Cache[key] = value
			local new = get(data)

			if istable(old) or new != old then
				Save(key, value)

				hook.Run("On" .. data.VarName .. "Changed", lp, old, new)
			end
		else
			meta["Set" .. data.VarName](lp, value)
			netstream.Send("SetSetting", key, value)
		end
	end

	function Save(key, value)
		logger:Debug("Sqlite write: [%s] = %s", key, value)

		if value == nil then
			sql.Query(string.format("DELETE FROM cc_settings where key = %s",
				SQLStr(key)
			))
		else
			sql.Query(string.format("REPLACE INTO cc_settings (key, value) VALUES (%s, %s)",
				SQLStr(key), SQLStr(sfs.encode(value))
			))
		end
	end

	netstream.Hook("ForceSetting", Set)
end

function meta:GetSetting(key)
	local data = assert(List[key], "Attempt to get non-existent setting " .. key)

	if data.ClientOnly then
		assert(CLIENT, "Attempt to get client-only setting on SERVER")
		assert(self == lp, "Attempt to get another player's client-only setting")

		return Get(key)
	else
		return meta[data.VarName](self)
	end
end

if SERVER then
	function meta:SetSetting(key, value)
		local data = assert(List[key], "Attempt to set non-existent setting " .. key)

		if data.ClientOnly then
			logger:Info("Remote setting client: %s[%s] = '%s'", self, key, value)

			netstream.Send("ForceSetting", key, value)
		else
			meta["Set" .. data.VarName](self, value)
		end
	end

	netstream.Hook("SetSetting", function(ply, key, value)
		local data = List[key]

		if not data or data.ClientOnly then
			return
		end

		local ok, err = validate.Value(value, data.Validate)

		if not ok then
			logger:Warning("%s tried to bypass validation: [%s] = '%s' (%s)", ply, key, value, err)

			return
		end

		meta["Set" .. data.VarName](ply, value)
	end)

	function GM:OnStoredSettingsChanged(ply, old, new, loaded)
		if not loaded then
			return
		end

		local i = 0

		for key, data in pairs(List) do
			local value = new[key]

			if value == nil then
				continue
			end

			local ok, err = validate.Value(value, data.Validate)

			if not ok then
				logger:Warning("Skipping player var: %s[%s] = '%s' (%s)", ply, key, value, err)

				continue
			end

			logger:Debug("Load player var: %s[%s] = '%s'", ply, key, value)

			meta["Set" .. data.VarName](ply, value, true)
		end

		logger:Info("Loaded %s player var settings for %s", i, ply)
	end
end
