local toolTrustMapping = {
	banned = TOOLTRUST_BANNED,
	untrusted = TOOLTRUST_UNTRUSTED,
	trusted = TOOLTRUST_TRUSTED,
	advanced = TOOLTRUST_ADVANCED
}

local setToolTrust = console.AddCommand("rpa_settooltrust", function (ply, target, trust)
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

setToolTrust:AddParameter(console.Player({
	SingleTarget = true,
	NoAdmin = true
}))

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

	if #targets > 1 then
		console.Feedback(ply, "NOTICE", "You've healed %d players", #targets)
	else
		console.Feedback(ply, "NOTICE", "You've healed %s", targets[1])
	end
end)

heal:SetCategory("Player Commands")
heal:SetDescription("Heals one or more players to full health and armor")
heal:SetExecutionContext(console.Server)
heal:SetAccess(console.IsAdmin)

heal:AddParameter(console.Player())

local setHealth = console.AddCommand("rpa_sethealth", function(ply, targets, health)
	for _, target in ipairs(targets) do
		target:SetHealth(health)

		console.Feedback(target, "NOTICE", "%s has set your health to %d", ply, health)

		Log.Write("admin_player_set", ply, target, "Health", health)
	end

	if #targets > 1 then
		console.Feedback(ply, "NOTICE", "You've set %d players' health to %d", #targets, health)
	else
		console.Feedback(ply, "NOTICE", "You've set %s's health to %d", targets[1], health)
	end
end)

setHealth:SetCategory("Player Commands")
setHealth:SetDescription("Sets a player's health")
setHealth:SetExecutionContext(console.Server)
setHealth:SetAccess(console.IsAdmin)

setHealth:AddParameter(console.Player())
setHealth:AddParameter(console.Number())

local setArmor = console.AddCommand("rpa_setarmor", function(ply, targets, armor)
	for _, target in ipairs(targets) do
		target:SetArmor(armor)

		console.Feedback(target, "NOTICE", "%s has set your armor to %d", ply, armor)

		Log.Write("admin_player_set", ply, target, "Armor", armor)
	end

	if #targets > 1 then
		console.Feedback(ply, "NOTICE", "You've set %d players' armor to %d", #targets, armor)
	else
		console.Feedback(ply, "NOTICE", "You've set %s's armor to %d", targets[1], armor)
	end
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

kill:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = true
}))

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

slap:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = true
}))

local listCharacters = console.AddCommand("rpa_listcharacters", function(ply, steamid)
	local target = player.GetBySteamID(steamid)
	local name = target and string.format("%s (%s)", target:Nick(), steamid) or steamid
	local characters = GAMEMODE.Database:Query("SELECT `id`, COALESCE(`NameOverride`, `Name`) AS `Name`, `Flag`, `EventCharacter` FROM rp_characters WHERE `SteamID` = :steamId AND `Deleted_At` IS NULL", {
		steamId = steamid
	})

	if #characters < 1 then
		console.Feedback(ply, "ERROR", "No characters exist for %s", name)

		return
	end

	local defaultFlag = CharacterFlag.Get(GAMEMODE.DefaultFlag).Name
	local lines = {string.format("<c=white>-- Character list for: %s (%d character%s) --</c>", name, #characters, #characters > 1 and "s" or "")}

	for _, character in pairs(characters) do
		local flag = defaultFlag

		if character.Flag then
			flag = CharacterFlag.Get(character.Flag).Name or character.Flag
		end

		table.insert(lines, string.format("  CharID %d: %s%s - %s%s",
			character.id,
			character.Name,
			character.NameOverride and " (" .. character.NameOverride .. ")" or "",
			flag,
			character.EventCharacter and " (EVENT CHARACTER)" or ""
		))
	end

	console.Feedback(ply, "NOTICE", "Sent %s's character list to your console", name)
	console.Feedback(ply, "CONSOLE", table.concat(lines, "\n"))
end)

listCharacters:SetCategory("Player Commands")
listCharacters:SetDescription("Lists all characters created by a player")
listCharacters:SetExecutionContext(console.Server)
listCharacters:SetAccess(console.IsAdmin)

listCharacters:AddParameter(console.SteamID({
	SingleTarget = true
}))

local setAlias = console.AddCommand("rpa_setalias", function(ply, steamId, alias)
	local target = player.GetBySteamID(steamId)
	local name = target and target:Nick() or steamId

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

setAlias:AddParameter(console.SteamID({
	SingleTarget = true
}))

setAlias:AddParameter(console.String({
	validate.Max(32),
}))

local setScale = console.AddCommand("rpa_setscale", function (ply, target, scale)
	Log.Write("admin_player_set", ply, target, "Scale", scale)

	target:SetScale(scale)

	console.Feedback(ply, "NOTICE", "You've set %s's character scale to %d", target, scale)
	console.Feedback(target, "NOTICE", "%s has set your character scale to %d", ply, scale)
end)

setScale:SetCategory("Player Commands")
setScale:SetDescription("Updates a player's current size")
setScale:SetExecutionContext(console.Server)
setScale:SetAccess(console.IsAdmin)

setScale:AddParameter(console.Player({
	SingleTarget = true
}))

setScale:AddParameter(console.Number({
	validate.Min(0.1),
	validate.Max(10),
}))
