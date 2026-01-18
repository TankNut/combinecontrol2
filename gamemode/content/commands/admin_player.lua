local toolTrustMapping = {
	banned = TOOLTRUST_BANNED,
	untrusted = TOOLTRUST_UNTRUSTED,
	trusted = TOOLTRUST_TRUSTED,
	advanced = TOOLTRUST_ADVANCED
}





local setToolTrust = console.AddCommand("rpa_player_tooltrust", function(ply, target, trust)
	local toolTrustLevel = toolTrustMapping[trust]

	target:SetToolTrust(toolTrustLevel)

	console.Feedback(ply, "NOTICE", "You've set %s's tool trust to %s", target, trust)
	console.Feedback(target, "NOTICE", "%s has set your tool trust to %s", ply, trust)

	Log.Write("admin_player_tooltrust", ply, target, trust)
end)

setToolTrust:SetCategory("Player Commands")
setToolTrust:SetDescription("Sets a player's toolgun access")
setToolTrust:SetExecutionContext(console.Server)
setToolTrust:SetAccess(console.IsAdmin)

setToolTrust:AddParameter(console.Player({NoAdmins = true}))
setToolTrust:AddParameter(console.String({
	validate.InList(table.GetKeys(toolTrustMapping))
}))





local heal = console.AddCommand("rpa_heal", function(ply, target)
	-- Don't reset the health of rpa_sethealth'ed players
	if target:Health() < target:GetMaxHealth() then
		target:SetHealth(target:GetMaxHealth())
	end

	-- Ditto for rpa_setarmor
	if target:Armor() < target:GetMaxArmor() then
		target:SetArmor(target:GetMaxArmor())
	end

	console.Feedback(target, "NOTICE", "%s has healed you", ply)
	console.Feedback(ply, "NOTICE", "You've healed %s", targets)

	Log.Write("admin_player_heal", ply, target)
end)

heal:SetCategory("Player Commands")
heal:SetDescription("Heals a player to full health and armor")
heal:SetExecutionContext(console.Server)
heal:SetAccess(console.IsAdmin)

heal:AddParameter(console.Player())





local healAll = console.AddCommand("rpa_heal_all", function(ply)
	for _, target in player.Iterator() do
		-- Don't reset the health of rpa_sethealth'ed players
		if target:Health() < target:GetMaxHealth() then
			target:SetHealth(target:GetMaxHealth())
		end

		-- Ditto for rpa_setarmor
		if target:Armor() < target:GetMaxArmor() then
			target:SetArmor(target:GetMaxArmor())
		end
	end

	Chat.Send("NOTICE", console.FormatMessage("%s has healed everyone", ply))

	Log.Write("admin_player_heal_all", ply)
end)

healAll:SetCategory("Player Commands")
healAll:SetDescription("Heals everyone to full health and armor")
healAll:SetExecutionContext(console.Server)
healAll:SetAccess(console.IsAdmin)





local setHealth = console.AddCommand("rpa_player_health", function(ply, target, health)
	target:SetHealth(health)

	console.Feedback(target, "NOTICE", "%s has set your health to %d", ply, health)
	console.Feedback(ply, "NOTICE", "You've set the health of %s to %d", targets, health)

	Log.Write("admin_player_health", ply, target, health)
end)

setHealth:SetCategory("Player Commands")
setHealth:SetDescription("Sets a player's health")
setHealth:SetExecutionContext(console.Server)
setHealth:SetAccess(console.IsAdmin)

setHealth:AddParameter(console.Player())
setHealth:AddParameter(console.Number())





local setArmor = console.AddCommand("rpa_player_armor", function(ply, target, armor)
	target:SetArmor(armor)

	console.Feedback(target, "NOTICE", "%s has set your armor to %d", ply, armor)
	console.Feedback(ply, "NOTICE", "You've set the armor of %s to %d", targets, armor)

	Log.Write("admin_player_armor", ply, target, armor)
end)

setArmor:SetCategory("Player Commands")
setArmor:SetDescription("Sets a player's armor")
setArmor:SetExecutionContext(console.Server)
setArmor:SetAccess(console.IsAdmin)

setArmor:AddParameter(console.Player())
setArmor:AddParameter(console.Number())





local kill = console.AddCommand("rpa_kill", function(ply, target)
	target:Kill()

	console.Feedback(target, "NOTICE", "%s has killed you", ply)
	console.Feedback(ply, "NOTICE", "You've killed %s", target)

	Log.Write("admin_player_kill", ply, target)
end)

kill:SetCategory("Player Commands")
kill:SetChatAlias("kill")
kill:SetDescription("Kills a player")
kill:SetExecutionContext(console.Server)
kill:SetAccess(console.IsAdmin)

kill:AddParameter(console.Player())





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

slap:AddParameter(console.Player())





local setScale = console.AddCommand("rpa_player_scale", function (ply, target, scale)
	Log.Write("admin_player_scale", ply, target, scale)

	target:SetScale(scale)

	console.Feedback(ply, "NOTICE", "You've set %s's character scale to %d", target, scale)
	console.Feedback(target, "NOTICE", "%s has set your character scale to %d", ply, scale)
end)

setScale:SetCategory("Player Commands")
setScale:SetDescription("Updates a player's current size")
setScale:SetExecutionContext(console.Server)
setScale:SetAccess(console.IsAdmin)

setScale:AddParameter(console.Player())
setScale:AddParameter(console.Number({validate.Min(0.1), validate.Max(10)}))
