module("Data.Player", package.seeall)

function Fetch(steamID)
	local data = GAMEMODE.Database:Query("SELECT * FROM `rp_players` WHERE `SteamID` = :steamID", {
		steamID = steamID
	})[1]

	if not data then
		return false
	end

	local fields = Data.Unpack(data, PlayerVar.Vars, true)

	-- Add in fields without explicit vars
	fields.SteamID = data.SteamID

	return fields
end

function Nick(steamID)
	local data = GAMEMODE.Database:Query("SELECT `LastNick` FROM `rp_players` WHERE `SteamID` = :steamID", {
		steamID = steamID
	})[1]

	return data and data.LastNick or steamID
end

function Alias(steamID)
	local data = GAMEMODE.Database:Query("SELECT `Alias`, `LastNick` FROM `rp_players` WHERE `SteamID` = :steamID", {
		steamID = steamID
	})[1]

	if not data then
		return steamID
	end

	return data.Alias or data.LastNick or steamID
end

function UserGroup(steamID)
	local data = GAMEMODE.Database:Query("SELECT `UserGroup` FROM `rp_players` WHERE `SteamID` = :steamID", {
		steamID = steamID
	})[1]

	return data and data.UserGroup or "user"
end

function Load(ply)
	local steamID = ply:SteamID()

	Create(steamID)

	local data = GAMEMODE.Database:Query("SELECT * FROM `rp_players` WHERE `SteamID` = :steamID", {
		steamID = steamID
	})[1]

	for key, value in pairs(Data.Unpack(data, PlayerVar.Vars)) do
		ply["Set" .. key](ply, value, true)
	end
end

function Create(steamID)
	GAMEMODE.Database:Query("INSERT IGNORE INTO `rp_players` (`SteamID`) VALUES (:steamID)", {steamID = steamID})
end

function Update(steamID, data)
	local ply = player.GetBySteamID(steamID)

	if IsValid(ply) then
		for name, value in pairs(data) do
			local var = PlayerVar.Vars[name]

			if not var then
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
	local queryValues = {steamID = steamID}

	for _, field in pairs(fields) do
		local key, value = field[1], field[2]

		table.insert(queryFields, string.format("`%s` = :%s", key, key))

		queryValues[key] = value == nil and NULL or value
	end

	local query = string.format("UPDATE `rp_players` SET %s WHERE `SteamID` = :steamID", table.concat(queryFields, ", "))

	GAMEMODE.Database:Query(query, queryValues)
end
