local setCharacterModel = console.AddCommand("rpa_setcharmodel", function (ply, target, mdl)
	if not util.IsValidModel(mdl) then
		console.Feedback(ply, "ERROR", "The given model is not mounted on the server", target)

		return
	end

	Log.Write("admin_character_set", ply, target, "Model", mdl)

	target:SetCharacterModel(mdl)
	target:UpdateAppearance()

	console.Feedback(ply, "NOTICE", "You've set %s's character model to %s", target, mdl)
	console.Feedback(target, "NOTICE", "%s has set your character model to %s", ply, mdl)
end)

setCharacterModel:SetCategory("Character Commands")
setCharacterModel:SetDescription("Updates a player's current character model")
setCharacterModel:SetExecutionContext(console.Server)
setCharacterModel:SetAccess(console.IsAdmin)

setCharacterModel:AddParameter(console.Player({
	SingleTarget = true
}))

setCharacterModel:AddParameter(console.String())

local setCharacterSkin = console.AddCommand("rpa_setcharskin", function (ply, target, skin)
	Log.Write("admin_character_set", ply, target, "Skin", skin)

	target:SetCharacterSkin(skin)
	target:UpdateAppearance()

	console.Feedback(ply, "NOTICE", "You've set %s's character skin to %d", target, skin)
	console.Feedback(target, "NOTICE", "%s has set your character skin to %d", ply, skin)
end)

setCharacterSkin:SetCategory("Character Commands")
setCharacterSkin:SetDescription("Updates a player's current character skin")
setCharacterSkin:SetExecutionContext(console.Server)
setCharacterSkin:SetAccess(console.IsAdmin)

setCharacterSkin:AddParameter(console.Player({
	SingleTarget = true
}))

setCharacterSkin:AddParameter(console.Number())

local setCharacterName = console.AddCommand("rpa_setcharname", function (ply, target, name)
	Log.Write("admin_character_set", ply, target, "Name", name)

	target:SetCharacterName(name)
	target:UpdateVisibleName()

	console.Feedback(ply, "NOTICE", "You've set %s's character name to %s", target, name)
	console.Feedback(target, "NOTICE", "%s has set your character name to %s", ply, name)
end)

setCharacterName:SetCategory("Character Commands")
setCharacterName:SetDescription("Updates a player's current character name")
setCharacterName:SetExecutionContext(console.Server)
setCharacterName:SetAccess(console.IsAdmin)

setCharacterName:AddParameter(console.Player({
	SingleTarget = true
}))

setCharacterName:AddParameter(console.String(Config.Get("CharacterNameRules")))

local setCharacterScale = console.AddCommand("rpa_setcharscale", function (ply, target, scale, persist)
	if persist then
		local flag = target:RunCharFlag("Scale")

		if flag != 0 then
			console.Feedback(ply, "ERROR", "%s has a character flag overriding scale, cannot persist", target)

			return
		end

		target:SetCharacterScale(scale)
	end

	Log.Write("admin_character_set", ply, target, "Scale", scale)

	target:SetScale(scale)

	console.Feedback(ply, "NOTICE", "You've set %s's %s scale to %d", target, persist and "character" or "", scale)
	console.Feedback(target, "NOTICE", "%s has set your %s scale to %d", ply, persist and "character" or "", scale)
end)

setCharacterScale:SetCategory("Character Commands")
setCharacterScale:SetDescription("Updates a player's current character scale")
setCharacterScale:SetExecutionContext(console.Server)
setCharacterScale:SetAccess(console.IsAdmin)

setCharacterScale:AddParameter(console.Player({
	SingleTarget = true
}))

setCharacterScale:AddParameter(console.Number({
	validate.Min(0.1),
	validate.Max(10),
}))

setCharacterScale:AddOptional(console.Bool({}, "Persist"), nil, "false")

local giveCharacterLanguage = console.AddCommand("rpa_givecharlang", function(ply, target, lang, speak)
	local languageName = Language.Get(lang).Name
	local accessType = speak and "speak" or "understand"
	if (speak and target:CanSpeakLanguage(lang)) or (not speak and target:CanUnderstandLanguage(lang)) then
		console.Feedback(ply, "ERROR", "%s can already %s %s", target:VisibleRPName(), accessType, languageName)

		return
	end

	target:GiveLanguage(lang, speak)

	console.Feedback(ply, "NOTICE", "You've given %s the ability to %s %s", target:VisibleRPName(), accessType, languageName)
	console.Feedback(target, "NOTICE", "%s has given you the ability to %s %s", ply, accessType, languageName)

	Log.Write("admin_character_givelang", ply, target, languageName, speak)
end)

