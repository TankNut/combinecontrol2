local func = function()
	local str = ""

	str = str .. "<giant><b>Character Generators:</b></giant>"
	str = str .. "\n\tThe 'Create event character' button as well as the <dark>rpa_character_create</dark> commands use character generators. These are pieces of code that will create a new character without any user input, designed to help quickly setup event or normal characters where full character creation either isn't available, takes too long or the player isn't trusted with access."

	str = str .. "\n\n<giant><b>Available Generators:</b></giant>"

	for id, gen in SortedPairsByMemberValue(CharacterGen.List, "Name") do
		str = str .. string.format("\n\t%s - <dark>%s</dark>", id, gen.Name)
	end

	return str
end

hook.Add("PopulateHelpMenu", "admin_chargen", function(panel)
	panel:AddAdminMenu(2, "Character Generators", func)
end)

