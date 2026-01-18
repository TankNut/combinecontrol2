local setModel = console.AddCommand("rpa_character_model", function (ply, target, mdl)
	if not util.IsValidModel(mdl) then
		console.Feedback(ply, "ERROR", "That model is not mounted on the server!")

		return
	end

	Log.Write("admin_character_model", ply, target, mdl)

	target:SetCharacterModel(mdl)

	console.Feedback(ply, "NOTICE", "You've set %s's character model to %s", target, mdl)
	console.Feedback(target, "NOTICE", "%s has set your character model to %s", ply, mdl)
end)

setModel:SetCategory("Character Commands")
setModel:SetDescription("Updates a player's current character model")
setModel:SetExecutionContext(console.Server)
setModel:SetAccess(console.IsAdmin)

setModel:AddParameter(console.Player())
setModel:AddParameter(console.String())





local setModelOverride = console.AddCommand("rpa_character_model_override", function (ply, target, mdl)
	if #mdl > 0 and not util.IsValidModel(mdl) then
		console.Feedback(ply, "ERROR", "That model is not mounted on the server!", target)

		return
	end

	target:SetCharacterModelOverride(mdl)

	Log.Write("admin_character_model_override", ply, target, mdl)

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

setModelOverride:AddParameter(console.Player())
setModelOverride:AddOptional(console.String(), "", "none")





local setSkin = console.AddCommand("rpa_character_skin", function (ply, target, num)
	Log.Write("admin_character_skin", ply, target, num)

	target:SetCharacterSkin(num)

	console.Feedback(ply, "NOTICE", "You've set %s's character skin to %d", target, num)
	console.Feedback(target, "NOTICE", "%s has set your character skin to %d", ply, num)
end)

setSkin:SetCategory("Character Commands")
setSkin:SetDescription("Updates a player's current character skin")
setSkin:SetExecutionContext(console.Server)
setSkin:SetAccess(console.IsAdmin)

setSkin:AddParameter(console.Player())
setSkin:AddParameter(console.Number())





local setName = console.AddCommand("rpa_character_name", function (ply, target, name)
	Log.Write("admin_character_name", ply, target, name)

	target:SetCharacterName(name)

	console.Feedback(ply, "NOTICE", "You've set %s's character name to %s", target, name)
	console.Feedback(target, "NOTICE", "%s has set your character name to %s", ply, name)
end)

setName:SetCategory("Character Commands")
setName:SetDescription("Updates a player's current character name")
setName:SetExecutionContext(console.Server)
setName:SetAccess(console.IsAdmin)

setName:AddParameter(console.Player())
setName:AddParameter(console.String(Config.Get("CharacterNameRules")))





local setNameOverride = console.AddCommand("rpa_character_name_override", function (ply, target, name)
	name = string.Escape(name)

	Log.Write("admin_character_name_override", ply, target, name)

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

setNameOverride:AddParameter(console.Player())
setNameOverride:AddOptional(console.String({validate.String(), validate.Max(64)}), "", "none")





local setScale = console.AddCommand("rpa_character_scale", function (ply, target, scale)
	Log.Write("admin_character_scale", ply, target, scale)

	target:SetCharacterScale(scale)

	console.Feedback(ply, "NOTICE", "You've set %s's character scale to %d", target, scale)
	console.Feedback(target, "NOTICE", "%s has set your character scale to %d", ply, scale)
end)

setScale:SetCategory("Character Commands")
setScale:SetDescription("Updates a player's permanent character size, use 0 to reset back to default")
setScale:SetExecutionContext(console.Server)
setScale:SetAccess(console.IsAdmin)

setScale:AddParameter(console.Player())
setScale:AddParameter(console.Number({validate.Min(0), validate.Max(10)}))





local setHidden = console.AddCommand("rpa_character_hide", function(ply, target, bool)
	local new = bool

	if bool == nil then
		new = not target:CharacterHidden()
	end

	local str = new and "hidden" or "unhidden"

	Log.Write("admin_character_hidden", ply, target, new)

	target:SetCharacterHidden(new)

	console.Feedback(target, "NOTICE", "%s has %s you from the scoreboard", ply, str)
	console.Feedback(ply, "NOTICE", "You've %s %s from the scoreboard", str, target)
end)

setHidden:SetCategory("Character Commands")
setHidden:SetDescription("Toggles a character's hidden status on the scoreboard")
setHidden:SetExecutionContext(console.Server)
setHidden:SetAccess(console.IsAdmin)

setHidden:AddParameter(console.Player())
setHidden:AddOptional(console.Bool(), nil, "flip")





local setFlag = console.AddCommand("rpa_character_flag", function(ply, target, flag)
	Log.Write("admin_character_flag", ply, target, flag)

	target:SetCharacterFlag(flag)

	local name = CharacterFlag.Get(flag).Name or flag

	console.Feedback(ply, "NOTICE", "You've set %s's character flag to %s", target:VisibleRPName(), name)
	console.Feedback(target, "NOTICE", "%s has set your character flag to %s", ply, name)
end)

setFlag:SetCategory("Character Commands")
setFlag:SetDescription("Updates a player's current character flag")
setFlag:SetExecutionContext(console.Server)
setFlag:SetAccess(console.IsAdmin)

setFlag:AddParameter(console.Player())
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

editInventory:AddParameter(console.Player())





local editStash = console.AddCommand("rpa_character_stash", function(ply, target)
	local inventory = target:GetStash()

	inventory:AddListener(ply, LISTENER_ADMIN)

	ply:OpenGUI("InventoryPopup", inventory.ID)
end)

editStash:SetCategory("Character Commands")
editStash:SetDescription("Opens a character's stash")
editStash:SetExecutionContext(console.Server)
editStash:SetAccess(console.IsAdmin)

editStash:AddParameter(console.Player())





local create = console.AddCommand("rpa_character_create", function(ply, target, generator)
	CharacterGen.Run(target, generator.ClassName)

	Log.Write("admin_character_create", ply, target, generator.ClassName)

	console.Feedback(target, "NOTICE", "%s has given you a new character", ply)
	console.Feedback(ply, "NOTICE", "You've given %s a new character", target)
end)

create:SetCategory("Character Commands")
create:SetDescription("Creates a character for someone")
create:SetExecutionContext(console.Server)
create:SetAccess(console.IsAdmin)

create:AddParameter(console.Player())
create:AddParameter(console.CharacterGen())
