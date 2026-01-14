module("Character", package.seeall)

local PLAYER = FindMetaTable("Player")

function Delete(id)
	local data = Data.Character.Fetch(id)

	if not data then
		return
	end

	local ply = player.GetBySteamID(data.SteamID)

	if IsValid(ply) and ply:CharID() == id then
		ply:UnloadCharacter()
	end

	GAMEMODE.Database:Query("UPDATE `rp_characters` SET `Deleted_At` = :time WHERE `id` = :id", {
		time = os.time(),
		id = id
	})

	if IsValid(ply) then
		ply:LoadCharacterList()
	end
end

function Undelete(id)
	local data = Data.Character.Fetch(id)

	if not data then
		return
	end

	local ply = player.GetBySteamID(data.SteamID)

	GAMEMODE.Database:Query("UPDATE `rp_characters` SET `Deleted_At` = NULL WHERE `id` = :id", {
		id = id
	})

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

	GAMEMODE.Database:Query("UPDATE `rp_characters` SET `SteamID` = :steamId WHERE `id` = :id", {
		steamId = steamid,
		id = id
	})

	local newOwner = player.GetBySteamID(steamid)

	if IsValid(newOwner) then
		newOwner:LoadCharacterList()
	end
end

function PLAYER:LoadCharacterList()
	local data = GAMEMODE.Database:Query("SELECT `id`, `Name`, `NameOverride`, `EventCharacter` FROM `rp_characters` WHERE `SteamID` = :steamId AND `Deleted_At` IS NULL", {
		steamId = self:SteamID()
	})

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
	local keys = {"`SteamID`", "`Created_At`"}
	local values = {":steamId", ":time"}

	local data = {
		steamId = self:SteamID(),
		time = os.time()
	}

	for k, v in pairs(fields) do
		local var = CharacterVar.Vars[k]

		if var.Validate and not var.Validate(v) then
			error(string.format("%s value '%s' doesn't match database type %s", k, v, var.DataType))
		end

		table.insert(keys, string.format("`%s`", var.Field))
		table.insert(values, ":" .. var.Field)

		data[var.Field] = var.Encode and var.Encode(v) or v
	end

	local _, id = GAMEMODE.Database:Query(string.format("INSERT INTO `rp_characters` (%s) VALUES (%s)", table.concat(keys, ", "), table.concat(values, ", ")), data)

	self:LoadCharacter(id)
	self:LoadCharacterList()

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

	local data = Data.Character.Load(id)

	if not istable(data) then
		error(string.format("No character with id %s exists", id))
	end

	self:SetCharID(id)

	for name, var in pairs(CharacterVar.Vars) do
		self["Set" .. name](self, data[name], true)
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
