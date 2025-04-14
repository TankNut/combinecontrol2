local listEventCharacters = console.AddCommand("rpa_listeventcharacters", function(ply)
	local characters = GAMEMODE.Database:Query([[
SELECT rp_characters.id,
       rp_characters.SteamID,
       COALESCE(rp_characters.NameOverride, rp_characters.Name) as Name,
       rp_characters.Flag,
       rp_players.LastNick
FROM rp_characters
  LEFT JOIN rp_players ON rp_characters.SteamID = rp_players.SteamID
WHERE rp_characters.EventCharacter = 1 AND rp_characters.Deleted_At IS NULL AND rp_characters.SteamID != "BOT"]])

	if #characters < 1 then
		console.Feedback(ply, "ERROR", "No event characters exist")

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

listEventCharacters:SetCategory("Event Character Commands")
listEventCharacters:SetDescription("Lists all event characters")
listEventCharacters:SetExecutionContext(console.Server)
listEventCharacters:SetAccess(console.IsAdmin)
