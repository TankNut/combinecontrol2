local characterWhitelist = console.AddCommand("rpa_character_whitelist", function(ply, targets, whitelist)
	local name = whitelist.Name or whitelist.ClassName

	for _, target in ipairs(targets) do
		local whitelists = target:CharacterWhitelist()
		whitelists[whitelist.ClassName] = true

		target:SetCharacterWhitelist(whitelists)

		console.Feedback(target, "NOTICE", "%s has added you to the %s whitelist", ply, name)

		Log.Write("admin_character_whitelist", ply, target, whitelist, true)
	end

	console.Feedback(ply, "NOTICE", "You've added %s to the %s whitelist", targets, name)

end)

characterWhitelist:SetCategory("Player Commands")
characterWhitelist:SetDescription("Adds a player to a character whitelist")
characterWhitelist:SetExecutionContext(console.Server)
characterWhitelist:SetAccess(console.IsAdmin)

characterWhitelist:AddParameter(console.Player({NoAdmins = true}))
characterWhitelist:AddParameter(console.CharacterWhitelist({Assignable = true}))





local characterBlacklist = console.AddCommand("rpa_character_blacklist", function(ply, targets, whitelist)
	local name = whitelist.Name or whitelist.ClassName

	for _, target in ipairs(targets) do
		local whitelists = target:CharacterWhitelist()
		whitelists[whitelist.ClassName] = nil

		target:SetCharacterWhitelist(whitelists)

		console.Feedback(target, "NOTICE", "%s has removed you from the %s whitelist", ply, name)

		Log.Write("admin_character_whitelist", ply, target, whitelist, false)
	end

	console.Feedback(ply, "NOTICE", "You've removed %s from the %s whitelist", targets, name)
end)

characterBlacklist:SetCategory("Player Commands")
characterBlacklist:SetDescription("Removes a player from a character whitelist")
characterBlacklist:SetExecutionContext(console.Server)
characterBlacklist:SetAccess(console.IsAdmin)

characterWhitelist:AddParameter(console.Player({NoAdmins = true}))
characterWhitelist:AddParameter(console.CharacterWhitelist({Assignable = true}))




local eventWhitelist = console.AddCommand("rpa_eventcharacter_whitelist", function(ply, targets, whitelist)
	local name = whitelist.Name or whitelist.ClassName

	for _, target in ipairs(targets) do
		local whitelists = target:EventCharacterWhitelist()
		whitelists[whitelist.ClassName] = true

		target:SetEventCharacterWhitelist(whitelists)

		console.Feedback(target, "NOTICE", "%s has added you to the %s event character whitelist", ply, name)

		Log.Write("admin_eventcharacter_whitelist", ply, target, whitelist, true)
	end

	console.Feedback(ply, "NOTICE", "You've added %s to the %s event character whitelist", targets, name)
end)

eventWhitelist:SetCategory("Event Character Commands")
eventWhitelist:SetDescription("Adds a player to an event character whitelist")
eventWhitelist:SetExecutionContext(console.Server)
eventWhitelist:SetAccess(console.IsAdmin)

eventWhitelist:AddParameter(console.Player({NoAdmins = true}))
eventWhitelist:AddParameter(console.EventCharacterWhitelist({Assignable = true}))





local eventBlacklist = console.AddCommand("rpa_eventcharacter_blacklist", function(ply, targets, whitelist)
	local name = whitelist.Name or whitelist.ClassName

	for _, target in ipairs(targets) do
		local whitelists = target:EventCharacterWhitelist()
		whitelists[whitelist.ClassName] = nil

		target:SetEventCharacterWhitelist(whitelists)

		console.Feedback(target, "NOTICE", "%s has removed you from the %s event character whitelist", ply, name)

		Log.Write("admin_eventcharacter_whitelist", ply, target, whitelist, false)
	end

	console.Feedback(ply, "NOTICE", "You've removed %s from the %s event character whitelist", targets, name)
end)

eventBlacklist:SetCategory("Event Character Commands")
eventBlacklist:SetDescription("Removes a player from an event character whitelist")
eventBlacklist:SetExecutionContext(console.Server)
eventBlacklist:SetAccess(console.IsAdmin)

eventBlacklist:AddParameter(console.Player({NoAdmins = true}))
eventBlacklist:AddParameter(console.EventCharacterWhitelist({Assignable = true}))
