local listCharacters = console.AddCommand("rpa_eventcharacter_list", function(ply)
	local characters = GAMEMODE.Database:Query([[
SELECT rp_characters.id,
       rp_characters.SteamID,
       COALESCE(rp_characters.NameOverride, rp_characters.Name) as Name,
       rp_characters.Flag,
       rp_players.LastNick
FROM rp_characters
  LEFT JOIN rp_players ON rp_characters.SteamID = rp_players.SteamID
WHERE rp_characters.EventCharacter = 1 AND rp_characters.Deleted_At IS NULL AND rp_characters.SteamID != 'BOT']])

	if #characters < 1 then
		console.Feedback(ply, "ERROR", "No event characters exist!")

		return
	end

	local defaultFlag = CharacterFlag.Get(GAMEMODE.DefaultFlag).Name
	local lines = {"Event characters:"}

	for _, character in ipairs(characters) do
		table.insert(lines, string.format("  CharID %s: %s - %s (%s - %s)",
			character.id,
			character.Name,
			character.Flag and CharacterFlag.Get(character.Flag).Name or defaultFlag,
			character.SteamID,
			character.LastNick
		))
	end

	console.Feedback(ply, "CONSOLE", table.concat(lines, "\n"))
end)

listCharacters:SetCategory("Event Character Commands")
listCharacters:SetDescription("Lists all event characters")
listCharacters:SetExecutionContext(console.Server)
listCharacters:SetAccess(console.IsAdmin)





local setOwner = console.AddCommand("rpa_eventcharacter_owner", function(ply, id, steamid)
	local data = Character.Fetch(id)

	if not data or not data.IsEventCharacter then
		console.Feedback(ply, "ERROR", "That character either doesn't exist or isn't an event character!")

		return
	end

	if data.SteamID == steamid then
		console.Feedback(ply, "ERROR", "That event character is already owned by that player!")

		return
	end

	-- if Character.GetByID(id) then inform them
	-- if player.GetBySteamID then also inform

	Character.SetOwner(id, steamid)
end)

setOwner:SetCategory("Event Character Commands")
setOwner:SetDescription("Changes ownership of an event character")
setOwner:SetExecutionContext(console.Server)
setOwner:SetAccess(console.IsAdmin)

setOwner:AddParameter(console.Number(nil, "character id"))
setOwner:AddParameter(console.SteamID(nil, "new owner"))





local delete = console.AddCommand("rpa_eventcharacter_delete", function(ply, id)
	local data = Character.Fetch(id)

	if not data or not data.IsEventCharacter then
		console.Feedback(ply, "ERROR", "That character either doesn't exist or isn't an event character!")

		return
	end

	-- if Character.GetByID(id) then inform them

	Character.Delete(id)
end)

delete:SetCategory("Event Character Commands")
delete:SetDescription("Deletes an event character")
delete:SetExecutionContext(console.Server)
delete:SetAccess(console.IsAdmin)

delete:AddParameter(console.Number())





local create = console.AddCommand("rpa_character_create", function(ply, target, generator)
	CharacterGen.Run(target, generator.ClassName)

	Log.Write("admin_character_create", ply, target, generator.ClassName)

	console.Feedback(target, "NOTICE", "%s given you a new character with type: %s", ply, generator.ClassName)
	console.Feedback(ply, "NOTICE", "You've given %s a new character with type: %s", target, generator.ClassName)
end)

create:SetCategory("Character Commands")
create:SetDescription("Creates a character for someone")
create:SetExecutionContext(console.Server)
create:SetAccess(console.IsAdmin)

create:AddParameter(console.Player({SingleTarget = true}))
create:AddParameter(console.CharacterGen())





local createEvent = console.AddCommand("rpa_character_create_event", function(ply, target, generator)
	CharacterGen.Run(target, generator.ClassName, true)

	Log.Write("admin_character_create_event", ply, target, generator.ClassName)

	console.Feedback(target, "NOTICE", "%s given you an event character with type: %s", ply, generator.ClassName)
	console.Feedback(ply, "NOTICE", "You've given %s an event character with type: %s", target, generator.ClassName)
end)

createEvent:SetCategory("Character Commands")
createEvent:SetDescription("Creates an event character for someone")
createEvent:SetExecutionContext(console.Server)
createEvent:SetAccess(console.IsAdmin)

createEvent:AddParameter(console.Player({SingleTarget = true}))
createEvent:AddParameter(console.CharacterGen())
