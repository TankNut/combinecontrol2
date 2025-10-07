module("Settings", package.seeall)

List = {}

Categories = table.Map(Config.Get("SettingCategories"), function(name)
	return {Name = name}
end)

if CLIENT then
	Cache = Cache or {}

	if not sql.TableExists("cc_settings") then
		sql.Query("CREATE TABLE cc_settings (key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL)")
	end
end

local PLAYER = FindMetaTable("Player")
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
		Args = data.Args,
		CanAccess = data.CanAccess,
		Dark = tobool(data.Dark),
		Hint = data.Hint or nil
	}

	if not data.ClientOnly then
		PlayerVar.Add(data.VarName, {
			Default = data.Default,
			Private = data.Private
		})

		if SERVER then
			hook.Add("On" .. data.VarName .. "Changed", "cc2.Settings", function(ply, old, new, loaded)
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
		mode = "client"
	else
		mode = "server"
	end

	local private = data.Private and " (private)" or ""

	logger:Info("Registered %s setting: %s%s", mode, name, private)

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

if CLIENT then
	local function get(data)
		local val = Cache[data.Key]

		if val == nil then
			return util.SafeCopy(data.Default)
		end

		return val
	end

	function LoadClient()
		local path = DataFolder .. "settings.dat"

		if not file.Exists(path, "DATA") then
			logger:Info("Skipping load: No file found at garrysmod/data/%s", path)

			return
		end

		local rawData = file.Read(path, "DATA")

		logger:Debug("Read %s from garrysmod/data/%s", string.NiceSize(file.Size(path, "DATA")), path)

		-- We do a bit of variable re-use so we're defining them all in one go
		local ok, data, err

		data, err = sfs.decode_from_hex(rawData)

		if err then
			logger:Warning("Failed to load from disk: " .. data)

			return
		end

		local i = 0

		for key, value in pairs(data) do
			local define = List[key]

			if not define then
				continue
			end

			ok, err = validate.Value(value, define.Validate)

			if not ok then
				logger:Warning("Skipping setting: [%s] = '%s' (%s)",  key, value, err)

				continue
			end

			i = i + 1

			logger:Debug("Load setting: [%s] = '%s'", key, value)

			local old = get(define)
			Cache[key] = value
			local new = get(define)

			if istable(old) or new != old then
				hook.Run("On" .. define.VarName .. "Changed", lp, old, new, true)
			end
		end

		logger:Info("Loaded %s settings from disk", i)
	end

	function Get(key)
		local data = assert(List[key], "Attempt to get non-existent setting " .. key)

		if data.CanAccess and not data.CanAccess(lp) then
			return util.SafeCopy(data.Default)
		end

		if data.ClientOnly then
			return get(data)
		else
			return PLAYER[data.VarName](lp)
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
				deferred.Call("settings.save", 10, Save)

				hook.Run("On" .. data.VarName .. "Changed", lp, old, new)
			end
		else
			PLAYER["Set" .. data.VarName](lp, value)
			netstream.Send("SetSetting", key, value)
		end
	end

	function Save()
		local path = DataFolder .. "settings.dat"

		file.WriteSafe(path, sfs.encode_to_hex(Cache))

		logger:Debug("Wrote %s to garrysmod/data/%s", string.NiceSize(file.Size(path, "DATA")), path)
	end

	netstream.Hook("ForceSetting", Set)
end

function PLAYER:GetSetting(key)
	local data = assert(List[key], "Attempt to get non-existent setting " .. key)

	if data.CanAccess and not data.CanAccess(self) then
		return util.SafeCopy(data.Default)
	end

	if data.ClientOnly then
		assert(CLIENT, "Attempt to get client-only setting on SERVER")
		assert(self == lp, "Attempt to get another player's client-only setting")

		return Get(key)
	else
		return PLAYER[data.VarName](self)
	end
end

if SERVER then
	function PLAYER:SetSetting(key, value)
		local data = assert(List[key], "Attempt to set non-existent setting " .. key)

		if data.ClientOnly then
			logger:Info("Remote setting client: %s[%s] = '%s'", self, key, value)

			netstream.Send("ForceSetting", key, value)
		else
			PLAYER["Set" .. data.VarName](self, value)
		end
	end

	netstream.Hook("SetSetting", function(ply, key, value)
		local data = List[key]

		if not data or data.ClientOnly then
			return
		end

		if data.CanAccess and not data.CanAccess(ply) then
			return
		end

		local ok, err = validate.Value(value, data.Validate)

		if not ok then
			logger:Warning("%s tried to bypass validation: [%s] = '%s' (%s)", ply, key, value, err)

			return
		end

		PLAYER["Set" .. data.VarName](ply, value)
	end)

	function GM:OnStoredSettingsChanged(ply, old, new, loaded)
		if not loaded then
			return
		end

		local i = 0

		for key, data in pairs(List) do
			if data.ClientOnly then
				continue
			end

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

			PLAYER["Set" .. data.VarName](ply, value, true)
		end

		logger:Info("Loaded %s player var settings for %s", i, ply)
	end
end
