module("Character", package.seeall)

local meta = FindMetaTable("Player")

function meta:LoadCharacterList()
	local query = GAMEMODE.Database:Select("rp_characters")
		query:Select("id")
		query:Select("Name")
		query:Select("NameOverride")
		query:WhereEqual("SteamID", self:SteamID())
		query:WhereNull("Deleted_At")
	local data = query:Execute()

	local characters = {}

	for _, row in pairs(data) do
		characters[row.id] = row.NameOverride or row.Name
	end

	self:SetCharacterList(characters, true)
end

function meta:CreateCharacter(fields)
	local query = GAMEMODE.Database:Insert("rp_characters")
		query:Insert("SteamID", self:SteamID())

		for k, v in pairs(fields) do
			local var = CharacterVar.Vars[k]

			if var.Validate and not var.Validate(v) then
				error(string.format("%s value '%s' doesn't match database type %s", k, v, var.DataType))
			end

			if var.DataType == "BLOB" then
				query:Insert(var.Field, sfs.encode(v))
			else
				query:Insert(var.Field, v)
			end
		end
	local _, id = query:Execute()

	return id
end

function meta:LoadCharacter(id)
	local query = GAMEMODE.Database:Select("rp_characters")
		query:WhereEqual("id", id)
		query:WhereNull("Deleted_At")
	local data = assert(query:Execute()[1], string.format("No character with id %s exists", id))

	self:SetCharID(id)

	for _, var in pairs(CharacterVar.Vars) do
		local val = data[var.Field]

		if not val then
			self["Set" .. var.Name](self, nil, true)

			continue
		end

		if var.DataType == "BLOB" then
			val = sfs.decode(val)
		end

		self["Set" .. var.Name](self, val, true)
	end

	Inventory.Load(self)

	netstream.Send(self, "PostLoadCharacter")
	hook.Run("PostLoadCharacter", self)
end

function meta:DeleteCharacter(id)
	Delete(id)

	local characters = self:CharacterList()
	characters[id] = nil

	self:SetCharacterList(characters)
end

function Delete(id)
	local query = GAMEMODE.Database:Update("rp_characters")
		query:UpdateRaw("Deleted_At", "CURRENT_TIMESTAMP")
		query:WhereEqual("id", id)
	query:Execute()
end

function GM:PreCreateCharacter(ply, fields)
	Language.SetupCharacter(fields)
end

netstream.Hook("CreateCharacter", function(ply, name, desc, model, skin)
	local mul = ply:IsSuperAdmin() and 3 or ply:IsAdmin() and 2 or 1
	if table.Count(ply:CharacterList()) >= GAMEMODE.MaxCharacters * mul then return end
	if not ply:IsAdmin() and GAMEMODE.CurrentLocation != LOCATION_CITY then return end

	if GAMEMODE:CheckCharacterValidity(name, desc, model, skin) then
		local fields = {
			Name = name,
			Description = desc,
			Model = model,
			Skin = skin
		}

		hook.Run("PreCreateCharacter", ply, fields)

		ply:LoadCharacter(ply:CreateCharacter(fields))
	end
end)

netstream.Hook("SelectCharacter", function(ply, id)
	if not ply:CharacterList()[id] then
		return
	end

	ply:LoadCharacter(id)
end)
