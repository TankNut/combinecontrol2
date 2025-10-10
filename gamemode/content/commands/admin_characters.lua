local setModel = console.AddCommand("rpa_setcharmodel", function (ply, target, mdl)
	if not util.IsValidModel(mdl) then
		console.Feedback(ply, "ERROR", "The given model is not mounted on the server", target)

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

local setModelOverride = console.AddCommand("rpa_setcharmodel_override", function (ply, target, mdl)
	if #mdl > 0 and not util.IsValidModel(mdl) then
		console.Feedback(ply, "ERROR", "The given model is not mounted on the server", target)

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

local setSkin = console.AddCommand("rpa_setcharskin", function (ply, target, num)
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

local setName = console.AddCommand("rpa_setcharname", function (ply, target, name)
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

local setNameOverride = console.AddCommand("rpa_setcharname_override", function (ply, target, name)
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

local setScale = console.AddCommand("rpa_setcharscale", function (ply, target, scale)
	Log.Write("admin_character_set", ply, target, "Scale", scale)

	target:SetCharacterScale(scale)

	console.Feedback(ply, "NOTICE", "You've set %s's character scale to %d", target, scale)
	console.Feedback(target, "NOTICE", "%s has set your character scale to %d", ply, scale)
end)

setScale:SetCategory("Character Commands")
setScale:SetDescription("Updates a player's permanent character size, a size of 0 resets to flag default")
setScale:SetExecutionContext(console.Server)
setScale:SetAccess(console.IsAdmin)

setScale:AddParameter(console.Player({
	SingleTarget = true
}))

setScale:AddParameter(console.Number({
	validate.Min(0),
	validate.Max(10),
}))

local giveLanguage = console.AddCommand("rpa_givelanguage", function(ply, target, lang, speak)
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

giveLanguage:SetCategory("Character Commands")
giveLanguage:SetDescription("Gives a spoken or understood language to a player's character")
giveLanguage:SetExecutionContext(console.Server)
giveLanguage:SetAccess(console.IsAdmin)

giveLanguage:AddParameter(console.Player({
	SingleTarget = true
}))

giveLanguage:AddParameter(console.Language())
giveLanguage:AddOptional(console.Bool(nil, "speaking"), true)

local takeLanguage = console.AddCommand("rpa_takelanguage", function(ply, target, lang)
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

takeLanguage:SetCategory("Character Commands")
takeLanguage:SetDescription("Takes a spoken or understood language from a player's character")
takeLanguage:SetExecutionContext(console.Server)
takeLanguage:SetAccess(console.IsAdmin)

takeLanguage:AddParameter(console.Player({
	SingleTarget = true
}))

takeLanguage:AddParameter(console.Language())

local setHidden = console.AddCommand("rpa_setcharhidden", function(ply, targets, bool)
	local targetCount = table.Count(targets)

	if targetCount > 1 and bool == nil then
		console.Feedback(ply, "ERROR", "Multiple matches found when attempting to flip hidden status")

		return
	end

	for _, target in pairs(targets) do
		local new

		if bool == nil then
			new = not target:CharacterHidden()
		else
			new = bool
		end

		Log.Write("admin_character_set", ply, target, "Hidden", new)

		target:SetCharacterHidden(new)

		console.Feedback(target, "NOTICE", "%s has %s you from the scoreboard", ply, new and "hidden" or "unhidden")
	end

	console.Feedback(ply, "NOTICE", "You've updated scoreboard visibility for %s", targetCount == 1 and targets[1] or (targetCount .. " players"))
end)

setHidden:SetCategory("Character Commands")
setHidden:SetDescription("Toggles a character's hidden status on the scoreboard")
setHidden:SetExecutionContext(console.Server)
setHidden:SetAccess(console.IsAdmin)

setHidden:AddParameter(console.Player())
setHidden:AddOptional(console.Bool())

local setFlag = console.AddCommand("rpa_setcharflag", function(ply, target, flag)
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

local editInventory = console.AddCommand("rpa_editinventory", function(ply, target)
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
