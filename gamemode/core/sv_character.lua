module("Character", package.seeall)

local PLAYER = FindMetaTable("Player")

function Fetch(id)
	local query = GAMEMODE.Database:Select("rp_characters")
		query:WhereEqual("id", id)

	local data = query:Execute()[1]

	if not data then
		return false
	end

	local fields = {
		id = id,
		SteamID = data.SteamID
	}

	for _, var in pairs(CharacterVar.Vars) do
		local val = data[var.Field]

		if not val then
			val = util.SafeCopy(var.Default)
		elseif var.Decode then
			val = var.Decode(val)
		end

		fields[var.Name] = val
	end

	return fields
end

function Delete(id)
	local data = Fetch(id)

	if not data then
		return
	end

	local ply = player.GetBySteamID(data.SteamID)

	if IsValid(ply) and ply:CharID() == id then
		ply:UnloadCharacter()
	end

	local query = GAMEMODE.Database:Update("rp_characters")
		query:Update("Deleted_At", os.time())
		query:WhereEqual("id", id)
	query:Execute()

	if IsValid(ply) then
		ply:LoadCharacterList()
	end
end

function Undelete(id)
	local data = Fetch(id)

	if not data then
		return
	end

	local ply = player.GetBySteamID(data.SteamID)

	local query = GAMEMODE.Database:Update("rp_characters")
		query:UpdateRaw("Deleted_At", "NULL")
		query:WhereEqual("id", id)
	query:Execute()

	if IsValid(ply) then
		ply:LoadCharacterList()
	end
end

function SetOwner(id, steamid)
	local oldOwner = GetByID(id)

	if IsValid(oldOwner) then
		oldOwner:UnloadCharacter()

		local charList = oldOwner:CharacterList()
		charList[id] = nil

		oldOwner:SetCharacterList(charList)
	end

	local query = GAMEMODE.Database:Update("rp_characters")
		query:Update("SteamID", steamid)
		query:WhereEqual("id", id)
	query:Execute()

	local newOwner = player.GetBySteamID(steamid)

	if IsValid(newOwner) then
		newOwner:LoadCharacterList()
	end
end

function PLAYER:LoadCharacterList()
	local query = GAMEMODE.Database:Select("rp_characters")
		query:Select("id")
		query:Select("Name")
		query:Select("NameOverride")
		query:Select("EventCharacter")
		query:WhereEqual("SteamID", self:SteamID())
		query:WhereNull("Deleted_At")
	local data = query:Execute()

	local characters = {}

	for _, row in pairs(data) do
		characters[row.id] = {
			Name = row.NameOverride or row.Name or "Unknown",
			Event = tobool(row.EventCharacter)
		}
	end

	self:SetCharacterList(characters, true)
end

function PLAYER:CreateCharacter(fields)
	local query = GAMEMODE.Database:Insert("rp_characters")
		query:Insert("SteamID", self:SteamID())
		query:Insert("Created_At", os.time())

		for k, v in pairs(fields) do
			local var = CharacterVar.Vars[k]

			if var.Validate and not var.Validate(v) then
				error(string.format("%s value '%s' doesn't match database type %s", k, v, var.DataType))
			end

			if var.Encode then
				query:Insert(var.Field, var.Encode(v))
			else
				query:Insert(var.Field, v)
			end
		end
	local _, id = query:Execute()

	self:LoadCharacterList()
	self:LoadCharacter(id)

	return id
end

function GM:PreLoadCharacter(ply, id)
	if ply:HasCharacter() then
		ply:SetCharacterLastSeen(os.time())
	end
end

function PLAYER:LoadCharacter(id)
	local ply = GetByID(id)

	if ply then
		ply:UnloadCharacter()
	end

	hook.Run("PreLoadCharacter", self, id)

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

		if var.Decode then
			val = var.Decode(val)
		end

		self["Set" .. var.Name](self, val, true)
	end

	Inventory.Load(self)

	netstream.Send(self, "PostLoadCharacter")

	hook.Run("PostLoadCharacter", self)
end

function PLAYER:UnloadCharacter()
	hook.Run("PreLoadCharacter", self, 0)

	self:SetCharID(0)

	for _, var in pairs(CharacterVar.Vars) do
		self["Set" .. var.Name](self, nil, true)
	end

	Inventory.Clear(self)

	self:CloseGUI("HelpMenu")
	self:CloseGUI("AdminMenu")
	self:CloseGUI("PlayerMenu")

	self:Spawn()
end

netstream.Hook("DeleteCharacter", function(ply, id)
	if not ply:CharacterList()[id] then
		return
	end

	Log.Write("character_delete", ply, id)

	Delete(id)
end)

netstream.Hook("SelectCharacter", function(ply, id)
	if not ply:CharacterList()[id] then
		return
	end

	ply:LoadCharacter(id)
end)

netstream.Hook("ChangeCharacterName", function(ply, new)
	if not ply:HasCharacter() or not hook.Run("CanChangeCharacterName", ply) then
		return
	end

	if not validate.Value(new, Config.Get("CharacterNameRules")) then
		return
	end

	Log.Write("character_set_name", ply, new)

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

	Log.Write("character_set_description", ply, new)

	ply:SetCharacterDescription(new)
end)

netstream.Hook("ChangeCharacterNotes", function(ply, new)
	if not ply:HasCharacter() then
		return
	end

	new = string.Escape(new)

	if not validate.Value(new, Config.Get("CharacterDescriptionRules")) then
		return
	end

	-- Notes are only visible to the player themselves, admins don't have to know what's in there

	ply:SetCharacterNotes(new)
end)

local function updateCharacterListing(ply)
	local charList = ply:CharacterList()

	local name = ply:CharacterName()
	local override = ply:CharacterNameOverride()

	charList[ply:CharID()] = {
		Name = #override > 0 and override or name or "*UNKNOWN*",
		Event = ply:IsEventCharacter()
	}

	ply:SetCharacterList(charList)
end

function GM:OnCharacterNameChanged(ply, old, new, loaded)
	if not loaded then
		ply:UpdateVisibleName()

		updateCharacterListing(ply)
	end
end

function GM:OnCharacterNameOverrideChanged(ply, old, new, loaded)
	if not loaded then
		ply:UpdateVisibleName()

		updateCharacterListing(ply)
	end
end

function GM:OnIsEventCharacterChanged(ply, old, new, loaded)
	if not loaded then
		updateCharacterListing(ply)
	end
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
