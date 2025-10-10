-- rpa_language_give

local give = console.AddCommand("rpa_language_give", function(ply, target, lang, speak)
	local languageName = Language.Get(lang).Name
	local accessType = speak and "speak" or "understand"
	if (speak and target:CanSpeakLanguage(lang)) or (not speak and target:CanUnderstandLanguage(lang)) then
		console.Feedback(ply, "ERROR", "%s can already %s %s", target:VisibleRPName(), accessType, languageName)

		return
	end

	target:GiveLanguage(lang, speak)

	console.Feedback(ply, "NOTICE", "You've given %s the ability to %s %s", target:VisibleRPName(), accessType, languageName)
	console.Feedback(target, "NOTICE", "%s has given you the ability to %s %s", ply, accessType, languageName)

	Log.Write("admin_language_give", ply, target, languageName, speak)
end)

give:SetCategory("Character Commands")
give:SetDescription("Gives a spoken or understood language to a player's character")
give:SetExecutionContext(console.Server)
give:SetAccess(console.IsAdmin)

give:AddParameter(console.Player({
	SingleTarget = true
}))

give:AddParameter(console.Language())
give:AddOptional(console.Bool(nil, "speaking"), true)

-- rpa_language_take

local take = console.AddCommand("rpa_language_take", function(ply, target, lang)
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

	Log.Write("admin_language_take", ply, target, languageName, canSpeak)
end)

take:SetCategory("Character Commands")
take:SetDescription("Takes a spoken or understood language from a player's character")
take:SetExecutionContext(console.Server)
take:SetAccess(console.IsAdmin)

take:AddParameter(console.Player({
	SingleTarget = true
}))

take:AddParameter(console.Language())
