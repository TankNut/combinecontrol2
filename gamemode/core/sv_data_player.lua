module("Data.Player", package.seeall)

function Fetch(steamID)
	local data = GAMEMODE.Database:Query("SELECT * FROM `rp_players` WHERE `SteamID` = :steamId", {
		steamId = steamID
	})[1]

	if not data then
		return false
	end

	local fields = Data.Unpack(data, PlayerVar.Vars, true)

	-- Add in fields without explicit vars
	fields.SteamID = data.SteamID

	return fields
end

function Load(ply)
	local steamID = ply:SteamID()

	Create(steamID)

	local data = GAMEMODE.Database:Query("SELECT * FROM `rp_players` WHERE `SteamID` = :steamId", {
		steamId = steamID
	})[1]

	for key, value in pairs(Data.Unpack(data, PlayerVar.Vars)) do
		ply["Set" .. key](ply, value, true)
	end
end

function Create(steamID)
	GAMEMODE.Database:Query("INSERT IGNORE INTO `rp_players` (`SteamID`) VALUES (:steamId)", {steamId = steamID})
end

function Update(steamID, data)
	local ply = player.GetBySteamID(steamID)

	if IsValid(ply) then
		for name, value in pairs(data) do
			if not PlayerVar.Vars[name] then
				continue
			end

			if (not istable(value) and value == var.Default) or value == NULL then
				value = nil
			end

			ply["Set" .. name](ply, value)
		end

		return
	else
		-- Wouldn't be able to set usergroups for people that don't exist otherwise
		Create(steamID)
	end

	Write(steamID, data)
end

function Write(steamID, data)
	local fields = Data.Pack(data, PlayerVar.Vars)

	local queryFields = {}
	local queryValues = {steamId = steamID}

	for _, field in pairs(fields) do
		local key, value = field[1], field[2]

		table.insert(queryFields, string.format("`%s` = :%s", key, key))

		queryValues[key] = value == nil and NULL or value
	end

	local query = string.format("UPDATE `rp_players` SET %s WHERE `SteamID` = :steamId", table.concat(queryFields, ", "))

	GAMEMODE.Database:Query(query, queryValues)
end
