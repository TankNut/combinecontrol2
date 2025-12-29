local func = function()
	local str = ""

	str = str .. "<giant><b>Sandbox Access:</b></giant>"
	str = str .. "\n	Tool, Physics, and Prop Spawning permissions are all contained to a single tooltrust permission in CombineControl. By default, you will be given untrusted access to these tools which will allow some basic access to the Garry's Mod sandbox. Server administrators have the ability to individually modify a player's tooltrust at any given time, including issuing a tooltrust ban to prevent abuse."

	-- Scoreboard Recognition
	str = str .. "\n\n<big><b>Scoreboard Badges:</b></big>"
	str = str .. "\n	Players who have either been banned from accessing the Garry's Mod sandbox or granted advanced access to additional tools are represented with a scoreboard badge that both yourself and all server administrators can see. Other players will not be able to see your badge for either permission level."

	-- Tooltrust Levels
	local function addTooltrustLevel(tier, description)
		str = str .. string.format("\n\t%s - <dark>%s</dark>", tier, description)
	end

	str = str .. "\n\n<big><b>Trust Levels:</b></big>"

	addTooltrustLevel("banned", "No access at all.")
	addTooltrustLevel("untrusted", "The default access with the bare minimum of tools, restrictive entity limits, and non-solid props.")
	addTooltrustLevel("trusted", "Standard access with access to standard tools, and solid props.")
	addTooltrustLevel("advanced", "Extended access with advanced tools and increased entity limits.")

	return str
end

hook.Add("PopulateHelpMenu", "sandbox", function(panel)
	panel:AddMenu(5, "Sandbox Access", func)
end)

