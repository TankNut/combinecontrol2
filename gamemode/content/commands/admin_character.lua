local setCharacterModel = console.AddCommand("rpa_setcharmodel", function (ply, target, mdl)
	if not util.IsValidModel(mdl) then
		console.Feedback(ply, "ERROR", "The given model is not mounted on server", target)

		return
	end

	target:SetCharacterModel(mdl)
	target:UpdateAppearance()

	GAMEMODE:WriteLog("admin_setmodel", {Admin = GAMEMODE:LogPlayer(ply), Ply = GAMEMODE:LogPlayer(target), Char = GAMEMODE:LogCharacter(target), Model = mdl})

	console.Feedback(ply, "NOTICE", "You've set %s's character model to %s", target, mdl)
	console.Feedback(target, "NOTICE", "%s has set your character model to %s", ply, mdl)
end)

setCharacterModel:SetDescription("Updates a player's current character model")
setCharacterModel:SetExecutionContext(console.Server)
setCharacterModel:SetAccess(console.IsAdmin)

setCharacterModel:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = false,
	NoSelfTarget = false
}))

setCharacterModel:AddParameter(console.String())

local setCharacterSkin = console.AddCommand("rpa_setcharskin", function (ply, target, skin)
	target:SetCharacterSkin(skin)
	target:UpdateAppearance()

	GAMEMODE:WriteLog("admin_setskin", {Admin = GAMEMODE:LogPlayer(ply), Ply = GAMEMODE:LogPlayer(target), Char = GAMEMODE:LogCharacter(target), Skin = skin})

	console.Feedback(ply, "NOTICE", "You've set %s's character skin to %d", target, skin)
	console.Feedback(target, "NOTICE", "%s has set your character skin to %d", ply, skin)
end)

setCharacterSkin:SetDescription("Updates a player's current character skin")
setCharacterSkin:SetExecutionContext(console.Server)
setCharacterSkin:SetAccess(console.IsAdmin)

setCharacterSkin:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = false,
	NoSelfTarget = false
}))

setCharacterSkin:AddParameter(console.Number())

local setCharacterName = console.AddCommand("rpa_setcharname", function (ply, target, name)
	target:SetCharacterName(name)
	target:UpdateVisibleName()

	GAMEMODE:WriteLog("admin_setname", {Admin = GAMEMODE:LogPlayer(ply), Ply = GAMEMODE:LogPlayer(target), Char = GAMEMODE:LogCharacter(target), Name = name})

	console.Feedback(ply, "NOTICE", "You've set %s's character name to %s", target, name)
	console.Feedback(target, "NOTICE", "%s has set your character name to %s", ply, name)
end)

setCharacterName:SetDescription("Updates a player's current character name")
setCharacterName:SetExecutionContext(console.Server)
setCharacterName:SetAccess(console.IsAdmin)

setCharacterName:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = false,
	NoSelfTarget = false
}))

setCharacterName:AddParameter(console.String({
	validate.Min(Config.Get("MinNameLength")),
	validate.Max(Config.Get("MaxNameLength")),
	validate.AllowedCharacters(Config.Get("AllowedNameCharacters"))
}))
