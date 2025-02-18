module("Character", package.seeall)

TempData = TempData or {}

local PLAYER = FindMetaTable("Player")

function PLAYER:LoadCharacterList()
	local query = GAMEMODE.Database:Select("rp_characters")
		query:Select("id")
		query:Select("Name")
		query:Select("NameOverride")
		query:WhereEqual("SteamID", self:SteamID())
		query:WhereNull("Deleted_At")
	local data = query:Execute()

	local characters = {}

	for _, row in pairs(data) do
		characters[row.id] = row.NameOverride or row.Name or "Unknown"
	end

	for id, temp in ipairs(TempData) do
		if temp.SteamID == self:SteamID() then
			characters[-id] = temp.Fields.CharacterNameOverride or temp.Fields.CharacterName or "Unknown"
		end
	end

	self:SetCharacterList(characters, true)
end

function PLAYER:CreateCharacter(fields)
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

	local characters = self:CharacterList()
	characters[id] = fields.CharacterNameOverride or fields.CharacterName or "Unknown"

	self:SetCharacterList(characters)
	self:LoadCharacter(id)

	return id
end

function PLAYER:CreateTempCharacter(fields)
	local id = -table.insert(TempData, {
		SteamID = self:SteamID(),
		Fields = fields
	})

	local characters = self:CharacterList()
	characters[id] = fields.CharacterNameOverride or fields.CharacterName or "Unknown"

	self:SetCharacterList(characters)
	self:LoadTempCharacter(id)

	return id
end

function PLAYER:LoadTempCharacter(id)
	local data = TempData[-id].Fields

	self:SetCharID(id)

	for _, var in pairs(CharacterVar.Vars) do
		local val = data[var.Name]

		if not val then
			self["Set" .. var.Name](self, nil, true)

			continue
		end

		self["Set" .. var.Name](self, val, true)
	end

	Inventory.LoadTemp(self)

	netstream.Send(self, "PostLoadCharacter")

	hook.Run("PostLoadCharacter", self)
end

function PLAYER:LoadCharacter(id)
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

function PLAYER:UnloadCharacter()
	self:SetCharID(0)

	for _, var in pairs(CharacterVar.Vars) do
		self["Set" .. var.Name](self, nil, true)
	end

	Inventory.Clear(self)

	self:Spawn()
end

netstream.Hook("DeleteCharacter", function(ply, id)
	if not ply:CharacterList()[id] then
		return
	end

	ply:DeleteCharacter(id)
end)

function PLAYER:DeleteCharacter(id)
	if id < 0 then
		DeleteTemp(id)
	else
		Delete(id)
	end

	local characters = self:CharacterList()
	characters[id] = nil

	self:SetCharacterList(characters)

	if self:CharID() == id then
		self:UnloadCharacter()
	end
end

function DeleteTemp(id)
	local data = TempData[-id]

	if data.Inventory then
		Inventory.Get(data.Inventory):Remove()
		Inventory.Get(data.Stash):Remove()
	end

	TempData[-id] = nil
end

function Delete(id)
	local query = GAMEMODE.Database:Update("rp_characters")
		query:UpdateRaw("Deleted_At", "CURRENT_TIMESTAMP")
		query:WhereEqual("id", id)
	query:Execute()
end

netstream.Hook("SelectCharacter", function(ply, id)
	if not ply:CharacterList()[id] then
		return
	end

	if id < 0 then
		ply:LoadTempCharacter(id)
	else
		ply:LoadCharacter(id)
	end
end)

netstream.Hook("ChangeCharacterName", function(ply, new)
	if not ply:HasCharacter() or not hook.Run("CanChangeCharacterName", ply) then
		return
	end

	if not validate.Value(new, Config.Get("CharacterNameRules")) then
		return
	end

	ply:SetCharacterName(new)
end)

netstream.Hook("ChangeCharacterDescription", function(ply, new)
	if not ply:HasCharacter() or not hook.Run("CanChangeCharacterDescription", ply) then
		return
	end

	new = string.Escape(new)

	if not validate.Value(new, Config.Get("CharacterDescriptionRules")) then
		return
	end

	ply:SetCharacterDescription(new)
end)

function GM:OnCharacterNameChanged(ply, old, new)
	ply:UpdateVisibleName()
end

function GM:OnCharacterNameOverrideChanged(ply, old, new)
	ply:UpdateVisibleName()
end

function GM:OnCharacterDescriptionChanged(ply, old, new)
	ply:UpdateVisibleDescription()
end

request.Hook("Examine", function(ply, target)
	target.ExamineCache = target.ExamineCache or {}

	if not target.ExamineCache[ply] then
		target.ExamineCache[ply] = true

		return target:VisibleDescription()
	end
end)
