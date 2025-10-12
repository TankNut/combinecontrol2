local listCharacters = console.AddCommand("rpa_character_list", function(ply, steamid)
	local target = player.GetBySteamID(steamid)
	local name = target and string.format("%s (%s)", target:Nick(), steamid) or steamid
	local characters = GAMEMODE.Database:Query("SELECT `id`, COALESCE(`NameOverride`, `Name`) AS `Name`, `Flag`, `EventCharacter` FROM rp_characters WHERE `SteamID` = :steamId AND `Deleted_At` IS NULL", {
		steamId = steamid
	})

	if #characters < 1 then
		console.Feedback(ply, "ERROR", "No characters exist for %s!", name)

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





local setModel = console.AddCommand("rpa_character_model", function (ply, target, mdl)
	if not util.IsValidModel(mdl) then
		console.Feedback(ply, "ERROR", "That model is not mounted on the server!")

		return
	end

	Log.Write("admin_character_set", ply, target, "Model", mdl)

	target:SetCharacterModel(mdl)

	console.Feedback(ply, "NOTICE", "You've set %s's character model to %s", target, mdl)
	console.Feedback(target, "NOTICE", "%s has set your character model to %s", ply, mdl)
end)

setModel:SetCategory("Character Commands")
setModel:SetDescription("Updates a player's current character model")
setModel:SetExecutionContext(console.Server)
setModel:SetAccess(console.IsAdmin)

setModel:AddParameter(console.Player({
	SingleTarget = true
}))

setModel:AddParameter(console.String())





local setModelOverride = console.AddCommand("rpa_character_model_override", function (ply, target, mdl)
	if #mdl > 0 and not util.IsValidModel(mdl) then
		console.Feedback(ply, "ERROR", "That model is not mounted on the server!", target)

		return
	end

	Log.Write("admin_character_set", ply, target, "ModelOverride", mdl)

	target:SetCharacterModelOverride(mdl)

	if #mdl > 0 then
		console.Feedback(ply, "NOTICE", "You've set %s's character model override to %s", target, mdl)
		console.Feedback(target, "NOTICE", "%s has set your character model override to %s", ply, mdl)
	else
		console.Feedback(ply, "NOTICE", "You've removed %s's character model override", target)
		console.Feedback(target, "NOTICE", "%s has removed your character model override", ply)
	end
end)

setModelOverride:SetCategory("Character Commands")
setModelOverride:SetDescription("Overrides a player's current character model and disables clothing")
setModelOverride:SetExecutionContext(console.Server)
setModelOverride:SetAccess(console.IsAdmin)

setModelOverride:AddParameter(console.Player({
	SingleTarget = true
}))

setModelOverride:AddOptional(console.String(), "", "none")





local setSkin = console.AddCommand("rpa_character_skin", function (ply, target, num)
	Log.Write("admin_character_set", ply, target, "Skin", num)

	target:SetCharacterSkin(num)

	console.Feedback(ply, "NOTICE", "You've set %s's character skin to %d", target, num)
	console.Feedback(target, "NOTICE", "%s has set your character skin to %d", ply, num)
end)

setSkin:SetCategory("Character Commands")
setSkin:SetDescription("Updates a player's current character skin")
setSkin:SetExecutionContext(console.Server)
setSkin:SetAccess(console.IsAdmin)

setSkin:AddParameter(console.Player({
	SingleTarget = true
}))

setSkin:AddParameter(console.Number())





local setName = console.AddCommand("rpa_character_name", function (ply, target, name)
	Log.Write("admin_character_set", ply, target, "Name", name)

	target:SetCharacterName(name)

	console.Feedback(ply, "NOTICE", "You've set %s's character name to %s", target, name)
	console.Feedback(target, "NOTICE", "%s has set your character name to %s", ply, name)
end)

setName:SetCategory("Character Commands")
setName:SetDescription("Updates a player's current character name")
setName:SetExecutionContext(console.Server)
setName:SetAccess(console.IsAdmin)

setName:AddParameter(console.Player({
	SingleTarget = true
}))

setName:AddParameter(console.String(Config.Get("CharacterNameRules")))





local setNameOverride = console.AddCommand("rpa_character_name_override", function (ply, target, name)
	name = string.Escape(name)

	Log.Write("admin_character_set", ply, target, "NameOverride", name)

	target:SetCharacterNameOverride(name)

	if #name > 0 then
		console.Feedback(ply, "NOTICE", "You've set %s's character name override to %s", target, name)
		console.Feedback(target, "NOTICE", "%s has set your character name override to %s", ply, name)
	else
		console.Feedback(ply, "NOTICE", "You've removed %s's character name override", target)
		console.Feedback(target, "NOTICE", "%s has removed your character name override", ply)
	end
end)

setNameOverride:SetCategory("Character Commands")
setNameOverride:SetDescription("Overrides a player's current character name")
setNameOverride:SetExecutionContext(console.Server)
setNameOverride:SetAccess(console.IsAdmin)

setNameOverride:AddParameter(console.Player({
	SingleTarget = true
}))

setNameOverride:AddOptional(console.String({
	validate.String(),
	validate.Max(64),
}), "", "none")





local setScale = console.AddCommand("rpa_character_scale", function (ply, target, scale)
	Log.Write("admin_character_set", ply, target, "Scale", scale)

	target:SetCharacterScale(scale)

	console.Feedback(ply, "NOTICE", "You've set %s's character scale to %d", target, scale)
	console.Feedback(target, "NOTICE", "%s has set your character scale to %d", ply, scale)
end)

setScale:SetCategory("Character Commands")
setScale:SetDescription("Updates a player's permanent character size, use 0 to reset back to default")
setScale:SetExecutionContext(console.Server)
setScale:SetAccess(console.IsAdmin)

setScale:AddParameter(console.Player({
	SingleTarget = true
}))

setScale:AddParameter(console.Number({
	validate.Min(0),
	validate.Max(10),
}))





local setHidden = console.AddCommand("rpa_character_hide", function(ply, target, bool)
	local new = bool

	if bool == nil then
		new = not target:CharacterHidden()
	end

	local str = bool and "hidden" or "unhidden"

	Log.Write("admin_character_set", ply, target, "Hidden", new)

	target:SetCharacterHidden(new)

	console.Feedback(target, "NOTICE", "%s has %s you from the scoreboard", ply, str)
	console.Feedback(ply, "NOTICE", "You've %s %s from the scoreboard", str, target)
end)

setHidden:SetCategory("Character Commands")
setHidden:SetDescription("Toggles a character's hidden status on the scoreboard")
setHidden:SetExecutionContext(console.Server)
setHidden:SetAccess(console.IsAdmin)

setHidden:AddParameter(console.Player({
	SingleTarget = true
}))
setHidden:AddOptional(console.Bool(), nil, "flip")





local setFlag = console.AddCommand("rpa_character_flag", function(ply, target, flag)
	Log.Write("admin_character_set", ply, target, "Flag", flag)

	target:SetCharacterFlag(flag)

	local name = CharacterFlag.Get(flag).Name or flag

	console.Feedback(ply, "NOTICE", "You've set %s's character flag to %s", target:VisibleRPName(), name)
	console.Feedback(target, "NOTICE", "%s has set your character flag to %s", ply, name)
end)

setFlag:SetCategory("Character Commands")
setFlag:SetDescription("Updates a player's current character flag")
setFlag:SetExecutionContext(console.Server)
setFlag:SetAccess(console.IsAdmin)

setFlag:AddParameter(console.Player({
	SingleTarget = true
}))

setFlag:AddParameter(console.CharacterFlag())





local editInventory = console.AddCommand("rpa_character_inventory", function(ply, target)
	local inventory = target:GetInventory()

	inventory:AddListener(ply, LISTENER_ADMIN)

	ply:OpenGUI("InventoryPopup", inventory.ID)
end)

editInventory:SetCategory("Character Commands")
editInventory:SetDescription("Opens a character's inventory")
editInventory:SetExecutionContext(console.Server)
editInventory:SetAccess(console.IsAdmin)

editInventory:AddParameter(console.Player({
	SingleTarget = true
}))