giveCharacterLanguage:SetCategory("Character Commands")
giveCharacterLanguage:SetDescription("Gives a spoken or understood language to a player's character")
giveCharacterLanguage:SetExecutionContext(console.Server)
giveCharacterLanguage:SetAccess(console.IsAdmin)

giveCharacterLanguage:AddParameter(console.Player({
	SingleTarget = true
}))

giveCharacterLanguage:AddParameter(console.Language())

giveCharacterLanguage:AddOptional(console.Bool(), true)

local takeCharacterLanguage = console.AddCommand("rpa_takecharlang", function(ply, target, lang)
	local languageName = Language.Get(lang).Name
	local canSpeak = target:CanSpeakLanguage(lang)
	local accessType = canSpeak and "speak" or "understand"

	if not target:CanUnderstandLanguage(lang) then
		console.Feedback(ply, "ERROR", "%s does not %s %s", target:VisibleRPName(), accessType, languageName)

		return
	end

	target:TakeLanguage(lang)

	console.Feedback(ply, "NOTICE", "You've taken %s's ability to %s %s", target:VisibleRPName(), accessType, languageName)
	console.Feedback(target, "NOTICE", "%s has taken your the ability to %s %s", ply, accessType, languageName)

	Log.Write("admin_character_takelang", ply, target, languageName, canSpeak)
end)

takeCharacterLanguage:SetCategory("Character Commands")
takeCharacterLanguage:SetDescription("Takes a spoken or understood language from a player's character")
takeCharacterLanguage:SetExecutionContext(console.Server)
takeCharacterLanguage:SetAccess(console.IsAdmin)

takeCharacterLanguage:AddParameter(console.Player({
	SingleTarget = true
}))

takeCharacterLanguage:AddParameter(console.Language())

local hideCharacter = console.AddCommand("rpa_setcharhidden", function(ply, targets, bool)
	local targetCount = table.Count(targets)

	if targetCount > 1 and bool == nil then
		console.Feedback(ply, "ERROR", "Multiple matches found when attempting to flip hidden status")

		return
	end

	for _, target in pairs(targets) do
		local new = 1 - target:CharacterHidden()

		if bool != nil then
			new = bool and 1 or 0
		end

		Log.Write("admin_character_set", ply, target, "Hidden", new)

		target:SetCharacterHidden(new)

		console.Feedback(ply, "NOTICE", "%s has %s you from the scoreboard", ply, new == 1 and "hidden" or "unhidden")
	end

	console.Feedback(ply, "NOTICE", "You've updated scoreboard visibility for %s", targetCount == 1 and targets[1] or (targetCount .. " players"))
end)

hideCharacter:SetCategory("Character Commands")
hideCharacter:SetDescription("Toggles a character's hidden status on the scoreboard")
hideCharacter:SetExecutionContext(console.Server)
hideCharacter:SetAccess(console.IsAdmin)

hideCharacter:AddParameter(console.Player())
hideCharacter:AddOptional(console.Bool())

local setCharacterFlag = console.AddCommand("rpa_setcharflag", function(ply, target, flag)
	Log.Write("admin_character_set", ply, target, "Flag", flag)

	target:SetCharacterFlag(flag)

	local name = CharacterFlag.Get(flag).Name or flag

	console.Feedback(ply, "NOTICE", "You've set %s's character flag to %s", target:VisibleRPName(), name)
	console.Feedback(target, "NOTICE", "%s has set your character flag to %s", ply, name)
end)

setCharacterFlag:SetCategory("Character Commands")
setCharacterFlag:SetDescription("Updates a player's current character flag")
setCharacterFlag:SetExecutionContext(console.Server)
setCharacterFlag:SetAccess(console.IsAdmin)

setCharacterFlag:AddParameter(console.Player({
	SingleTarget = true
}))

setCharacterFlag:AddParameter(console.CharacterFlag())
