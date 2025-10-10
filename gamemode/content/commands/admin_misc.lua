local restart = console.AddCommand("rpa_restart", function(ply)
	Chat.Send("ADMINWARN", console.FormatMessage("%s is restarting the server in 5 seconds", ply))

	Log.Write("admin_restart", ply)

	timer.Simple(5, function()
		game.ConsoleCommand("changelevel " .. game.GetMap() .. "\n")
	end)
end)

restart:SetCategory("Server Commands")
restart:SetDescription("Restarts the server on the current map")
restart:SetExecutionContext(console.Server)
restart:SetAccess(console.IsAdmin)

local changeLevel = console.AddCommand("rpa_changelevel", function(ply, map)
	local maps = game.GetMapList()
	if not table.HasValue(maps, map) then
		local lines = {"<c=white>-- Valid Maps --</c>"}

		for _, name in ipairs(maps) do
			table.insert(lines, "  " .. name)
		end

		console.Feedback(ply, "NOTICE", "Sent all valid maps to your console")
		console.Feedback(ply, "CONSOLE", table.concat(lines, "\n"))

		return
	end

	Chat.Send("ADMINWARN", console.FormatMessage("%s is changing the map to %s in 5 seconds", ply, map))

	GAMEMODE:SetAutoMapOverride(map)
	Log.Write("admin_changelevel", ply, map)

	timer.Simple(5, function()
		game.ConsoleCommand("changelevel " .. map .. "\n")
	end)
end)

changeLevel:SetCategory("Server Commands")
changeLevel:SetDescription("Changes the current map from one to another")
changeLevel:SetExecutionContext(console.Server)
changeLevel:SetAccess(console.IsAdmin)

changeLevel:AddOptional(console.String())

local disableAI = console.AddCommand("rpa_ai_disable", function (ply, bool)
	Chat.Send("NOTICE", console.FormatMessage("%s has %s AI thinking", ply, bool and "disabled" or "enabled"), player.GetAdmins())

	Log.Write("admin_variable_set", ply, "ai_disable", bool and 1 or 0)

	GAMEMODE:SetAIDisabled(bool)
end)

disableAI:SetCategory("Server Commands")
disableAI:SetDescription("Enables/disables AI thinking")
disableAI:SetExecutionContext(console.Server)
disableAI:SetAccess(console.IsAdmin)

disableAI:AddParameter(console.Bool())

local ignoreAI = console.AddCommand("rpa_ai_notarget", function (ply, bool)
	Chat.Send("NOTICE", console.FormatMessage("%s has turned %s NPC's ignoring players", ply, bool and "on" or "off"), player.GetAdmins())

	Log.Write("admin_variable_set", ply, "ai_notarget", bool and 1 or 0)

	GAMEMODE:SetAINoTarget(bool)
end)

ignoreAI:SetCategory("Server Commands")
ignoreAI:SetDescription("Enables/disables NPC's ignoring players")
ignoreAI:SetExecutionContext(console.Server)
ignoreAI:SetAccess(console.IsAdmin)

ignoreAI:AddParameter(console.Bool())

local yell = console.AddCommand("rpa_yell", function(ply, message)
	Log.Write("admin_yell", ply, message)

	Chat.Send("ADMINYELL", {Name = console.RPName(ply), Text = message})
end)

yell:SetDescription("Sends a large text message to all players")
yell:SetExecutionContext(console.Server)
yell:SetAccess(console.IsAdmin)

yell:AddParameter(console.String())

local propInfo = console.AddCommand("rpa_propinfo", function(ply)
	local ent = ply:GetEyeTrace().Entity

	if not IsValid(ent) then
		console.Feedback(ply, "NOTICE", "You're not looking at an entity!")

		return
	end

	console.Feedback(ply, "CONSOLE", table.concat(hook.Run("GetPropInfo", ply, ent), "\n"))
end)

propInfo:SetDescription("Get information about whatever prop you're looking at")
propInfo:SetExecutionContext(console.Server)
propInfo:SetAccess(console.IsAdmin)
propInfo:SetNoConsole()

local toggleSaved = console.AddCommand("rpa_togglesaved", function(ply)
	local ent = ply:GetEyeTrace().Entity

	if IsValid(ent) and PermaProps.Whitelist[ent:GetClass()] then
		-- Context that gets passed to OnPermaPropChanged to write to PermaPropInfo
		Admin = ply

		local new = not ent:PermaProp()

		ent:SetPermaProp(new)
		Log.Write("admin_togglesaved",
			ply,
			ent.AttachedEntity and ent.AttachedEntity:GetModel() or ent:GetModel(),
			new)

		Admin = nil
	end
end)

toggleSaved:SetDescription("Toggles persistence on a prop or effect")
toggleSaved:SetExecutionContext(console.Server)
toggleSaved:SetAccess(console.IsAdmin)
toggleSaved:SetNoConsole()

local seeAll = console.AddCommand("rpa_seeall", function(ply)
	Settings.Set("SeeAll", not Settings.Get("SeeAll"))
end)

seeAll:SetDescription("Toggles SeeAll on or off")
seeAll:SetExecutionContext(console.ClientOnly)
seeAll:SetAccess(console.IsAdmin)

local teamHidden = console.AddCommand("rpa_setteamhidden", function(ply, enum, hidden)
	Chat.Send("NOTICE", console.FormatMessage("%s has %s the %s team from the scoreboard", ply, hidden and "hidden" or "unhidden", Team.Get(enum).Name), player.GetAdmins())

	Team.SetHidden(enum, hidden)

	Log.Write("admin_hideteam", ply, enum, hidden)
end)

teamHidden:SetCategory("Server Commands")
teamHidden:SetDescription("Toggles a team's hidden state on the scoreboard")
teamHidden:SetExecutionContext(console.Server)
teamHidden:SetAccess(console.IsAdmin)

teamHidden:AddParameter(console.Team())

teamHidden:AddParameter(console.Bool())
