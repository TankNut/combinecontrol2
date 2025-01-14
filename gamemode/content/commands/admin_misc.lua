local restart = console.AddCommand("rpa_restart", function(ply)
	GAMEMODE:WriteLog("admin_restart", {Admin = GAMEMODE:LogPlayer(ply)})
	Chat.Send("GENERIC", {
		Text = console.FormatMessage("<giant>%s is restarting the server in 5 seconds", ply),
		Color = Color(200, 0, 0)
	})

	timer.Simple(5, function()
		game.ConsoleCommand("changelevel " .. game.GetMap() .. "\n")
	end)
end)

restart:SetDescription("Restarts the server on the current map")
restart:SetExecutionContext(console.Server)
restart:SetAccess(console.IsAdmin)

local function printMaps(maps)
	MsgC(Color(214, 172, 19), "Valid Maps:\n")
	for _, map in ipairs(maps) do
		MsgC(Color(229, 201, 98, 255), "\t", map, "\n")
	end
end

if CLIENT then
	netstream.Hook("MapList", function(data)
		printMaps(data.Maps)
	end)
end

local changeLevel = console.AddCommand("rpa_changelevel", function(ply, map)
	local maps = game.GetMapList()
	if not table.HasValue(maps, map) then
		if IsValid(ply) then
			netstream.Send(ply, "MapList", {
				Maps = maps
			})
		else
			printMaps(maps)
		end

		return
	end

	GAMEMODE:WriteLog("admin_changelevel", {Admin = GAMEMODE:LogPlayer(ply), Map = map})
	Chat.Send("GENERIC", {
		Text = console.FormatMessage("<giant>%s is changing the map to %s in 5 seconds", ply, map),
		Color = Color(200, 0, 0)
	})

	file.Write("cc_maps/" .. game.GetPort() .. ".txt", map)
	timer.Simple(5, function()
		game.ConsoleCommand("changelevel " .. map .. "\n")
	end)
end)

changeLevel:SetDescription("Changes the current map from one to another")
changeLevel:SetExecutionContext(console.Server)
changeLevel:SetAccess(console.IsAdmin)

changeLevel:AddOptional(console.String())

local aiDisabled = console.AddCommand("rpa_aidisabled", function (ply, bool)
	Chat.Send("NOTICE", console.FormatMessage("%s has %s AI thinking", ply, bool and "disabled" or "enabled"), player.GetAdmins())

	RunConsoleCommand("ai_disabled", bool and 1 or 0)
end)

aiDisabled:SetDescription("Updates the AI Disabled server console variable")
aiDisabled:SetExecutionContext(console.Server)
aiDisabled:SetAccess(console.IsAdmin)

aiDisabled:AddParameter(console.Bool())

local yell = console.AddCommand("rpa_yell", function(ply, message)
	Chat.Send("ADMINYELL", {Name = console.RPName(ply), Text = message})
end)

yell:SetDescription("Announces a large-text message to all players")
yell:SetExecutionContext(console.Server)
yell:SetAccess(console.IsAdmin)

yell:AddParameter(console.String())

local heal = console.AddCommand("rpa_heal", function(ply, targets)
	for _,target in pairs(targets) do
		if target:Health() > target:GetMaxHealth() then
			continue -- Don't reset the health of admins using rpa_sethealth.
		end

		target.ArmorFraction = 1

		target:SetHealth(target:GetMaxHealth())
		target:SetArmor(target:GetMaxArmor())

		GAMEMODE:WriteLog("admin_heal", {Admin = GAMEMODE:LogPlayer(ply), Ply = GAMEMODE:LogPlayer(target), Char = GAMEMODE:LogCharacter(target), Self = ply == target})

		console.Feedback(target, "NOTICE", "%s has healed you", ply)
	end

	local targetCount = table.Count(targets)

	if targetCount == 1 then
		console.Feedback(ply, "NOTICE", "You've healed %s", targets[1])
	else
		console.Feedback(ply, "NOTICE", "You've healed %d players", targetCount)
	end
end)

heal:SetDescription("Heals one or more players to full health and armor")
heal:SetExecutionContext(console.Server)
heal:SetAccess(console.IsAdmin)

heal:AddParameter(console.Player({
	SingleTarget = false,
	CheckImmunity = false,
	NoSelfTarget = false
}))

local setHealth = console.AddCommand("rpa_sethealth", function(ply, target, max)
	target:SetHealth(max)

	console.Feedback(ply, "NOTICE", "You've set %s's health to \"%d\"", target, max)
	console.Feedback(target, "NOTICE", "%s set your health to \"%d\"", ply, max)
end)

setHealth:SetDescription("Manually sets a player's health bar")
setHealth:SetExecutionContext(console.Server)
setHealth:SetAccess(console.IsAdmin)

setHealth:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = false,
	NoSelfTarget = false
}))

setHealth:AddParameter(console.Number({
	validate.Min(0),
	validate.Max(100000)
}))

local deadmin = console.AddCommand("rpa_deadmin", function(ply)
	ply:SetUserGroup("user")

	console.Feedback(ply, "NOTICE", "You've deadminned yourself")
	Chat.Send("NOTICE", string.format("%s has deadminned themselves.", ply:Nick()), player.GetAdmins())
end)

deadmin:SetDescription("Removes yourself from the admin role")
deadmin:SetExecutionContext(console.Server)
deadmin:SetAccess(console.IsAdmin)
