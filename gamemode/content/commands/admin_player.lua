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

	GAMEMODE:LogAdmin("[S] " .. ply:Nick() .. " changed " .. target:Nick() .. "'s tooltrust to " .. tostring(trust), ply)

	console.Feedback(ply, "NOTICE", "You've set %s's tool trust to %s", target, trust)
	console.Feedback(target, "NOTICE", "%s has set your tool trust to %s", ply, trust)
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

local oocMute = console.AddCommand("rpa_oocmute", function (ply, target, bool)
	local new = 1 - target:OOCMuted()

	if bool != nil then
		new = bool and 1 or 0
	end

	target:SetOOCMuted(new)

	GAMEMODE:LogAdmin("[S] " .. ply:Nick() .. " changed player " .. target:CharacterName() .. "'s ooc mute to " .. tostring(new == 1), ply)

	console.Feedback(ply, "NOTICE", "You %s %s from OOC chat", new == 1 and "muted" or "unmuted", target)
	console.Feedback(target, "NOTICE", "%s has %s you from OOC chat", ply, new == 1 and "muted" or "unmuted")
end)

oocMute:SetCategory("Player Commands")
oocMute:SetChatAlias("mute")
oocMute:SetDescription("Mute or unmutes a player from OOC chat")
oocMute:SetExecutionContext(console.Server)
oocMute:SetAccess(console.IsAdmin)

oocMute:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = true
}))

oocMute:AddOptional(console.Bool())

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

		GAMEMODE:WriteLog("admin_heal", {Admin = GAMEMODE:LogPlayer(ply), Ply = GAMEMODE:LogPlayer(target), Char = GAMEMODE:LogCharacter(target), Self = ply == target})

		console.Feedback(target, "NOTICE", "%s has healed you", ply)
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

	GAMEMODE:WriteLog("admin_kill", {Admin = GAMEMODE:LogPlayer(ply), Ply = GAMEMODE:LogPlayer(target), Char = GAMEMODE:LogCharacter(target)})
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

	GAMEMODE:WriteLog("admin_slap", {Admin = GAMEMODE:LogPlayer(ply), Ply = GAMEMODE:LogPlayer(target), Char = GAMEMODE:LogCharacter(target)})
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

local function printCharacterList(data)
	local defaultFlag = CharacterFlag.Get(CharacterVar.Vars["CharacterFlag"].Default).Name

	MsgC(Color(214, 172, 19), string.format("Character list for: %s (%d character%s)\n", data.Name, #data.Characters, #data.Characters > 1 and "s" or ""))

	for _, character in pairs(data.Characters) do
		MsgC(Color(229, 201, 98, 255), "\t", string.format("CharID %d: %s%s - %s",
				character.id,
				character.Name,
				character.NameOverride and " (" .. character.NameOverride .. ")" or "",
				character.Flag and (CharacterFlag.Get(flag).Name or flag) or defaultFlag),
			"\n")
	end
end

if CLIENT then
	netstream.Hook("ListCharacters", function(data)
		printCharacterList(data)
	end)
end

local listCharacters = console.AddCommand("rpa_listcharacters", function(ply, steamId)
	local target = player.GetBySteamID(steamId)
	local name = target and target:Nick() or steamId
	local query = GAMEMODE.Database:Select("rp_characters")
		query:Select("id")
		query:Select("Name")
		query:Select("NameOverride")
		query:Select("Flag")
		query:WhereEqual("SteamID", steamId)
		query:WhereNull("Deleted_At")
	local characters = query:Execute()

	if #characters < 1 then
		console.Feedback(ply, "ERROR", "No characters exist for %s", name)

		return
	end

	local data = {
		Name = name,
		Characters = characters
	}

	if IsValid(ply) then
		console.Feedback(ply, "NOTICE", "Sent %s's character list to your console", name)

		netstream.Send(ply, "ListCharacters", data)
	else
		printCharacterList(data)
	end
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

	console.Feedback(ply, "NOTICE", "You've set %s's alias to %s", name, alias)
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
