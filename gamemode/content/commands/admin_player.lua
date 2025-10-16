local toolTrustMapping = {
	banned = TOOLTRUST_BANNED,
	untrusted = TOOLTRUST_UNTRUSTED,
	trusted = TOOLTRUST_TRUSTED,
	advanced = TOOLTRUST_ADVANCED
}





local setToolTrust = console.AddCommand("rpa_player_tooltrust", function (ply, target, trust)
	local toolTrustLevel = toolTrustMapping[trust]

	target:SetToolTrust(toolTrustLevel)
	target:UpdateLoadout()

	console.Feedback(ply, "NOTICE", "You've set %s's tool trust to %s", target, trust)
	console.Feedback(target, "NOTICE", "%s has set your tool trust to %s", ply, trust)

	Log.Write("admin_player_set", ply, target, "ToolTrust", trust)
end)

setToolTrust:SetCategory("Player Commands")
setToolTrust:SetDescription("Sets a player's toolgun access")
setToolTrust:SetExecutionContext(console.Server)
setToolTrust:SetAccess(console.IsAdmin)

setToolTrust:AddParameter(console.Player({SingleTarget = true, NoAdmins = true}))
setToolTrust:AddParameter(console.String({
	validate.InList(table.GetKeys(toolTrustMapping))
}))





local heal = console.AddCommand("rpa_heal", function(ply, targets)
	for _, target in ipairs(targets) do
		-- Don't reset the health of rpa_sethealth'ed players
		if target:Health() < target:GetMaxHealth() then
			target:SetHealth(target:GetMaxHealth())
		end

		-- Ditto for rpa_setarmor
		if target:Armor() < target:GetMaxArmor() then
			target:SetArmor(target:GetMaxArmor())
		end

		console.Feedback(target, "NOTICE", "%s has healed you", ply)

		Log.Write("admin_player_heal", ply, target)
	end

	console.Feedback(ply, "NOTICE", "You've healed %s", targets)
end)

heal:SetCategory("Player Commands")
heal:SetDescription("Heals one or more players to full health and armor")
heal:SetExecutionContext(console.Server)
heal:SetAccess(console.IsAdmin)

heal:AddParameter(console.Player())





local setHealth = console.AddCommand("rpa_player_health", function(ply, targets, health)
	for _, target in ipairs(targets) do
		target:SetHealth(health)

		console.Feedback(target, "NOTICE", "%s has set your health to %d", ply, health)

		Log.Write("admin_player_set", ply, target, "Health", health)
	end

	console.Feedback(ply, "NOTICE", "You've set the health of %s to %d", targets, health)
end)

setHealth:SetCategory("Player Commands")
setHealth:SetDescription("Sets a player's health")
setHealth:SetExecutionContext(console.Server)
setHealth:SetAccess(console.IsAdmin)

setHealth:AddParameter(console.Player())
setHealth:AddParameter(console.Number())





local setArmor = console.AddCommand("rpa_player_armor", function(ply, targets, armor)
	for _, target in ipairs(targets) do
		target:SetArmor(armor)

		console.Feedback(target, "NOTICE", "%s has set your armor to %d", ply, armor)

		Log.Write("admin_player_set", ply, target, "Armor", armor)
	end

	console.Feedback(ply, "NOTICE", "You've set the armor of %s to %d", targets, armor)
end)

setArmor:SetCategory("Player Commands")
setArmor:SetDescription("Sets a player's armor")
setArmor:SetExecutionContext(console.Server)
setArmor:SetAccess(console.IsAdmin)

setArmor:AddParameter(console.Player())
setArmor:AddParameter(console.Number())





local kill = console.AddCommand("rpa_kill", function(ply, target)
	target:Kill()

	console.Feedback(target, "NOTICE", "%s killed you", ply)

	Log.Write("admin_player_kill", ply, target)
end)

kill:SetCategory("Player Commands")
kill:SetChatAlias("kill")
kill:SetDescription("Kills a player")
kill:SetExecutionContext(console.Server)
kill:SetAccess(console.IsAdmin)

kill:AddParameter(console.Player({SingleTarget = true, CheckImmunity = true}))





local slap = console.AddCommand("rpa_slap", function(ply, target)
	target:SetVelocity(Vector(math.random(-200, 200), math.random(-200, 200), 0))
	target:TakeDamage(10)

	console.Feedback(target, "NOTICE", "%s has slapped you", ply)
	console.Feedback(ply, "NOTICE", "You've slapped %s", target)

	Log.Write("admin_player_slap", ply, target)
end)

slap:SetCategory("Player Commands")
slap:SetChatAlias("slap")
slap:SetDescription("Slaps a player")
slap:SetExecutionContext(console.Server)
slap:SetAccess(console.IsAdmin)

slap:AddParameter(console.Player({SingleTarget = true, CheckImmunity = true}))





local setAlias = console.AddCommand("rpa_player_alias", function(ply, steamID, alias)
	local target = player.GetBySteamID(steamID)
	local name = target and target:Nick() or steamID

	if target then
		target:SetAlias(alias)
	else
		local query = GAMEMODE.Database:Upsert("rp_players")
			query:Insert("SteamID", steamId)
			query:Insert("Alias", alias)
		query:Execute()
	end

	Log.Write("admin_player_set",
		ply,
		target or {
			SteamID = function() return steamID end,
			Nick = function() return name end,
		},
		"Alias",
		alias == "" and "N/A" or alias)
end)

setAlias:SetCategory("Player Commands")
setAlias:SetDescription("Sets a player's alias name")
setAlias:SetExecutionContext(console.Server)
setAlias:SetAccess(console.IsAdmin)

setAlias:AddParameter(console.SteamID({SingleTarget = true}))
setAlias:AddParameter(console.String({validate.Max(32)}))





local setScale = console.AddCommand("rpa_player_scale", function (ply, target, scale)
	Log.Write("admin_player_set", ply, target, "Scale", scale)

	target:SetScale(scale)

	console.Feedback(ply, "NOTICE", "You've set %s's character scale to %d", target, scale)
	console.Feedback(target, "NOTICE", "%s has set your character scale to %d", ply, scale)
end)

setScale:SetCategory("Player Commands")
setScale:SetDescription("Updates a player's current size")
setScale:SetExecutionContext(console.Server)
setScale:SetAccess(console.IsAdmin)

setScale:AddParameter(console.Player({SingleTarget = true}))
setScale:AddParameter(console.Number({validate.Min(0.1), validate.Max(10)}))
