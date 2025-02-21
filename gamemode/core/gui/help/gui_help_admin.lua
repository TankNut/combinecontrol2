local func = function()
	local categories = {}
	local miscellanious = {}

	for name, command in SortedPairs(console.Commands) do
		if not string.StartsWith(name, "rpa_") or not console.IsVisible(command) or not command.CanAccess(lp) then
			continue
		end

		if not command.Category then
			miscellanious[name] = command

			continue
		end

		local category = command.Category
		categories[category] = categories[category] or {}
		categories[category][name] = command
	end

	local first = false
	local str = ""

	str = str .. "<giant><b>Admin Commands:</b></giant>\n"
	str = str .. "Various commands and utilities to help administrators manage the server, categorized into sections loosely based on how similar verious commands are. Parameters wrapped in <b>(parenthesis)</b> are required while those wrapped in <b>[brackets]</b> are optional with, potentially, a non-null default value."

	local function addCommandCategory(category, commands)
		str = str .. string.format("%s<big><b>%s:</b></big>", first and "" or "\n\n", category)
		first = false

		for name, command in SortedPairs(commands) do
			str = str .. string.format("\n\t%s %s\n\t\t<dark>- %s</dark>", name, command:GetUsage(), command.Description)
		end
	end

	-- Normal Commands
	for category, commands in SortedPairs(categories) do
		addCommandCategory(category, commands)
	end

	-- Everything Else
	addCommandCategory("Miscellanious Commands", miscellanious)

	return str
end

hook.Add("PopulateHelpMenu", "admin", function(panel)
	if lp:IsAdmin() then
		panel:AddMenu(5, "Admin Commands", func)
	end
end)

