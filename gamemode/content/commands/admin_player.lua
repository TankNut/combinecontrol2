local setPhysTrust = console.AddCommand("rpa_setphystrust", function (ply, target, bool)
	target:SetPhysTrust(bool and PHYSTRUST_ENABLED or PHYSTRUST_BANNED)
	target:UpdateLoadout()

	GAMEMODE:LogAdmin("[S] " .. ply:Nick() .. " changed player " .. target:CharacterName() .. "'s phystrust to " .. tostring(bool), ply)

	console.Feedback(ply, "NOTICE", "You %s %s physics gun trust", bool and "gave" or "removed", target)
	console.Feedback(target, "NOTICE", "%s has %s physics gun trust", ply, bool and "given you" or "taken your")
end)

setPhysTrust:SetCategory("Player Commands")
setPhysTrust:SetDescription("Sets a player's physics gun access")
setPhysTrust:SetExecutionContext(console.Server)
setPhysTrust:SetAccess(console.IsAdmin)

setPhysTrust:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = true,
	NoSelfTarget = false
}))

setPhysTrust:AddParameter(console.Bool())

local setPropTrust = console.AddCommand("rpa_setproptrust", function (ply, target, bool)
	target:SetPropTrust(bool and PROPTRUST_ENABLED or PROPTRUST_BANNED)
	target:UpdateLoadout()

	GAMEMODE:LogAdmin("[S] " .. ply:Nick() .. " changed player " .. target:CharacterName() .. "'s proptrust to " .. tostring(bool), ply)

	console.Feedback(ply, "NOTICE", "You %s %s prop spawning trust", bool and "gave" or "removed", target)
	console.Feedback(target, "NOTICE", "%s has %s prop spawning trust", ply, bool and "given you" or "taken your")
end)

setPropTrust:SetCategory("Player Commands")
setPropTrust:SetDescription("Sets a player's prop spawning access")
setPropTrust:SetExecutionContext(console.Server)
setPropTrust:SetAccess(console.IsAdmin)

setPropTrust:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = true,
	NoSelfTarget = false
}))

setPropTrust:AddParameter(console.Bool())

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

	GAMEMODE:LogAdmin("[S] " .. ply:Nick() .. " changed player " .. target:CharacterName() .. "'s tooltrust to " .. tostring(trust), ply)

	console.Feedback(ply, "NOTICE", "You've set %s's tool trust to %s", target, trust)
	console.Feedback(target, "NOTICE", "%s has set your tool trust to %s", ply, trust)
end)

setToolTrust:SetCategory("Player Commands")
setToolTrust:SetDescription("Sets a player's toolgun access")
setToolTrust:SetExecutionContext(console.Server)
setToolTrust:SetAccess(console.IsAdmin)

setToolTrust:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = true,
	NoSelfTarget = false
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
oocMute:SetDescription("Mute or unmutes a player from OOC chat")
oocMute:SetExecutionContext(console.Server)
oocMute:SetAccess(console.IsAdmin)

oocMute:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = true,
	NoSelfTarget = false
}))

oocMute:AddOptional(console.Bool())

local heal = console.AddCommand("rpa_heal", function(ply, targets)
	for _,target in pairs(targets) do
		if target:Health() > target:GetMaxHealth() then
			continue -- Don't reset the health of admins using rpa_sethealth.
		end

		target.ArmorFraction = 1

		target:SetHealth(target:GetMaxHealth())
		target:SetArmor(target:GetMaxArmor())

		GAMEMODE:WriteLog("admin_heal", {Admin = GAMEMODE:LogPlayer(ply), Ply = GAMEMODE:LogPlayer(target), Char = GAMEMODE:LogCharacter(target), Self = ply == target})

		console.Feedback(target, "NOTICE", "%s has healed you", ply)
	end

	local targetCount = table.Count(targets)

	if targetCount == 1 then
		console.Feedback(ply, "NOTICE", "You've healed %s", targets[1])
	else
		console.Feedback(ply, "NOTICE", "You've healed %d players", targetCount)
	end
end)

heal:SetCategory("Player Commands")
heal:SetDescription("Heals one or more players to full health and armor")
heal:SetExecutionContext(console.Server)
heal:SetAccess(console.IsAdmin)

heal:AddParameter(console.Player({
	SingleTarget = false,
	CheckImmunity = false,
	NoSelfTarget = false
}))

local setHealth = console.AddCommand("rpa_sethealth", function(ply, target, max)
	target:SetHealth(max)

	console.Feedback(ply, "NOTICE", "You've set %s's health to %d", target, max)
	console.Feedback(target, "NOTICE", "%s set your health to %d", ply, max)
end)

setHealth:SetCategory("Player Commands")
setHealth:SetDescription("Manually sets a player's health bar")
setHealth:SetExecutionContext(console.Server)
setHealth:SetAccess(console.IsAdmin)

setHealth:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = false,
	NoSelfTarget = false
}))

setHealth:AddParameter(console.Number({
	validate.Min(0),
	validate.Max(100000)
}))

local kill = console.AddCommand("rpa_kill", function(ply, target)
	target:Kill()

	console.Feedback(target, "NOTICE", "%s killed you", ply)

	GAMEMODE:WriteLog("admin_kill", {Admin = GAMEMODE:LogPlayer(ply), Ply = GAMEMODE:LogPlayer(target), Char = GAMEMODE:LogCharacter(target)})
end)

kill:SetCategory("Player Commands")
kill:SetDescription("Kills a player")
kill:SetExecutionContext(console.Server)
kill:SetAccess(console.IsAdmin)

kill:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = true,
	NoSelfTarget = false
}))

local slap = console.AddCommand("rpa_slap", function(ply, target)
	target:SetVelocity(Vector(math.random(-400, 400), math.random(-400, 400), math.random(400, 600)))

	console.Feedback(target, "NOTICE", "%s slapped you", ply)

	GAMEMODE:WriteLog("admin_slap", {Admin = GAMEMODE:LogPlayer(ply), Ply = GAMEMODE:LogPlayer(target), Char = GAMEMODE:LogCharacter(target)})
end)

slap:SetCategory("Player Commands")
slap:SetDescription("Slaps a player")
slap:SetExecutionContext(console.Server)
slap:SetAccess(console.IsAdmin)

slap:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = true,
	NoSelfTarget = false
}))
