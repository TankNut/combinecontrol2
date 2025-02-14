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

local setCharacterScale = console.AddCommand("rpa_setcharscale", function (ply, target, scale, persist)
	if persist then
		local flag = target:RunCharFlag("Scale")

		if flag != 0 then
			console.Feedback(ply, "ERROR", "%s has a character flag overriding scale, cannot persist", target)

			return
		end

		target:SetCharacterScale(scale)
	end

	target:SetScale(scale, false)

	console.Feedback(ply, "NOTICE", "You've set %s's %s scale to %d", target, persist and "character" or "", scale)
	console.Feedback(target, "NOTICE", "%s has set your %s scale to %d", ply, persist and "character" or "", scale)
end)

setCharacterScale:SetDescription("Updates a player's current character scaling")
setCharacterScale:SetExecutionContext(console.Server)
setCharacterScale:SetAccess(console.IsAdmin)

setCharacterScale:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = false,
	NoSelfTarget = false
}))

setCharacterScale:AddParameter(console.Number({
	validate.Min(0.1),
	validate.Max(10),
}))

setCharacterScale:AddOptional(console.Bool(), false)

local giveCharacterLanguage = console.AddCommand("rpa_givecharlang", function(ply, target, lang, speak)
	local languageName = Language.Get(lang).Name
	local accessType = speak and "speak" or "understand"
	if (speak and target:CanSpeakLanguage(lang)) or (not speak and target:CanUnderstandLanguage(lang)) then
		console.Feedback(ply, "ERROR", "%s can already %s %s", target:VisibleRPName(), accessType, languageName)

		return
	end

	target:GiveLanguage(lang, speak)

	GAMEMODE:LogAdmin("[T] " .. ply:Nick() .. " gave player " .. target:CharacterName() .. " " .. languageName .. ".", ply)

	console.Feedback(ply, "NOTICE", "You've given %s the ability to %s %s", target:VisibleRPName(), accessType, languageName)
	console.Feedback(target, "NOTICE", "%s has given you the ability to %s %s", ply, accessType, languageName)
end)

giveCharacterLanguage:SetDescription("Gives a spoken or understood language to a player's character")
giveCharacterLanguage:SetExecutionContext(console.Server)
giveCharacterLanguage:SetAccess(console.IsAdmin)

giveCharacterLanguage:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = false,
	NoSelfTarget = false
}))

giveCharacterLanguage:AddParameter(console.Language())

giveCharacterLanguage:AddOptional(console.Bool(), true)

local takeCharacterLanguage = console.AddCommand("rpa_takecharlang", function(ply, target, lang)
	local languageName = Language.Get(lang).Name
	local accessType = target:CanSpeakLanguage(lang) and "speak" or "understand"

	if not target:CanUnderstandLanguage(lang) then
		console.Feedback(ply, "ERROR", "%s does not %s %s", target:VisibleRPName(), accessType, languageName)

		return
	end

	target:TakeLanguage(lang)

	GAMEMODE:LogAdmin("[T] " .. ply:Nick() .. " took " .. languageName ..  " from player " .. target:CharacterName() .. ".", ply)

	console.Feedback(ply, "NOTICE", "You've taken %s's ability to %s %s", target:VisibleRPName(), accessType, languageName)
	console.Feedback(target, "NOTICE", "%s has taken your the ability to %s %s", ply, accessType, languageName)
end)

takeCharacterLanguage:SetDescription("Takes a spoken or understood language from a player's character")
takeCharacterLanguage:SetExecutionContext(console.Server)
takeCharacterLanguage:SetAccess(console.IsAdmin)

takeCharacterLanguage:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = false,
	NoSelfTarget = false
}))

takeCharacterLanguage:AddParameter(console.Language())
