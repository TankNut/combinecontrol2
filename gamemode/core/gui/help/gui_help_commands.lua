local func = function(ply)
	local str = ""

	local playerCommands = {}

	for name, command in SortedPairs(console.Commands) do
		if not string.StartsWith(name, "rp_") or not console.IsVisible(command) or not command:CanAccess(lp) then
			continue
		end

		playerCommands[name] = command
	end

	-- Menu Commands
	local function addMenuCommand(name, binding)
		local lookup = input.LookupBinding(binding, true)

		str = str .. string.format("\n\t%s - %s <dark>(or use %s)</dark>", lookup and string.upper(lookup) or "Unbound", name, binding)
	end

	str = str .. "<giant><b>In-Game Menus:</b></giant>"
	addMenuCommand("Help Menu", "gm_showhelp")
	addMenuCommand("Character Selection", "gm_showteam")
	addMenuCommand("Player Menu", "gm_showspare1")
	addMenuCommand("Administration Menu", "gm_showspare2")
	addMenuCommand("Context Menu", "+menu_context")

	-- Weapon Holstering
	str = str .. "\n\n<giant><b>Weapon Holstering:</b></giant>\n\tB - Toggle Holster <dark>(or use rp_toggleholster)</dark>"

	-- Non-Admin Commands
	if table.Count(playerCommands) > 0 then
		str = str .. "\n\n<giant><b>Additional Commands:</b></giant>"

		for name, command in SortedPairs(playerCommands) do
			str = str .. string.format("\n\t%s - <dark>%s</dark>", name, command.Description)
		end
	end

	return str
end

hook.Add("PopulateHelpMenu", "commands", function(panel)
	panel:AddMenu(2, "Menus and Commands", func)
end)

