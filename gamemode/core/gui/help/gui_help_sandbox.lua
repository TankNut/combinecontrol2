local func = function()
	local str = ""

	str = str .. "<giant><b>Sandbox Permissions:</b></giant>"
	str = str .. "\nTool, Physics, and Prop Spawning permissions are all contained to a single tooltrust permission in CombineControl. By default, you will be given untrusted access to these tools which will allow some basic access to the Garry's Mod sandbox. Server administrators have the ability to individually modify a player's tooltrust at any given time, including issuing a tooltrust ban to prevent abuse."

	-- Scoreboard Recognition
	str = str .. "\n\n<giant><b>Scoreboard Badges:</b></giant>"
	str = str .. "\nPlayers who have either been banned from accessing the Garry's Mod sandbox or granted advanced access to additional tools are represented with a scoreboard badge that both yourself and all server administrators can see. Other players will not br provided access to see this information."

	-- Tooltrust Levels
	local function addTooltrustLevel(tier, description)
		str = str .. string.format("\n\t%s - <dark>%s</dark>", tier, description)
	end

	str = str .. "\n\n<giant><b>Trust Levels:</b></giant>"
	addTooltrustLevel("banned", "Restricted access to prevent sandbox interactions.")
	addTooltrustLevel("untrusted", "Default access with minimal tools, decreased entity counts, and non-solid props.")
	addTooltrustLevel("trusted", "Standard access with standard tools, standard entity counts, and solid props.")
	addTooltrustLevel("advanced", "Applied-for access with advanced tools, increased entity counts, and solid props.")

	return str
end

hook.Add("PopulateHelpMenu", "sandbox", function(panel)
	panel:AddMenu(4, "Sandbox Permissions", func)
end)

