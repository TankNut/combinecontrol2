module("Log", package.seeall)

function Character(ply)
	local data = {
		CharID = ply:CharID(),
		CharName = ply:VisibleRPName(),
		EventCharacter = ply:IsEventCharacter()
	}

	table.Merge(data, Player(ply))

	return data
end

function Player(ply)
	if isstring(ply) then
		local name = PlayerVar.GetOffline(ply, "LastNick")

		if #name == 0 then
			name = nil
		end

		return {
			Player = name,
			SteamID = ply
		}
	end

	return {
		Player = ply:Nick(),
		SteamID = ply:SteamID()
	}
end

function Admin(ply)
	if not IsValid(ply) then
		return {
			AdminID = "CONSOLE",
			Admin = "CONSOLE",
			UserGroup = "CONSOLE"
		}
	end

	local data = {
		AdminID = ply:SteamID(),
		Admin = ply:GetAlias(),
		UserGroup = ply:UserGroup()
	}

	if ply:TempAdmin() then
		data.UserGroup = "temp_admin"
	end

	return data
end

function Item(item)
	return {
		ItemID = item.ID,
		ItemClass = item.ClassName,
		IsTemporaryItem = item:IsTemporaryItem()
	}
end

function Nick(ply)
	return IsValid(ply) and ply:Nick() or "CONSOLE"
end

function Read(name, data, offset, fromTime, toTime)
	local db = GAMEMODE.Database
	local where = {}

	if #name > 0 then
		table.insert(where, string.format("`Name` LIKE '%s'", db:Escape(name) .. "%"))
	end

	if fromTime then
		table.insert(where, string.format("`Timestamp` >= '%s'", db:Escape(fromTime)))
	end

	if toTime then
		table.insert(where, string.format("`Timestamp` <= '%s'", db:Escape(toTime)))
	end

	for key, value in pairs(data) do
		if #value > 1 then
			local values = {}

			for k, v in ipairs(value) do
				values[k] = string.format("'%s'", db:Escape(v))
			end

			table.insert(where, string.format("(`Key` = '%s' AND `Value` IN (%s))",
				db:Escape(key),
				table.concat(values, ", ")
			))
		else
			table.insert(where, string.format("(`Key` = '%s' AND `Value` = '%s')",
				db:Escape(key),
				db:Escape(value[1])
			))
		end
	end

	where = table.concat(where, " AND ")

	if #where > 0 then
		where = " WHERE " .. where
	end

	return db:RawQuery(string.format("SELECT UNIQUE `id`, `Log`, `Name`, `Timestamp`, `Data` FROM `rp_logs` LEFT JOIN `rp_log_data` USING (`id`)%s ORDER BY `id` DESC LIMIT %s OFFSET %s", where, Config.Get("LogLines"), offset or 0))
end

local colorCache

function BuildColorCache()
	colorCache = {}

	local prefixes = {}
	local lookup = {}

	for name in SortedPairs(Types) do
		local prefix = string.match(name, "^([%a]+_)") or "yes"

		if not lookup[prefix] then
			table.insert(prefixes, prefix)
			lookup[prefix] = true
		end
	end

	local interval = 360 / #prefixes

	for k, prefix in ipairs(prefixes) do
		colorCache[prefix] = HSVToColor((k - 1) * interval, 0.5, 1)
	end
end

local baseColor = Color(200, 200, 200)

function Write(name, ...)
	local parser = assert(Types[name], "Tried to write unknown log: " .. name)
	local log, data = parser(...)

	data = data or {}

	if not log then
		return
	end

	do
		if not colorCache then
			BuildColorCache()
		end

		local prefix = string.match(name, "^([%a]+_)") or "yes"

		MsgC(baseColor, os.date("!%Y-%m-%dT%H:%M:%SZ "), "[", colorCache[prefix], name, baseColor, "] ", log, "\n")
	end

	local keyvalues = {}

	local function processKeyValue(key, value)
		-- Easier for people to work with than true/false
		if isbool(value) then
			value = value and 1 or 0
		end

		table.insert(keyvalues, {
			key, tostring(value)
		})
	end

	for key, value in pairs(data) do
		if istable(value) and not IsColor(value) then
			for key2, value2 in SortedPairs(value) do
				processKeyValue(key2, value2)
			end
		else
			processKeyValue(key, value)
		end
	end

	async.Start(function()
		local _, id = GAMEMODE.Database:Query("INSERT INTO `rp_logs` (`Log`, `Name`, `Timestamp`, `Data`) VALUES (:log, :name, :time, :data)", {
			log = log,
			name = name,
			time = os.time(),
			data = sfs.encode(keyvalues)
		})

		GAMEMODE.Database:Begin()

		for _, pair in ipairs(keyvalues) do
			GAMEMODE.Database:Query("INSERT INTO `rp_log_data` (`id`, `Key`, `Value`) VALUES (:id, :key, :value)", {
				id = id,
				key = pair[1],
				value = pair[2]
			})
		end

		GAMEMODE.Database:Commit()
	end)
end

request.Hook("GetLogs", function(ply, config)
	if Access.SecureAdmin(ply, "GetLogs") then
		return
	end

	local logs = {}

	for _, log in ipairs(Read(config.Name or "", config.Data, config.Offset, config.From, config.To)) do
		log.id = nil

		table.insert(logs, log)
	end

	return logs
end)
