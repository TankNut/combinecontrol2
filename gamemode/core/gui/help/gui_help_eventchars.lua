local text = [[<giant><b>Event Characters</b></giant>
	Event characters are a specific type of character that can be created through admins or character selection if you have the correct permissions. They function the same as normal characters, though with a few exceptions.

	Most notably, event characters can be both deleted and have their ownership changed by admins even when the player is offline, this ensures that important event characters are always available even if the players themselves aren't, and that people can't make off with special characters as easily.
]]

hook.Add("PopulateHelpMenu", "eventchars", function(panel)
	panel:AddMenu(4, "Event Characters", text)
end)
