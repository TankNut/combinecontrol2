local text = [[<giant><b>Console Commands</b></giant>
	A list of available console commands is available by using the <dark>commands</dark> command. This lists all of the commands that are available to you and allows you to filter them based on their name.

	By inputting a space after typing out a command, you'll see both a description and a syntax list. Arguments listed with (parenthesis) around them are required, whereas [brackets] are optional.
]]

hook.Add("PopulateHelpMenu", "console", function(panel)
	if lp:IsAdmin() then
		panel:AddMenu(6, "Console Commands", text)
	end
end)

