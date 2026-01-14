module("Data.Character", package.seeall)

function Fetch(id)
	local data = GAMEMODE.Database:Query("SELECT * FROM `rp_characters` WHERE `id` = :id AND `Deleted_At` IS NULL", {
		id = id
	})[1]

	if not data then
		return false
	end

	local fields = Data.Unpack(data, CharacterVar.Vars, true)

	-- Add in fields without explicit vars
	fields.id = id
	fields.SteamID = data.SteamID

	return fields
end

function Load(id)
	local data = GAMEMODE.Database:Query("SELECT * FROM `rp_characters` WHERE `id` = :id AND `Deleted_At` IS NULL", {
		id = id
	})[1]

	if not data then
		return false
	end

	return Data.Unpack(data, CharacterVar.Vars)
end

function Update(id, data)
	local ply = Character.GetByID(id)

	if IsValid(ply) then
		for name, value in pairs(data) do
			if not CharacterVar.Vars[name] then
				continue
			end

			if (not istable(value) and value == var.Default) or value == NULL then
				value = nil
			end

			ply["Set" .. name](ply, value)
		end

		return
	end

	Write(id, data)
end

function Write(id, data)
	local fields = Data.Pack(data, CharacterVar.Vars)

	local queryFields = {}
	local queryValues = {id = id}

	for _, field in pairs(fields) do
		local key, value = field[1], field[2]

		table.insert(queryFields, string.format("`%s` = :%s", key, key))

		queryValues[key] = value == nil and NULL or value
	end

	local query = string.format("UPDATE `rp_characters` SET %s WHERE `id` = :id", table.concat(queryFields, ", "))

	GAMEMODE.Database:Query(query, queryValues)
end
