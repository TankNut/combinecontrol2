local func = function(ply)
	local str = ""

	-- Menu Commands
	local function addMenuCommand(name, binding)
		local lookup = input.LookupBinding(binding, true)

		str = str .. string.format("\n\t%s - %s <dark>(%s)</dark>", lookup and string.upper(lookup) or "Unbound", name, binding)
	end

	str = str .. "<giant><b>In-Game Menus:</b></giant>"

	addMenuCommand("Help Menu", "gm_showhelp")
	addMenuCommand("Character Selection", "gm_showteam")
	addMenuCommand("Player Menu", "gm_showspare1")
	addMenuCommand("Administration Menu", "gm_showspare2")
	addMenuCommand("Context Menu", "+menu_context")

	str = str .. [[
	

<giant><b>Keybindings</b></giant>
	Gamemode specific keybindings can be found in the keybinds section of your settings, part of the player menu. There you can also rebind them to other keys.
]]

	return str
end

hook.Add("PopulateHelpMenu", "keybinds", function(panel)
	panel:AddMenu(2, "Menus and Keybindings", func)
end)

