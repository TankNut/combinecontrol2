module("Character", package.seeall)

local meta = FindMetaTable("Player")

function meta:NewCreateCharacter(fields)
	local query = GAMEMODE.Database:Insert("rp_characters")
		query:Insert("SteamID", self:SteamID())

		for k, v in pairs(fields) do
			local var = CharacterVar.Vars[k]

			if var.validate and not var.validate(v) then
				error(string.format("%s value '%s' doesn't match database type %s", k, v, var.DataType))
			end

			if var.DataType == "BLOB" then
				query:Insert(k.Field, sfs.encode(v))
			else
				query:Insert(k.Field, v)
			end
		end
	local _, id = query:Execute()

	return id
end

function meta:NewLoadCharacter(id)
	local query = GAMEMODE.Database:Select("rp_characters")
		query:WhereEqual("id", id)
		query:WhereNull("Deleted_At")
	local data = assert(query:Execute()[1], string.format("No character with id %s exists", id))

	self:SetCharID(id)

	for _, var in pairs(CharacterVar.Vars) do
		local val = data[var.Field]

		if not val then
			self["SetCharacter" .. var.Name](self, nil, true)

			continue
		end

		if var.DataType == "BLOB" then
			val = sfs.decode(val)
		end

		self["SetCharacter" .. var.Name](self, val, true)
	end
end

function Delete(id)
	local query = GAMEMODE.Database:Update("rp_characters")
		query:UpdateRaw("Deleted_At", "CURRENT_TIMESTAMP")
		query:WhereEqual("id", id)
	query:Execute()
end
