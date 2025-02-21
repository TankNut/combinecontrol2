local func = function()
	local str = ""

	-- The Basics
	str = str .. "<giant><b>Character Chat:</b></giant>"
	str = str .. "\nEntering anything into your chatbox will make you speak using in-character text, which is limited by range and can be blocked by world geometry. Additional commands exist to help facilitate additional interaction, functionality, and the use of unique character languages."

	-- Chat Commands (Minus Set Language)
	str = str .. "\n\n<big><b>Chat Commands:</b></big>"

	for name, message in SortedPairs(Chat.List) do
		if table.Count(message.Commands) == 0 and table.Count(message.Aliases) == 0 or name == "Set language" then
			continue
		end

		local main = nil
		local alts = {}

		for index, command in pairs(message.Commands) do
			if index == 1 then
				main = "/" .. command
				continue
			end

			table.insert(alts, "/" .. command)
		end

		for _, alias in pairs(message.Aliases) do
			table.insert(alts, alias)
		end

		str = str .. string.format("\n\t%s%s - <dark>%s</dark>",
			main,
			#alts == 0 and "" or " (" .. table.concat(alts, ", ") .. ")",
			message.Description)
	end

	-- Language Command Syntax
	str = str .. "\n\n<big><b>Using Language Commands:</b></big>"
	str = str .. "\nOn top of using language commands to speak directly or set your default language, you can preface chat commands with the language you want to use. Using <dark>/rus.y</dark>, for example, will cause you to yell in Russian, but won't change your current language."
	str = str .. "\n\n\t/[lang] - <dark>Sets a default speaking language (/eng will set you back to default).</dark>"
	str = str .. "\n\t/[lang].[cmd] [text] - <dark>Uses a command with the given language.</dark>"

	-- Available Languages
	str = str .. "\n\n<big><b>Available Languages:</b></big>"

	for _, lang in SortedPairs(Language.List) do
		str = str .. string.format("\n\t/%s - <dark>%s</dark>", lang.Command, lang.Name)
	end

	return str
end

hook.Add("PopulateHelpMenu", "chat", function(panel)
	panel:AddMenu(3, "Character Chat", func)
end)
