local func = function()
	local str = ""

	str = str .. "<giant><b>Character Flags:</b></giant>"
	str = str .. "\n\tEach character has a flag assigned to them, this flag determines many mechanical details about the character such as their team, stats, appearance and types of equipment they can use. Flags can be changed using <dark>rpa_character_flag</dark> at any time but are generally set once while setting up the character."
	str = str .. string.format("\n\n\tCharacters start with the <dark>%s</dark> flag by default.", GAMEMODE.DefaultFlag)

	str = str .. "\n\n<giant><b>Available Flags:</b></giant>"

	for id, flag in SortedPairsByMemberValue(CharacterFlag.List, "Name") do
		str = str .. string.format("\n\t%s - <dark>%s</dark>", id, flag.Name)
	end

	return str
end

hook.Add("PopulateHelpMenu", "admin_flags", function(panel)
	panel:AddAdminMenu(1, "Character Flags", func)
end)

